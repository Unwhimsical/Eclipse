import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String resolvedSelectedName(WidgetRef ref, Group group, {bool listen = true}) {
  final selected = listen
      ? ref.watch(selectedProxyNameProvider(group.name))
      : ref.read(selectedProxyNameProvider(group.name));
  return preferSelectedName(selected, group.now);
}

({Group group, String name})? firstResolvedNode(
  WidgetRef ref,
  List<Group> groups, {
  bool listen = true,
}) {
  return firstNamedNode(
    groups,
    (group) => resolvedSelectedName(ref, group, listen: listen),
  );
}
