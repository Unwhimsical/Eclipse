import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mutable holder for desktop UI state; Riverpod 3 keeps [StateProvider] in
/// the legacy import only.
class ValueHolder<T> extends Notifier<T> {
  ValueHolder(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  set value(T next) {
    if (state != next) state = next;
  }
}

NotifierProvider<ValueHolder<T>, T> valueHolder<T>(T initial) {
  return NotifierProvider<ValueHolder<T>, T>(() => ValueHolder<T>(initial));
}
