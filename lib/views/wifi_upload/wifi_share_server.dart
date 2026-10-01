import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/path.dart';
import 'package:path/path.dart' as p;

final _safeName = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]*$');

bool isShareableName(String name) {
  if (!_safeName.hasMatch(name)) return false;
  final lower = name.toLowerCase();
  return lower.endsWith('.conf') || lower.endsWith('.sgmodule');
}

class WifiShareServer {
  HttpServer? _server;
  final _filesChanged = StreamController<void>.broadcast();

  Stream<void> get filesChanged => _filesChanged.stream;

  int? get port => _server?.port;

  bool get running => _server != null;

  Future<String> get shareDir async {
    final dir = Directory(p.join(await appPath.homeDirPath, 'wifi_share'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<List<FileSystemEntity>> listFiles() async {
    final dir = Directory(await shareDir);
    if (!await dir.exists()) return const [];
    final files = await dir.list().toList();
    files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    return files.whereType<File>().toList();
  }

  Future<void> start() async {
    if (_server != null) return;
    await shareDir;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _server!.listen(_handleRequest);
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    await server?.close(force: true);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (request.method == 'GET' && (path == '/' || path.isEmpty)) {
        await _serveIndex(request);
      } else if (request.method == 'GET' && path.startsWith('/f/')) {
        await _serveFile(request, path.substring(3));
      } else if (request.method == 'POST' && path == '/upload') {
        await _handleUpload(request);
      } else if (request.method == 'DELETE' && path.startsWith('/f/')) {
        await _handleDelete(request, path.substring(3));
      } else {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      }
    } catch (_) {
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> _serveIndex(HttpRequest request) async {
    final files = await listFiles();
    final rows = files
        .map((file) {
          final name = p.basename(file.path);
          final encoded = Uri.encodeComponent(name);
          return '<li><a href="/f/$encoded">$name</a> '
              '<button onclick="del(\'$encoded\')">delete</button></li>';
        })
        .join('\n');
    final html =
        '''
<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Eclipse Wi-Fi Share</title></head><body>
<h2>Eclipse Wi-Fi Share</h2>
<input type="file" id="file" accept=".conf,.sgmodule">
<button onclick="up()">Upload</button>
<ul>$rows</ul>
<script>
async function up(){
const f=document.getElementById("file").files[0];
if(!f){return;}
await fetch("/upload?name="+encodeURIComponent(f.name),{method:"POST",body:f});
location.reload();}
async function del(n){
await fetch("/f/"+n,{method:"DELETE"});
location.reload();}
</script></body></html>''';
    request.response.headers.contentType = ContentType.html;
    request.response.write(html);
    await request.response.close();
  }

  Future<void> _serveFile(HttpRequest request, String rawName) async {
    final name = Uri.decodeComponent(rawName);
    if (!isShareableName(name)) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }
    final file = File(p.join(await shareDir, name));
    if (!await file.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    request.response.headers.contentType = ContentType.binary;
    request.response.headers.add(
      'Content-Disposition',
      'attachment; filename="$name"',
    );
    await request.response.addStream(file.openRead());
    await request.response.close();
  }

  Future<void> _handleUpload(HttpRequest request) async {
    final name = request.uri.queryParameters['name'];
    if (name == null || !isShareableName(name)) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write('bad name');
      await request.response.close();
      return;
    }
    final file = File(p.join(await shareDir, name));
    final sink = file.openWrite();
    await request.listen(sink.add).asFuture<void>();
    await sink.close();
    _filesChanged.add(null);
    request.response.write('ok');
    await request.response.close();
  }

  Future<void> _handleDelete(HttpRequest request, String rawName) async {
    final name = Uri.decodeComponent(rawName);
    if (!isShareableName(name)) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }
    final file = File(p.join(await shareDir, name));
    if (await file.exists()) {
      await file.delete();
      _filesChanged.add(null);
    }
    request.response.write('ok');
    await request.response.close();
  }

  void dispose() {
    unawaited(stop());
    unawaited(_filesChanged.close());
  }
}
