import 'dart:convert';

/// Serialize a Clash proxy map back to a share link (`vless://`, ...).
/// Mirrors `parseShareLink` in `shadowrocket.dart`; returns null for proxy
/// types without a link representation or when required fields are missing.
/// Best-effort: fields the link format cannot carry are dropped, the link
/// still connects.
String? proxyToShareLink(Map<String, dynamic> proxy) {
  try {
    return switch ('${proxy['type'] ?? ''}'.toLowerCase()) {
      'vless' => _vlessLink(proxy),
      'vmess' => _vmessLink(proxy),
      'ss' => _ssLink(proxy),
      'trojan' => _trojanLink(proxy),
      'hysteria2' => _hysteria2Link(proxy),
      _ => null,
    };
  } catch (_) {
    return null;
  }
}

String _hostPort(Map<String, dynamic> proxy) {
  final host = '${proxy['server'] ?? ''}';
  final port = proxy['port'];
  if (host.isEmpty || port == null) throw const FormatException('no server');
  final wrapped = host.contains(':') ? '[$host]' : host;
  return '$wrapped:$port';
}

String _nameFrag(Map<String, dynamic> proxy) {
  final name = '${proxy['name'] ?? ''}';
  return name.isEmpty ? '' : '#${Uri.encodeComponent(name)}';
}

String _query(Map<String, String> params) {
  if (params.isEmpty) return '';
  final query = params.entries
      .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');
  return '?$query';
}

Map<String, String> _tlsParams(Map<String, dynamic> proxy) {
  final params = <String, String>{};
  final sni = '${proxy['servername'] ?? proxy['sni'] ?? ''}';
  if (sni.isNotEmpty) params['sni'] = sni;
  final fp = '${proxy['client-fingerprint'] ?? ''}';
  if (fp.isNotEmpty) params['fp'] = fp;
  final alpn = proxy['alpn'];
  if (alpn is List && alpn.isNotEmpty) {
    params['alpn'] = alpn.join(',');
  }
  return params;
}

Map<String, String> _streamParams(Map<String, dynamic> proxy) {
  final params = <String, String>{};
  final net = '${proxy['network'] ?? 'tcp'}';
  if (net != 'tcp') params['type'] = net;
  final wsOpts = proxy['ws-opts'];
  if (wsOpts is Map) {
    final path = '${wsOpts['path'] ?? ''}';
    if (path.isNotEmpty) params['path'] = path;
    final headers = wsOpts['headers'];
    if (headers is Map && '${headers['Host'] ?? ''}'.isNotEmpty) {
      params['host'] = '${headers['Host']}';
    }
  }
  final grpcOpts = proxy['grpc-opts'];
  if (grpcOpts is Map && '${grpcOpts['grpc-service-name'] ?? ''}'.isNotEmpty) {
    params['serviceName'] = '${grpcOpts['grpc-service-name']}';
  }
  return params;
}

String? _vlessLink(Map<String, dynamic> proxy) {
  final uuid = '${proxy['uuid'] ?? ''}';
  if (uuid.isEmpty) return null;
  final params = <String, String>{};
  final realityOpts = proxy['reality-opts'];
  if (realityOpts is Map) {
    params['security'] = 'reality';
    final pbk = '${realityOpts['public-key'] ?? ''}';
    if (pbk.isNotEmpty) params['pbk'] = pbk;
    final sid = '${realityOpts['short-id'] ?? ''}';
    if (sid.isNotEmpty) params['sid'] = sid;
  } else if (proxy['tls'] == true) {
    params['security'] = 'tls';
  }
  params.addAll(_tlsParams(proxy));
  final flow = '${proxy['flow'] ?? ''}';
  if (flow.isNotEmpty) params['flow'] = flow;
  params.addAll(_streamParams(proxy));
  return 'vless://$uuid@${_hostPort(proxy)}${_query(params)}${_nameFrag(proxy)}';
}

String? _vmessLink(Map<String, dynamic> proxy) {
  final host = '${proxy['server'] ?? ''}';
  final port = proxy['port'];
  if (host.isEmpty || port == null) return null;
  final net = '${proxy['network'] ?? 'tcp'}';
  final tls = proxy['tls'] == true;
  final wsOpts = proxy['ws-opts'];
  final h2Opts = proxy['h2-opts'];
  final grpcOpts = proxy['grpc-opts'];
  final json = {
    'v': '2',
    'ps': '${proxy['name'] ?? ''}',
    'add': host,
    'port': '$port',
    'id': '${proxy['uuid'] ?? ''}',
    'aid': '${proxy['alterId'] ?? 0}',
    'net': net,
    'type': 'none',
    'host': wsOpts is Map
        ? '${(wsOpts['headers'] as Map?)?['Host'] ?? ''}'
        : h2Opts is Map
        ? '${(h2Opts['host'] as List?)?.firstOrNull ?? ''}'
        : '',
    'path': wsOpts is Map
        ? '${wsOpts['path'] ?? ''}'
        : grpcOpts is Map
        ? '${grpcOpts['grpc-service-name'] ?? ''}'
        : '',
    'tls': tls ? 'tls' : '',
    'sni': '${proxy['servername'] ?? ''}',
  };
  final encoded = base64.encode(utf8.encode(jsonEncode(json)));
  return 'vmess://$encoded';
}

String? _ssLink(Map<String, dynamic> proxy) {
  final method = '${proxy['cipher'] ?? ''}';
  final password = '${proxy['password'] ?? ''}';
  if (method.isEmpty || password.isEmpty) return null;
  final userinfo = base64.encode(utf8.encode('$method:$password'));
  return 'ss://$userinfo@${_hostPort(proxy)}${_nameFrag(proxy)}';
}

String? _trojanLink(Map<String, dynamic> proxy) {
  final password = '${proxy['password'] ?? ''}';
  if (password.isEmpty) return null;
  final params = _tlsParams(proxy);
  return 'trojan://$password@${_hostPort(proxy)}${_query(params)}${_nameFrag(proxy)}';
}

String? _hysteria2Link(Map<String, dynamic> proxy) {
  final password = '${proxy['password'] ?? ''}';
  if (password.isEmpty) return null;
  final params = _tlsParams(proxy);
  if (proxy['skip-cert-verify'] == true) params['insecure'] = '1';
  return 'hysteria2://$password@${_hostPort(proxy)}${_query(params)}${_nameFrag(proxy)}';
}
