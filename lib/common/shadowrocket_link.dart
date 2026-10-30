enum ShadowrocketLinkKind {
  connect,
  disconnect,
  toggle,
  connectivityTest,
  select,
  add,
  updateSubs,
  configAdd,
  installModule,
  route,
  color,
}

enum ShadowrocketRoute { proxy, config, direct, scene }

class ShadowrocketLinkAction {
  const ShadowrocketLinkAction({
    required this.kind,
    this.nodeName,
    this.url,
    this.route,
    this.autoClose = false,
  });

  final ShadowrocketLinkKind kind;
  final String? nodeName;
  final String? url;
  final ShadowrocketRoute? route;
  final bool autoClose;
}

const _bareActions = {
  'connect': ShadowrocketLinkKind.connect,
  'open': ShadowrocketLinkKind.connect,
  'disconnect': ShadowrocketLinkKind.disconnect,
  'close': ShadowrocketLinkKind.disconnect,
  'toggle': ShadowrocketLinkKind.toggle,
  'connectivity-test': ShadowrocketLinkKind.connectivityTest,
  'update-subs': ShadowrocketLinkKind.updateSubs,
};

bool _isHttpUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

String? _embeddedUrl(String raw) {
  final stripped = raw.split('#').first;
  if (stripped.isEmpty) return null;
  if (_isHttpUrl(stripped)) return stripped;
  final decoded = Uri.decodeFull(stripped);
  return _isHttpUrl(decoded) ? decoded : null;
}

bool? _autoClose(Map<String, String> params, Set<String> allowed) {
  if (params.keys.any((key) => !allowed.contains(key))) return null;
  final value = params['autoclose'];
  if (value == null) return false;
  if (value == 'true') return true;
  if (value == 'false') return false;
  return null;
}

ShadowrocketLinkAction? parseShadowrocketLink(Uri uri) {
  if (uri.scheme != 'shadowrocket') return null;
  final host = uri.host;
  final params = uri.queryParameters;
  final raw = uri.toString();
  final path = uri.path;
  if (_bareActions.containsKey(host)) {
    if (path != '' && path != '/') return null;
    final autoClose = _autoClose(params, {'autoclose'});
    if (autoClose == null) return null;
    return ShadowrocketLinkAction(
      kind: _bareActions[host]!,
      autoClose: autoClose,
    );
  }
  switch (host) {
    case 'select':
      if (path != '' && path != '/') return null;
      final autoClose = _autoClose(params, {'autoclose', 's'});
      if (autoClose == null) return null;
      final name = params['s'];
      if (name == null || name.trim().isEmpty) return null;
      return ShadowrocketLinkAction(
        kind: ShadowrocketLinkKind.select,
        nodeName: name,
        autoClose: autoClose,
      );
    case 'add':
      const prefix = 'shadowrocket://add/';
      if (!raw.startsWith(prefix)) return null;
      final url = _embeddedUrl(raw.substring(prefix.length));
      if (url == null) return null;
      return ShadowrocketLinkAction(kind: ShadowrocketLinkKind.add, url: url);
    case 'config':
      const prefix = 'shadowrocket://config/add/';
      if (!raw.startsWith(prefix)) return null;
      final url = _embeddedUrl(raw.substring(prefix.length));
      if (url == null) return null;
      return ShadowrocketLinkAction(
        kind: ShadowrocketLinkKind.configAdd,
        url: url,
      );
    case 'install':
      if (path != '' && path != '/') return null;
      final autoClose = _autoClose(params, {'autoclose', 'module'});
      if (autoClose == null) return null;
      final url = params['module'];
      if (url == null || !_isHttpUrl(url)) return null;
      return ShadowrocketLinkAction(
        kind: ShadowrocketLinkKind.installModule,
        url: url,
        autoClose: autoClose,
      );
    case 'route':
      final segments = uri.pathSegments;
      if (segments.length != 1) return null;
      final autoClose = _autoClose(params, {'autoclose'});
      if (autoClose == null) return null;
      final route = switch (segments.single.toLowerCase()) {
        'proxy' => ShadowrocketRoute.proxy,
        'config' => ShadowrocketRoute.config,
        'direct' => ShadowrocketRoute.direct,
        'scene' => ShadowrocketRoute.scene,
        _ => null,
      };
      if (route == null) return null;
      return ShadowrocketLinkAction(
        kind: ShadowrocketLinkKind.route,
        route: route,
        autoClose: autoClose,
      );
    case 'color':
      if (uri.query.isEmpty) return null;
      return const ShadowrocketLinkAction(kind: ShadowrocketLinkKind.color);
    default:
      return null;
  }
}
