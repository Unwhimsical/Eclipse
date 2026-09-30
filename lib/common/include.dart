import 'request.dart';
import 'shadowrocket.dart';

typedef IncludeFetcher = Future<String?> Function(String url);

const _includeMaxDepth = 5;
const _includeTimeout = Duration(seconds: 15);

ConfData mergeConfData(ConfData base, ConfData overlay) {
  return ConfData(
    proxies: [...base.proxies, ...overlay.proxies],
    proxyGroups: [...base.proxyGroups, ...overlay.proxyGroups],
    rules: [...base.rules, ...overlay.rules],
    general: {...overlay.general, ...base.general},
    hosts: {...overlay.hosts, ...base.hosts},
    urlRewrites: [...base.urlRewrites, ...overlay.urlRewrites],
    headerRewrites: [...base.headerRewrites, ...overlay.headerRewrites],
    mapLocal: [...base.mapLocal, ...overlay.mapLocal],
    bodyRewrites: [...base.bodyRewrites, ...overlay.bodyRewrites],
    mitm: {...overlay.mitm, ...base.mitm},
  );
}

Future<String?> _fetchIncludeText(String url) async {
  try {
    final response = await request
        .getTextResponseForUrl(url)
        .timeout(_includeTimeout);
    final text = response.data;
    return (text == null || text.isEmpty) ? null : text;
  } catch (_) {
    return null;
  }
}

/// Follow `[General] include=` chains, merging fetched configs into [conf].
/// Local keys win; failures are fail-open; cycles stop via visited URLs.
Future<ConfData> resolveConfIncludes(
  ConfData conf, {
  IncludeFetcher? fetcher,
  int maxDepth = _includeMaxDepth,
}) async {
  var nextUrl = conf.includeUrl;
  if (nextUrl == null) return conf;
  final fetch = fetcher ?? _fetchIncludeText;
  final visited = <String>{};
  var merged = conf;
  var depth = 0;
  while (nextUrl != null && depth < maxDepth) {
    final url = nextUrl.trim();
    if (url.isEmpty || !visited.add(url)) break;
    final text = await fetch(url);
    if (text == null || text.isEmpty) break;
    final remote = parseConf(text);
    merged = mergeConfData(merged, remote);
    nextUrl = remote.includeUrl;
    depth++;
  }
  return merged;
}
