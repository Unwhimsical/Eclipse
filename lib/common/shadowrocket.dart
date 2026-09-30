import 'dart:convert';

import 'yaml.dart';

/// Hoisted: the section/rule parsers below run once per line, so building
/// these per call costs over a million RegExp compilations on a 10MB module.
final _sectionHeaderPattern = RegExp(r'^\[(.+)\]$');
final _mitmHostSeparator = RegExp(r'[,\s]+');
final _updateIntervalParam = RegExp(
  r',update-interval=\d+',
  caseSensitive: false,
);
final _protocolWord = RegExp(
  r'(?<![A-Z-])PROTOCOL(?![A-Z-])',
  caseSensitive: false,
);
final _destPortWord = RegExp(
  r'(?<![A-Z-])DEST-PORT(?![A-Z-])',
  caseSensitive: false,
);
final _rejectNoDropWord = RegExp(
  r'(?<![A-Z-])REJECT-NO-DROP(?![A-Z-])',
  caseSensitive: false,
);
final _granularRejectWord = RegExp(
  r'(?<![A-Z-])REJECT-(DICT|ARRAY|200|IMG|TINYGIF|VIDEO)(?![A-Z-])',
  caseSensitive: false,
);
final _headerRewriteLinePattern = RegExp(
  r'^(\S+)\s+(header-del|header-add|header-replace|header-replace-regex)\s+(.+)$',
);
final _quotedArgPattern = RegExp(r'"([^"]*)"');
final _bodyRewriteLinePattern = RegExp(r'^(\S+)\s+(\S+)\s+(.+)$');
final _bodyRewriteExprPattern = RegExp(r'^(\S+)\s+(.+)$');

/// Parsers for Shadowrocket formats: share links, `.conf` sections and
/// `.sgmodule` files. Everything converts to Clash-compatible maps so the
/// existing profile pipeline can consume them without core changes.

/// Parse a single share link (`ss://`, `vmess://`, ...) into a Clash proxy
/// map. Returns null when the link is not recognized or malformed.
Map<String, dynamic>? parseShareLink(String link) {
  final text = link.trim();
  if (text.isEmpty) return null;
  final schemeEnd = text.indexOf('://');
  if (schemeEnd < 0) return null;
  final scheme = text.substring(0, schemeEnd).toLowerCase();
  final body = text.substring(schemeEnd + 3);
  try {
    return switch (scheme) {
      'ss' => _parseSs(body),
      'ssr' => _parseSsr(body),
      'vmess' => _parseVmess(body),
      'vless' => _parseVless(body),
      'trojan' => _parseTrojan(body),
      'hysteria2' || 'hy2' => _parseHysteria2(body),
      'tuic' => _parseTuic(body),
      _ => null,
    };
  } catch (_) {
    return null;
  }
}

/// Split a share-link body into main part, query params and fragment name.
(String, Map<String, String>, String) _splitLink(String body) {
  var rest = body;
  var name = '';
  final hashIndex = rest.indexOf('#');
  if (hashIndex >= 0) {
    name = Uri.decodeComponent(rest.substring(hashIndex + 1)).trim();
    rest = rest.substring(0, hashIndex);
  }
  final params = <String, String>{};
  final queryIndex = rest.indexOf('?');
  if (queryIndex >= 0) {
    params.addAll(Uri.splitQueryString(rest.substring(queryIndex + 1)));
    rest = rest.substring(0, queryIndex);
  }
  return (rest, params, name);
}

String _decodeBase64(String input) {
  var normalized = input.trim().replaceAll('-', '+').replaceAll('_', '/');
  final mod = normalized.length % 4;
  if (mod != 0) normalized += '=' * (4 - mod);
  return utf8.decode(base64.decode(normalized));
}

String _decodeBase64OrSelf(String input) {
  try {
    return _decodeBase64(input);
  } catch (_) {
    return input;
  }
}

int _parsePort(String value, [int fallback = 0]) {
  return int.tryParse(value.trim()) ?? fallback;
}

/// Parse a `host:port` pair, tolerating IPv6 literals.
(String, int) _splitHostPort(String text, [int fallbackPort = 0]) {
  final value = text.trim();
  if (value.startsWith('[')) {
    final end = value.indexOf(']');
    if (end > 0) {
      final host = value.substring(1, end);
      final rest = value.substring(end + 1);
      final port = rest.startsWith(':')
          ? _parsePort(rest.substring(1), fallbackPort)
          : fallbackPort;
      return (host, port);
    }
  }
  final lastColon = value.lastIndexOf(':');
  if (lastColon > 0 && value.indexOf(':') == lastColon) {
    return (
      value.substring(0, lastColon),
      _parsePort(value.substring(lastColon + 1), fallbackPort),
    );
  }
  return (value, fallbackPort);
}

Map<String, dynamic>? _parseSs(String body) {
  final (rest, params, name) = _splitLink(body);
  String method;
  String password;
  String host;
  int port;
  if (rest.contains('@')) {
    final atIndex = rest.lastIndexOf('@');
    final userInfo = _decodeBase64OrSelf(rest.substring(0, atIndex));
    final hostPort = rest.substring(atIndex + 1);
    final colonIndex = userInfo.indexOf(':');
    if (colonIndex < 0) return null;
    method = userInfo.substring(0, colonIndex);
    password = userInfo.substring(colonIndex + 1);
    final (h, p) = _splitHostPort(hostPort);
    host = h;
    port = p;
  } else {
    final decoded = _decodeBase64(rest);
    final atIndex = decoded.lastIndexOf('@');
    if (atIndex < 0) return null;
    final userInfo = decoded.substring(0, atIndex);
    final colonIndex = userInfo.indexOf(':');
    if (colonIndex < 0) return null;
    method = userInfo.substring(0, colonIndex);
    password = userInfo.substring(colonIndex + 1);
    final (h, p) = _splitHostPort(decoded.substring(atIndex + 1));
    host = h;
    port = p;
  }
  if (host.isEmpty || port <= 0) return null;
  return {
    'name': name.isEmpty ? '$host:$port' : name,
    'type': 'ss',
    'server': host,
    'port': port,
    'cipher': method,
    'password': password,
    if (params['plugin']?.isNotEmpty == true) 'plugin': params['plugin'],
    if (params['plugin-opts']?.isNotEmpty == true)
      'plugin-opts': params['plugin-opts'],
  };
}

Map<String, dynamic>? _parseSsr(String body) {
  final decoded = _decodeBase64(body.split('#').first.split('?').first);
  final querySplit = decoded.split('/?');
  final main = querySplit[0];
  final parts = main.split(':');
  if (parts.length < 6) return null;
  final host = parts[0];
  final port = _parsePort(parts[1]);
  final protocol = parts[2];
  final method = parts[3];
  final obfs = parts[4];
  final password = _decodeBase64OrSelf(parts.sublist(5).join(':'));
  final params = <String, String>{};
  var name = '$host:$port';
  if (querySplit.length > 1) {
    for (final pair in querySplit[1].split('&')) {
      final eq = pair.indexOf('=');
      if (eq < 0) continue;
      final key = pair.substring(0, eq);
      final value = _decodeBase64OrSelf(pair.substring(eq + 1));
      if (key == 'remarks' && value.isNotEmpty) {
        name = value;
      } else {
        params[key] = value;
      }
    }
  }
  if (host.isEmpty || port <= 0) return null;
  return {
    'name': name,
    'type': 'ssr',
    'server': host,
    'port': port,
    'cipher': method,
    'password': password,
    'protocol': protocol,
    'obfs': obfs,
    if (params['obfsparam']?.isNotEmpty == true)
      'obfs-param': params['obfsparam'],
    if (params['protoparam']?.isNotEmpty == true)
      'protocol-param': params['protoparam'],
  };
}

Map<String, dynamic>? _parseVmess(String body) {
  final decoded = _decodeBase64(body.split('#').first.trim());
  final json = jsonDecode(decoded);
  if (json is! Map) return null;
  final host = '${json['add'] ?? ''}'.trim();
  final port = _parsePort('${json['port'] ?? ''}');
  if (host.isEmpty || port <= 0) return null;
  final net = '${json['net'] ?? 'tcp'}'.toLowerCase();
  final tls = '${json['tls'] ?? ''}'.toLowerCase() == 'tls';
  final result = <String, dynamic>{
    'name': '${json['ps'] ?? '$host:$port'}'.trim(),
    'type': 'vmess',
    'server': host,
    'port': port,
    'uuid': '${json['id'] ?? ''}',
    'alterId': int.tryParse('${json['aid'] ?? '0'}') ?? 0,
    'cipher': 'auto',
    'udp': true,
    'tls': tls,
    'network': net,
  };
  if (tls) {
    final sni = '${json['sni'] ?? json['host'] ?? ''}'.trim();
    result['servername'] = sni.isEmpty ? host : sni;
  }
  if (net == 'ws') {
    result['ws-opts'] = {
      'path': '${json['path'] ?? '/'}',
      'headers': {
        if ('${json['host'] ?? ''}'.isNotEmpty) 'Host': '${json['host']}',
      },
    };
  } else if (net == 'h2') {
    result['h2-opts'] = {
      'host': ['${json['host'] ?? host}'],
      'path': '${json['path'] ?? '/'}',
    };
  } else if (net == 'grpc') {
    result['grpc-opts'] = {'grpc-service-name': '${json['path'] ?? ''}'};
  }
  return result;
}

Map<String, dynamic>? _parseVless(String body) {
  final (rest, params, name) = _splitLink(body);
  final atIndex = rest.lastIndexOf('@');
  if (atIndex < 0) return null;
  final uuid = rest.substring(0, atIndex);
  final (host, port) = _splitHostPort(rest.substring(atIndex + 1));
  if (host.isEmpty || port <= 0 || uuid.isEmpty) return null;
  final security = (params['security'] ?? 'none').toLowerCase();
  final net = (params['type'] ?? 'tcp').toLowerCase();
  final result = <String, dynamic>{
    'name': name.isEmpty ? '$host:$port' : name,
    'type': 'vless',
    'server': host,
    'port': port,
    'uuid': uuid,
    'udp': true,
    'tls': security == 'tls',
    'network': net,
  };
  if (security == 'tls') {
    result['servername'] = params['sni'] ?? host;
    if (params['fp']?.isNotEmpty == true) {
      result['client-fingerprint'] = params['fp'];
    }
    if (params['alpn']?.isNotEmpty == true) {
      result['alpn'] = params['alpn']!.split(',');
    }
  } else if (security == 'reality') {
    result['tls'] = true;
    result['servername'] = params['sni'] ?? host;
    result['reality-opts'] = {
      'public-key': params['pbk'] ?? '',
      'short-id': params['sid'] ?? '',
    };
    if (params['fp']?.isNotEmpty == true) {
      result['client-fingerprint'] = params['fp'];
    }
  }
  if (params['flow']?.isNotEmpty == true) {
    result['flow'] = params['flow'];
  }
  if (net == 'ws') {
    result['ws-opts'] = {
      'path': params['path'] ?? '/',
      'headers': {
        if (params['host']?.isNotEmpty == true) 'Host': params['host'],
      },
    };
  } else if (net == 'grpc') {
    result['grpc-opts'] = {'grpc-service-name': params['serviceName'] ?? ''};
  }
  return result;
}

Map<String, dynamic>? _parseTrojan(String body) {
  final (rest, params, name) = _splitLink(body);
  final atIndex = rest.lastIndexOf('@');
  if (atIndex < 0) return null;
  final password = rest.substring(0, atIndex);
  final (host, port) = _splitHostPort(rest.substring(atIndex + 1));
  if (host.isEmpty || port <= 0 || password.isEmpty) return null;
  return {
    'name': name.isEmpty ? '$host:$port' : name,
    'type': 'trojan',
    'server': host,
    'port': port,
    'password': password,
    'udp': true,
    'sni': params['sni'] ?? host,
    if (params['alpn']?.isNotEmpty == true) 'alpn': params['alpn']!.split(','),
  };
}

Map<String, dynamic>? _parseHysteria2(String body) {
  final (rest, params, name) = _splitLink(body);
  final atIndex = rest.lastIndexOf('@');
  if (atIndex < 0) return null;
  final password = rest.substring(0, atIndex);
  final (host, port) = _splitHostPort(rest.substring(atIndex + 1));
  if (host.isEmpty || port <= 0) return null;
  return {
    'name': name.isEmpty ? '$host:$port' : name,
    'type': 'hysteria2',
    'server': host,
    'port': port,
    'password': password.isEmpty ? params['password'] ?? '' : password,
    'sni': params['sni'] ?? host,
    if (params['insecure'] == '1') 'skip-cert-verify': true,
  };
}

Map<String, dynamic>? _parseTuic(String body) {
  final (rest, params, name) = _splitLink(body);
  final atIndex = rest.lastIndexOf('@');
  if (atIndex < 0) return null;
  final userInfo = rest.substring(0, atIndex).split(':');
  final (host, port) = _splitHostPort(rest.substring(atIndex + 1));
  if (host.isEmpty || port <= 0 || userInfo.isEmpty) return null;
  return {
    'name': name.isEmpty ? '$host:$port' : name,
    'type': 'tuic',
    'server': host,
    'port': port,
    'uuid': userInfo[0],
    'password': userInfo.length > 1 ? userInfo[1] : '',
    'sni': params['sni'] ?? host,
    if (params['alpn']?.isNotEmpty == true) 'alpn': params['alpn']!.split(','),
  };
}

/// A parsed Shadowrocket `.conf` file.
class ConfData {
  final List<Map<String, dynamic>> proxies;
  final List<Map<String, dynamic>> proxyGroups;
  final List<String> rules;
  final Map<String, String> general;
  final Map<String, String> hosts;
  final List<String> urlRewrites;
  final List<String> headerRewrites;
  final List<String> mapLocal;
  final List<String> bodyRewrites;
  final Map<String, String> mitm;

  const ConfData({
    this.proxies = const [],
    this.proxyGroups = const [],
    this.rules = const [],
    this.general = const {},
    this.hosts = const {},
    this.urlRewrites = const [],
    this.headerRewrites = const [],
    this.mapLocal = const [],
    this.bodyRewrites = const [],
    this.mitm = const {},
  });

  bool get isEmpty =>
      proxies.isEmpty &&
      proxyGroups.isEmpty &&
      rules.isEmpty &&
      general.isEmpty &&
      hosts.isEmpty &&
      urlRewrites.isEmpty &&
      headerRewrites.isEmpty &&
      mapLocal.isEmpty &&
      bodyRewrites.isEmpty &&
      mitm.isEmpty;

  /// DNS servers from `[General]` `dns-server` / `fallback-dns-server`.
  List<String> get dnsServers {
    final servers = <String>[];
    for (final key in ['dns-server', 'fallback-dns-server']) {
      final value = general[key];
      if (value == null || value.isEmpty) continue;
      servers.addAll(
        value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
      );
    }
    return servers;
  }

  /// Direct DNS servers from `[General]` `direct-dns-server`.
  /// Used for domains that should resolve without proxy.
  List<String> get directDnsServers {
    final value = general['direct-dns-server'];
    if (value == null || value.isEmpty) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Domains/IPs from `[General]` `skip-proxy` that bypass the proxy.
  List<String> get skipProxy {
    final value = general['skip-proxy'];
    if (value == null || value.isEmpty) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Routes from `[General]` `tun-excluded-routes` (CIDR list).
  List<String> get tunExcludedRoutes {
    final value = general['tun-excluded-routes'];
    if (value == null || value.isEmpty) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Routes from `[General]` `tun-included-routes` (CIDR list).
  List<String> get tunIncludedRoutes {
    final value = general['tun-included-routes'];
    if (value == null || value.isEmpty) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Whether IPv6 is enabled (`[General]` `ipv6`).
  bool get ipv6Enabled {
    final value = general['ipv6']?.toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Whether to prefer IPv6 (`[General]` `prefer-ipv6`).
  bool get preferIpv6 {
    final value = general['prefer-ipv6']?.toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Whether to allow private IP answers (`[General]` `private-ip-answer`).
  bool get privateIpAnswer {
    final value = general['private-ip-answer']?.toLowerCase();
    // Default true in Shadowrocket; only false if explicitly disabled.
    return value != 'false' && value != '0' && value != 'no';
  }

  /// Whether to always use real IP (`[General]` `always-real-ip`).
  bool get alwaysRealIp {
    final value = general['always-real-ip']?.toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// URL from `[General]` `include` for an included remote config.
  String? get includeUrl {
    final value = general['include']?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }
}

/// Parse a Shadowrocket `.conf` text into proxies / proxy-groups / rules.
ConfData parseConf(String content) {
  final proxies = <Map<String, dynamic>>[];
  final proxyGroups = <Map<String, dynamic>>[];
  final rules = <String>[];
  final general = <String, String>{};
  final hosts = <String, String>{};
  final urlRewrites = <String>[];
  final headerRewrites = <String>[];
  final mapLocal = <String>[];
  final bodyRewrites = <String>[];
  final mitm = <String, String>{};
  var section = '';
  for (final rawLine in const LineSplitter().convert(content)) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#') || line.startsWith(';')) {
      continue;
    }
    final sectionMatch = _sectionHeaderPattern.firstMatch(line);
    if (sectionMatch != null) {
      section = sectionMatch.group(1)!.trim().toLowerCase();
      continue;
    }
    switch (section) {
      case 'general':
        final eq = line.indexOf('=');
        if (eq > 0) {
          general[line.substring(0, eq).trim().toLowerCase()] = line
              .substring(eq + 1)
              .trim();
        }
      case 'proxy':
        final proxy = _parseConfProxyLine(line);
        if (proxy != null) proxies.add(proxy);
      case 'proxy group':
        final group = _parseConfProxyGroupLine(line);
        if (group != null) proxyGroups.add(group);
      case 'rule':
        final rule = _normalizeConfRule(line);
        if (rule != null) rules.add(rule);
      case 'host':
        final eq = line.indexOf('=');
        if (eq > 0) {
          hosts[line.substring(0, eq).trim()] = line.substring(eq + 1).trim();
        }
      case 'url rewrite':
        urlRewrites.add(line);
      case 'header rewrite':
        headerRewrites.add(line);
      case 'map local':
        mapLocal.add(line);
      case 'body rewrite':
        bodyRewrites.add(line);
      case 'mitm':
        final eq = line.indexOf('=');
        if (eq > 0) {
          mitm[line.substring(0, eq).trim().toLowerCase()] = line
              .substring(eq + 1)
              .trim();
        }
    }
  }
  return ConfData(
    proxies: proxies,
    proxyGroups: proxyGroups,
    rules: rules,
    general: general,
    hosts: hosts,
    urlRewrites: urlRewrites,
    headerRewrites: headerRewrites,
    mapLocal: mapLocal,
    bodyRewrites: bodyRewrites,
    mitm: mitm,
  );
}

/// Parse one `[Proxy]` line: `Name = ss, host, port, cipher, password, ...`.
Map<String, dynamic>? _parseConfProxyLine(String line) {
  final eq = line.indexOf('=');
  if (eq < 0) return null;
  final name = line.substring(0, eq).trim();
  final parts = line.substring(eq + 1).split(',').map((e) => e.trim()).toList();
  if (parts.isEmpty || name.isEmpty) return null;
  final type = parts[0].toLowerCase();
  try {
    return switch (type) {
      'ss' || 'shadowsocks' => _confSs(name, parts),
      'ssr' || 'shadowsocksr' => _confSsr(name, parts),
      'vmess' => _confVmess(name, parts),
      'vless' => _confVless(name, parts),
      'trojan' => _confTrojan(name, parts),
      'hysteria2' || 'hy2' => _confHysteria2(name, parts),
      'tuic' => _confTuic(name, parts),
      'http' => _confHttp(name, parts),
      'socks5' => _confSocks(name, parts),
      _ => null,
    };
  } catch (_) {
    return null;
  }
}

String _part(List<String> parts, int index, [String fallback = '']) {
  return index < parts.length ? parts[index] : fallback;
}

Map<String, dynamic> _confSs(String name, List<String> parts) {
  return {
    'name': name,
    'type': 'ss',
    'server': _part(parts, 1),
    'port': _parsePort(_part(parts, 2)),
    'cipher': _part(parts, 3),
    'password': _part(parts, 4),
    'udp': true,
  };
}

Map<String, dynamic> _confSsr(String name, List<String> parts) {
  return {
    'name': name,
    'type': 'ssr',
    'server': _part(parts, 1),
    'port': _parsePort(_part(parts, 2)),
    'cipher': _part(parts, 3),
    'password': _part(parts, 4),
    'protocol': _part(parts, 5, 'origin'),
    'obfs': _part(parts, 6, 'plain'),
  };
}

Map<String, dynamic> _confVmess(String name, List<String> parts) {
  // vmess, host, port, uuid, ws/h2/grpc, path, tls, sni/host, ...
  final net = _part(parts, 4, 'tcp').toLowerCase();
  final tlsValue = _part(parts, 6).toLowerCase();
  final tls = tlsValue == 'tls' || tlsValue == 'over-tls=true';
  final result = <String, dynamic>{
    'name': name,
    'type': 'vmess',
    'server': _part(parts, 1),
    'port': _parsePort(_part(parts, 2)),
    'uuid': _part(parts, 3),
    'alterId': 0,
    'cipher': 'auto',
    'udp': true,
    'tls': tls,
    'network': net == 'ws' || net == 'h2' || net == 'grpc' ? net : 'tcp',
  };
  if (tls) {
    final sni = _part(parts, 7);
    result['servername'] = sni.isEmpty ? _part(parts, 1) : sni;
  }
  if (net == 'ws') {
    result['ws-opts'] = {
      'path': _part(parts, 5, '/'),
      'headers': {if (_part(parts, 7).isNotEmpty) 'Host': _part(parts, 7)},
    };
  } else if (net == 'grpc') {
    result['grpc-opts'] = {'grpc-service-name': _part(parts, 5)};
  }
  return result;
}

Map<String, dynamic> _confVless(String name, List<String> parts) {
  final net = _part(parts, 4, 'tcp').toLowerCase();
  final tlsValue = _part(parts, 6).toLowerCase();
  final tls = tlsValue == 'tls' || tlsValue == 'xtls';
  final result = <String, dynamic>{
    'name': name,
    'type': 'vless',
    'server': _part(parts, 1),
    'port': _parsePort(_part(parts, 2)),
    'uuid': _part(parts, 3),
    'udp': true,
    'tls': tls,
    'network': net == 'ws' || net == 'grpc' ? net : 'tcp',
  };
  if (tls) {
    final sni = _part(parts, 7);
    result['servername'] = sni.isEmpty ? _part(parts, 1) : sni;
  }
  if (net == 'ws') {
    result['ws-opts'] = {
      'path': _part(parts, 5, '/'),
      'headers': {if (_part(parts, 7).isNotEmpty) 'Host': _part(parts, 7)},
    };
  }
  if (tlsValue == 'xtls' && _part(parts, 8).isNotEmpty) {
    result['flow'] = _part(parts, 8);
  }
  return result;
}

Map<String, dynamic> _confTrojan(String name, List<String> parts) {
  return {
    'name': name,
    'type': 'trojan',
    'server': _part(parts, 1),
    'port': _parsePort(_part(parts, 2)),
    'password': _part(parts, 3),
    'udp': true,
    'sni': _part(parts, 4).isEmpty ? _part(parts, 1) : _part(parts, 4),
  };
}

Map<String, dynamic> _confHysteria2(String name, List<String> parts) {
  return {
    'name': name,
    'type': 'hysteria2',
    'server': _part(parts, 1),
    'port': _parsePort(_part(parts, 2)),
    'password': _part(parts, 3),
    'sni': _part(parts, 4).isEmpty ? _part(parts, 1) : _part(parts, 4),
  };
}

Map<String, dynamic> _confTuic(String name, List<String> parts) {
  return {
    'name': name,
    'type': 'tuic',
    'server': _part(parts, 1),
    'port': _parsePort(_part(parts, 2)),
    'uuid': _part(parts, 3),
    'password': _part(parts, 4),
    'sni': _part(parts, 5).isEmpty ? _part(parts, 1) : _part(parts, 5),
  };
}

Map<String, dynamic> _confHttp(String name, List<String> parts) {
  return {
    'name': name,
    'type': 'http',
    'server': _part(parts, 1),
    'port': _parsePort(_part(parts, 2)),
    if (_part(parts, 3).isNotEmpty) 'username': _part(parts, 3),
    if (_part(parts, 4).isNotEmpty) 'password': _part(parts, 4),
    'tls': _part(parts, 5).toLowerCase() == 'tls',
  };
}

Map<String, dynamic> _confSocks(String name, List<String> parts) {
  return {
    'name': name,
    'type': 'socks5',
    'server': _part(parts, 1),
    'port': _parsePort(_part(parts, 2)),
    if (_part(parts, 3).isNotEmpty) 'username': _part(parts, 3),
    if (_part(parts, 4).isNotEmpty) 'password': _part(parts, 4),
    'udp': true,
  };
}

/// Parse one `[Proxy Group]` line: `Name = select, p1, p2, ...`.
Map<String, dynamic>? _parseConfProxyGroupLine(String line) {
  final eq = line.indexOf('=');
  if (eq < 0) return null;
  final name = line.substring(0, eq).trim();
  final parts = line.substring(eq + 1).split(',').map((e) => e.trim()).toList();
  if (parts.isEmpty || name.isEmpty) return null;
  final type = parts[0].toLowerCase();
  final proxies = parts.sublist(1).where((e) => e.isNotEmpty).toList();
  final clashType = switch (type) {
    'select' => 'select',
    'url-test' || 'urltest' => 'url-test',
    'fallback' => 'fallback',
    'load-balance' || 'loadbalance' => 'load-balance',
    _ => null,
  };
  if (clashType == null) return null;
  return {
    'name': name,
    'type': clashType,
    'proxies': proxies,
    if (clashType == 'url-test' || clashType == 'fallback')
      'url': 'http://www.gstatic.com/generate_204',
    if (clashType == 'url-test' || clashType == 'fallback') 'interval': 300,
  };
}

/// Normalize one `[Rule]` line to Clash format.
String? _normalizeConfRule(String line) {
  final upper = line.toUpperCase();
  if (upper.startsWith('FINAL,')) {
    return 'MATCH,${line.substring(6).trim()}';
  }
  if (upper.startsWith('USER-AGENT,')) {
    // Clash has no USER-AGENT rule type. Preserve as a YAML comment so
    // the user sees it was skipped, instead of dropping silently.
    return '# USER-AGENT not supported by Clash: $line';
  }
  var normalized = line;
  // Shadowrocket RULE-SET may carry `,update-interval=<seconds>`; Clash
  // RULE-SET has no such parameter — strip it.
  // e.g. `RULE-SET,https://x.com/a.txt,PROXY,update-interval=86400`
  //   -> `RULE-SET,https://x.com/a.txt,PROXY`
  normalized = normalized.replaceAll(_updateIntervalParam, '');
  // Shadowrocket `PROTOCOL,UDP` -> Clash Meta `NETWORK,UDP`.
  normalized = normalized.replaceAll(_protocolWord, 'NETWORK');
  // Shadowrocket `DEST-PORT` -> Clash `DST-PORT`.
  normalized = normalized.replaceAll(_destPortWord, 'DST-PORT');
  // Shadowrocket `REJECT-NO-DROP` behaves like Clash `REJECT` (TCP RST,
  // not silent drop).
  normalized = normalized.replaceAll(_rejectNoDropWord, 'REJECT');
  // Shadowrocket granular reject actions have no Clash equivalent and would
  // fail config parsing as unknown proxies — fall back to plain `REJECT`
  // (still blocks the traffic). `REJECT-DROP` is intentionally kept:
  // Clash Meta implements it natively as silent drop.
  normalized = normalized.replaceAll(_granularRejectWord, 'REJECT');
  return normalized;
}

/// A module parameter from `#!arguments=key:default,...`. The user-filled
/// value survives module updates, falling back to [defaultValue].
class ModuleArgument {
  final String key;
  final String defaultValue;

  const ModuleArgument({required this.key, this.defaultValue = ''});
}

/// Granular reject action captured at parse time, before [_normalizeConfRule] flattens the rule to plain `REJECT` for Mihomo.
class GranularRejectRule {
  final String hostPattern;
  final String kind;
  final int status;

  const GranularRejectRule({
    required this.hostPattern,
    required this.kind,
    required this.status,
  });

  Map<String, Object> toJson() => {
    'host': hostPattern,
    'kind': kind,
    'status': status,
  };
}

GranularRejectRule? parseGranularRejectLine(String rawLine) {
  final line = rawLine.trim();
  if (line.isEmpty ||
      line.startsWith('#') ||
      line.startsWith(';') ||
      line.startsWith('%')) {
    return null;
  }
  final parts = line.split(',');
  if (parts.length < 3) return null;
  final type = parts[0].trim().toUpperCase();
  final value = parts[1].trim();
  final action = parts[2].trim().toUpperCase();
  const kinds = {
    'REJECT-DICT': ('reject-json', 200),
    'REJECT-ARRAY': ('reject-array', 200),
    'REJECT-200': ('reject', 200),
    'REJECT-IMG': ('reject-img', 200),
    'REJECT-TINYGIF': ('reject-img', 200),
    'REJECT-VIDEO': ('reject-video', 200),
  };
  final kind = kinds[action];
  if (kind == null || value.isEmpty) return null;
  final hostPattern = switch (type) {
    'DOMAIN' => value.toLowerCase(),
    'DOMAIN-SUFFIX' => '*.${value.toLowerCase()}',
    'DOMAIN-KEYWORD' => '*${value.toLowerCase()}*',
    _ => null,
  };
  if (hostPattern == null) return null;
  return GranularRejectRule(
    hostPattern: hostPattern,
    kind: kind.$1,
    status: kind.$2,
  );
}

/// A `USER-AGENT,<pattern>,<policy>` rule; REJECT-family policies only.
/// Go maps the policy and converts the glob to a regex.
class UARejectRule {
  final String pattern;
  final String policy;

  const UARejectRule({required this.pattern, required this.policy});

  Map<String, Object> toJson() => {'pattern': pattern, 'policy': policy};
}

UARejectRule? parseUARejectLine(String rawLine) {
  final line = rawLine.trim();
  if (line.isEmpty ||
      line.startsWith('#') ||
      line.startsWith(';') ||
      line.startsWith('%')) {
    return null;
  }
  final parts = line.split(',');
  if (parts.length < 3) return null;
  if (parts[0].trim().toUpperCase() != 'USER-AGENT') return null;
  final pattern = parts[1].trim();
  final policy = parts[2].trim().toUpperCase();
  const rejectPolicies = {
    'REJECT',
    '-',
    'REJECT-NODROP',
    'REJECT-NO-DROP',
    'REJECT-200',
    'REJECT-DICT',
    'REJECT-JSON',
    'REJECT-ARRAY',
    'REJECT-IMG',
    'REJECT-TINYGIF',
    'REJECT-VIDEO',
  };
  if (!rejectPolicies.contains(policy) || pattern.isEmpty) return null;
  return UARejectRule(pattern: pattern, policy: policy);
}

/// A parsed `.sgmodule` file.
class Sgmodule {
  final String name;
  final String desc;
  final String? author;
  final List<String> rules;
  final Map<String, String> hosts;
  final List<String> urlRewrites;
  final List<String> headerRewrites;
  final List<String> mapLocal;
  final List<String> bodyRewrites;
  final List<String> scripts;
  final List<String> mitmHostnames;
  final String raw;

  /// `%APPEND%` in `[Rule]`: append rules instead of replacing config rules.
  final bool rulesAppend;

  final List<ModuleArgument> arguments;
  final Map<String, String> argumentDescriptions;

  final List<GranularRejectRule> granularRejects;

  final List<UARejectRule> uaRejects;

  const Sgmodule({
    this.name = '',
    this.desc = '',
    this.author,
    this.rules = const [],
    this.hosts = const {},
    this.urlRewrites = const [],
    this.headerRewrites = const [],
    this.mapLocal = const [],
    this.bodyRewrites = const [],
    this.scripts = const [],
    this.mitmHostnames = const [],
    this.raw = '',
    this.rulesAppend = false,
    this.arguments = const [],
    this.argumentDescriptions = const {},
    this.granularRejects = const [],
    this.uaRejects = const [],
  });

  bool get isEmpty =>
      rules.isEmpty &&
      hosts.isEmpty &&
      urlRewrites.isEmpty &&
      headerRewrites.isEmpty &&
      mapLocal.isEmpty &&
      bodyRewrites.isEmpty &&
      scripts.isEmpty;

  bool get needsMitm =>
      urlRewrites.isNotEmpty ||
      headerRewrites.isNotEmpty ||
      mapLocal.isNotEmpty ||
      bodyRewrites.isNotEmpty ||
      scripts.isNotEmpty ||
      granularRejects.isNotEmpty ||
      uaRejects.isNotEmpty;
}

/// Parse a `.sgmodule` text.
Sgmodule parseSgmodule(String content) {
  var name = '';
  var desc = '';
  String? author;
  final rules = <String>[];
  final hosts = <String, String>{};
  final urlRewrites = <String>[];
  final headerRewrites = <String>[];
  final mapLocal = <String>[];
  final bodyRewrites = <String>[];
  final scripts = <String>[];
  final mitmHostnames = <String>[];
  final granularRejects = <GranularRejectRule>[];
  final uaRejects = <UARejectRule>[];
  var rulesAppend = false;
  var moduleArguments = const <ModuleArgument>[];
  var argumentsDescRaw = '';
  var section = '';
  for (final rawLine in const LineSplitter().convert(content)) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    if (line.startsWith('#!')) {
      final meta = line.substring(2);
      final eq = meta.indexOf('=');
      if (eq > 0) {
        final key = meta.substring(0, eq).trim().toLowerCase();
        final value = meta.substring(eq + 1).trim();
        switch (key) {
          case 'name':
            name = value;
          case 'desc':
            desc = value;
          case 'author':
            author = value;
          case 'arguments':
            moduleArguments = parseModuleArguments(value);
          case 'arguments-desc':
            argumentsDescRaw = value;
        }
      }
      continue;
    }
    if (line.startsWith('#') || line.startsWith(';')) continue;
    final sectionMatch = _sectionHeaderPattern.firstMatch(line);
    if (sectionMatch != null) {
      section = sectionMatch.group(1)!.trim().toLowerCase();
      continue;
    }
    switch (section) {
      case 'rule':
        if (line.startsWith('%')) {
          if (line.toUpperCase() == '%APPEND%') rulesAppend = true;
        } else {
          final granular = parseGranularRejectLine(line);
          if (granular != null) granularRejects.add(granular);
          final uaReject = parseUARejectLine(line);
          if (uaReject != null) uaRejects.add(uaReject);
          final rule = _normalizeConfRule(line);
          if (rule != null) rules.add(rule);
        }
      case 'host':
        final eq = line.indexOf('=');
        if (eq > 0) {
          hosts[line.substring(0, eq).trim()] = line.substring(eq + 1).trim();
        }
      case 'url rewrite':
        urlRewrites.add(line);
      case 'header rewrite':
        headerRewrites.add(line);
      case 'map local':
        mapLocal.add(line);
      case 'body rewrite':
        bodyRewrites.add(line);
      case 'script':
        scripts.add(line);
      case 'mitm':
        final eq = line.indexOf('=');
        final value = eq > 0 ? line.substring(eq + 1) : line;
        for (final host in value.split(_mitmHostSeparator)) {
          final h = host.trim();
          if (h.isEmpty || h.startsWith('%')) continue;
          mitmHostnames.add(h);
        }
    }
  }
  return Sgmodule(
    name: name,
    desc: desc,
    author: author,
    rules: rules,
    hosts: hosts,
    urlRewrites: urlRewrites,
    headerRewrites: headerRewrites,
    mapLocal: mapLocal,
    bodyRewrites: bodyRewrites,
    scripts: scripts,
    mitmHostnames: mitmHostnames,
    rulesAppend: rulesAppend,
    granularRejects: granularRejects,
    uaRejects: uaRejects,
    arguments: moduleArguments,
    argumentDescriptions: parseModuleArgumentDescriptions(
      argumentsDescRaw,
      moduleArguments,
    ),
    raw: content,
  );
}

/// Splits each pair on the first colon only, so values like URLs survive.
List<ModuleArgument> parseModuleArguments(String value) {
  final args = <ModuleArgument>[];
  for (final part in value.split(',')) {
    final item = part.trim();
    if (item.isEmpty) continue;
    final colon = item.indexOf(':');
    if (colon < 0) {
      args.add(ModuleArgument(key: item));
      continue;
    }
    final key = item.substring(0, colon).trim();
    if (key.isEmpty) continue;
    args.add(
      ModuleArgument(key: key, defaultValue: item.substring(colon + 1).trim()),
    );
  }
  return args;
}

Map<String, String> parseModuleArgumentDescriptions(
  String value,
  List<ModuleArgument> declared,
) {
  if (value.isEmpty || declared.isEmpty) return const {};
  final keys = declared.map((e) => e.key).toSet();
  final descs = <String, String>{};
  String? current;
  for (final rawLine in value.replaceAll(r'\n', '\n').split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      current = null;
      continue;
    }
    var matched = false;
    for (final key in keys) {
      for (final sep in [':', '：']) {
        if (line.startsWith('$key$sep')) {
          descs[key] = line.substring(key.length + sep.length).trim();
          current = key;
          matched = true;
          break;
        }
      }
      if (matched) break;
    }
    if (!matched && current != null) {
      descs[current] = '${descs[current]}\n$line';
    }
  }
  return descs;
}

final _argumentPlaceholder = RegExp(r'\{\{\{\s*([^{}]+?)\s*\}\}\}');

/// Keys missing from [values] are left intact.
String substituteModuleArguments(String text, Map<String, String> values) {
  return text.replaceAllMapped(_argumentPlaceholder, (match) {
    final key = match.group(1)!.trim();
    return values.containsKey(key) ? values[key]! : match.group(0)!;
  });
}

Map<String, String> effectiveModuleArguments(
  Sgmodule module,
  Map<String, String> userValues,
) {
  final effective = <String, String>{};
  for (final arg in module.arguments) {
    effective[arg.key] = userValues[arg.key] ?? arg.defaultValue;
  }
  return effective;
}

/// The returned [Sgmodule.raw] holds the substituted text.
Sgmodule parseSgmoduleWithArguments(
  String raw,
  Map<String, String> userValues,
) {
  final declared = parseSgmodule(raw);
  final effective = effectiveModuleArguments(declared, userValues);
  if (effective.isEmpty) return declared;
  return parseSgmodule(substituteModuleArguments(raw, effective));
}

/// Parse a `[Header Rewrite]` line into (pattern, action, args).
/// Returns null if the line doesn't match the expected format.
/// Format: `<url-pattern> <header-del|header-add|header-replace|header-replace-regex> <args...>`
({String pattern, String action, List<String> args})? parseHeaderRewriteLine(
  String line,
) {
  // Match: pattern followed by action and quoted args
  // e.g.: ^https?://example.com/ header-del "X-Header"
  final match = _headerRewriteLinePattern.firstMatch(line.trim());
  if (match == null) return null;
  final pattern = match.group(1)!;
  final action = match.group(2)!;
  final argsStr = match.group(3)!;
  // Extract quoted strings
  final args = <String>[];
  final quoted = _quotedArgPattern.allMatches(argsStr);
  for (final m in quoted) {
    args.add(m.group(1)!);
  }
  if (args.isEmpty) return null;
  return (pattern: pattern, action: action, args: args);
}

List<String> _splitQuoted(String line) {
  final tokens = <String>[];
  final buf = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      inQuotes = !inQuotes;
      buf.write(c);
    } else if ((c == ' ' || c == '\t') && !inQuotes) {
      if (buf.isNotEmpty) {
        tokens.add(buf.toString());
        buf.clear();
      }
    } else {
      buf.write(c);
    }
  }
  if (buf.isNotEmpty) tokens.add(buf.toString());
  return tokens;
}

String _unquote(String s) {
  final v = s.trim();
  if (v.length >= 2 && v.startsWith('"') && v.endsWith('"')) {
    return v.substring(1, v.length - 1);
  }
  return v;
}

/// Parse a `[Map Local]` line. Format:
/// `<url-pattern> data-type=<text|file|tiny-gif|base64> data=<data> [status-code=<n>] [Extra-Header=<v> ...]`
({
  String pattern,
  String dataType,
  String data,
  int statusCode,
  Map<String, String> headers,
})?
parseMapLocalLine(String line) {
  final tokens = _splitQuoted(line.trim());
  if (tokens.isEmpty) return null;
  final pattern = _unquote(tokens.first);
  if (pattern.isEmpty) return null;
  var dataType = '';
  var data = '';
  var statusCode = 200;
  final headers = <String, String>{};
  for (final token in tokens.skip(1)) {
    final eq = token.indexOf('=');
    if (eq <= 0) continue;
    final key = token.substring(0, eq).trim().toLowerCase();
    final value = _unquote(token.substring(eq + 1));
    switch (key) {
      case 'data-type':
        dataType = value.toLowerCase();
      case 'data':
        data = value;
      case 'status-code':
        statusCode = int.tryParse(value) ?? 200;
      default:
        final name = token.substring(0, eq).trim();
        if (name.isNotEmpty) headers[name] = value;
    }
  }
  // data-type is required; without it a stray line could become a rule whose
  // pattern accidentally matches real URLs.
  switch (dataType) {
    case 'text':
    case 'file':
    case 'tiny-gif':
    case 'base64':
      break;
    default:
      return null;
  }
  return (
    pattern: pattern,
    dataType: dataType,
    data: data,
    statusCode: statusCode,
    headers: headers,
  );
}

/// Parse a `[Body Rewrite]` line. Format:
/// `<http-request|http-response> <url-pattern> <regex> <replacement>` or `<http-request-jq|http-response-jq> <url-pattern> <jq>`
({String type, String pattern, String regex, String replacement, String jq})?
parseBodyRewriteLine(String line) {
  final match = _bodyRewriteLinePattern.firstMatch(line.trim());
  if (match == null) return null;
  final type = match.group(1)!.toLowerCase();
  final pattern = match.group(2)!;
  final rest = match.group(3)!.trim();
  switch (type) {
    case 'http-request-jq':
    case 'http-response-jq':
      if (rest.isEmpty) return null;
      return (
        type: type,
        pattern: pattern,
        regex: '',
        replacement: '',
        jq: rest,
      );
    case 'http-request':
    case 'http-response':
      break;
    default:
      return null;
  }
  final expr = _bodyRewriteExprPattern.firstMatch(rest);
  if (expr == null) return null;
  return (
    type: type,
    pattern: pattern,
    regex: expr.group(1)!,
    replacement: expr.group(2)!,
    jq: '',
  );
}

/// Build a minimal Clash config YAML from parsed proxies.
String buildClashConfigFromProxies({
  required List<Map<String, dynamic>> proxies,
  List<Map<String, dynamic>>? proxyGroups,
  List<String>? rules,
  List<String>? dnsServers,
  List<String>? directDnsServers,
  List<String>? tunExcludedRoutes,
  List<String>? tunIncludedRoutes,
  bool? ipv6Enabled,
  bool? preferIpv6,
  bool? alwaysRealIp,
  String? groupName,
}) {
  final proxyNames = proxies
      .map((e) => '${e['name'] ?? ''}')
      .where((e) => e.isNotEmpty)
      .toList();
  final mainGroup = groupName ?? 'PROXY';
  final groups =
      proxyGroups ??
      [
        {'name': mainGroup, 'type': 'select', 'proxies': proxyNames},
      ];
  // skip-proxy stays on the TUN path: no DIRECT rules are forced.
  final configRules = <String>[];
  configRules.addAll(rules ?? ['MATCH,$mainGroup']);
  final config = <String, dynamic>{
    'proxies': proxies,
    'proxy-groups': groups,
    'rules': configRules,
  };
  // DNS configuration from [General]
  if (dnsServers != null && dnsServers.isNotEmpty) {
    final dns = <String, dynamic>{'enable': true, 'nameserver': dnsServers};
    if (directDnsServers != null && directDnsServers.isNotEmpty) {
      dns['direct-nameserver'] = directDnsServers;
    }
    if (ipv6Enabled != null) {
      dns['ipv6'] = ipv6Enabled;
    }
    // `always-real-ip` has no Clash equivalent and is intentionally not
    // mapped: emitting `respect-rules` here would fail config parsing
    // (it requires `proxy-server-nameserver`), and mihomo already returns
    // real IPs in its default DNS mapping mode.
    config['dns'] = dns;
  }
  // TUN routes from [General]
  if ((tunExcludedRoutes != null && tunExcludedRoutes.isNotEmpty) ||
      (tunIncludedRoutes != null && tunIncludedRoutes.isNotEmpty)) {
    final tun = <String, dynamic>{'enable': true};
    if (tunExcludedRoutes != null && tunExcludedRoutes.isNotEmpty) {
      tun['route-exclude-address'] = tunExcludedRoutes;
    }
    if (tunIncludedRoutes != null && tunIncludedRoutes.isNotEmpty) {
      tun['route-include-address'] = tunIncludedRoutes;
    }
    config['tun'] = tun;
  }
  // IPv6 at top level
  if (ipv6Enabled != null) {
    config['ipv6'] = ipv6Enabled;
  }
  return yaml.encode(config);
}
