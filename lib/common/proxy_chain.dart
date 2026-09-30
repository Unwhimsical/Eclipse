library;

/// Follows [name]'s via links; a loop appends the repeated node once.
List<String> resolveProxyChain(
  String name,
  Map<String, String> chains,
  Set<String> validNames,
) {
  final hops = <String>[name];
  final seen = <String>{name};
  var current = name;
  while (true) {
    final via = chains[current];
    if (via == null || via.isEmpty || !validNames.contains(via)) break;
    hops.add(via);
    if (!seen.add(via)) break;
    current = via;
  }
  return hops;
}

bool hasProxyChainLoop(Map<String, String> chains) {
  for (final start in chains.keys) {
    final seen = <String>{};
    var current = start;
    while (true) {
      final via = chains[current];
      if (via == null || via.isEmpty) break;
      if (via == start || !seen.add(via)) return true;
      current = via;
    }
  }
  return false;
}

/// Drops entries with unknown or self-referential nodes.
Map<String, String> sanitizeProxyChains(
  Map<String, String> chains,
  Set<String> validNames,
) {
  return {
    for (final entry in chains.entries)
      if (validNames.contains(entry.key) &&
          entry.value.isNotEmpty &&
          entry.value != entry.key &&
          validNames.contains(entry.value))
        entry.key: entry.value,
  };
}
