import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

class _CapturingCore extends CoreHandlerInterface {
  Map<String, dynamic>? lastArguments;

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    lastArguments = (arguments as Map?)?.cast<String, dynamic>();
    return null;
  }

  @override
  Future<CoreLifecycleResult> start() => throw UnimplementedError();

  @override
  Future<CoreLifecycleResult> restart() => throw UnimplementedError();

  @override
  Future<CoreLifecycleResult> stop() => throw UnimplementedError();

  @override
  Future<CoreLifecycleResult> close() => throw UnimplementedError();
}

void main() {
  group('asyncTestDelay method wiring', () {
    test('omits the method key when no method is given', () async {
      final core = _CapturingCore();
      await core.asyncTestDelay('http://example.com', 'proxy');
      expect(core.lastArguments?['proxy-name'], 'proxy');
      expect(core.lastArguments?['test-url'], 'http://example.com');
      expect(core.lastArguments?.containsKey('method'), isFalse);
    });

    test('sends the method name for tcp and icmp', () async {
      final core = _CapturingCore();
      await core.asyncTestDelay(
        'http://example.com',
        'proxy',
        DelayTestMethod.tcp,
      );
      expect(core.lastArguments?['method'], 'tcp');
      await core.asyncTestDelay(
        'http://example.com',
        'proxy',
        DelayTestMethod.icmp,
      );
      expect(core.lastArguments?['method'], 'icmp');
    });

    test('delay test methods serialize by name', () {
      expect(DelayTestMethod.values.map((e) => e.name), [
        'tcp',
        'icmp',
        'connect',
      ]);
      expect(const AppSettingProps().delayTestMethod, DelayTestMethod.connect);
    });
  });
}
