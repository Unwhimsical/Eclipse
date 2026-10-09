import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mutable holder for desktop UI state; Riverpod 3 keeps [StateProvider] in
/// the legacy import only.
class _ValueHolder<T> extends Notifier<T> {
  _ValueHolder(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  set value(T next) {
    if (state != next) state = next;
  }
}

NotifierProvider<_ValueHolder<T>, T> valueHolder<T>(T initial) {
  return NotifierProvider<_ValueHolder<T>, T>(() => _ValueHolder<T>(initial));
}
