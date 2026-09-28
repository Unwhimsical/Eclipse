import 'package:fl_clash/common/protocol.dart';
import 'package:fl_clash/common/system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('System.statArguments', () {
    test('macOS uses -f format', () {
      final args = System.statArguments('/path/to/core', isMacOS: true);
      expect(args, ['-f', '%Su:%Sg %Sp', '/path/to/core']);
    });

    test('Linux uses -c format', () {
      final args = System.statArguments('/path/to/core', isMacOS: false);
      expect(args, ['-c', '%U:%G %A', '/path/to/core']);
    });

    test('preserves path with spaces verbatim', () {
      final args = System.statArguments(
        '/my path/with spaces/core',
        isMacOS: false,
      );
      expect(args.last, '/my path/with spaces/core');
    });
  });

  group('System.isPrivilegedStatOutput', () {
    test('detects setuid root binary on macOS', () {
      expect(
        System.isPrivilegedStatOutput(
          'root:wheel rwsr-xr-x',
          ownerPrefix: 'root:',
        ),
        isTrue,
      );
    });

    test('rejects non-setuid binary', () {
      expect(
        System.isPrivilegedStatOutput(
          'root:wheel rwxr-xr-x',
          ownerPrefix: 'root:',
        ),
        isFalse,
      );
    });

    test('rejects wrong owner', () {
      expect(
        System.isPrivilegedStatOutput(
          'user:staff rwsr-xr-x',
          ownerPrefix: 'root:',
        ),
        isFalse,
      );
    });

    test('handles surrounding whitespace', () {
      expect(
        System.isPrivilegedStatOutput(
          '  root:wheel rwsr-xr-x\n',
          ownerPrefix: 'root:',
        ),
        isTrue,
      );
    });

    test('detects setuid on Linux format', () {
      expect(
        System.isPrivilegedStatOutput(
          'root:root rwsr-xr-x',
          ownerPrefix: 'root:',
        ),
        isTrue,
      );
    });
  });

  group('ProtocolRegistrationPlan', () {
    test('builds registry keys and values', () {
      const plan = ProtocolRegistrationPlan(
        scheme: 'pigcat',
        executable: r'C:\apps\pigcat.exe',
      );
      expect(plan.protocolKey, r'Software\Classes\pigcat');
      expect(plan.commandKey, r'shell\open\command');
      expect(plan.protocolValueName, 'URL Protocol');
      expect(plan.protocolValue, '');
      expect(plan.command, r'"C:\apps\pigcat.exe" "%1"');
    });

    test('supports all protocol schemes', () {
      for (final scheme in protocolSchemes) {
        final plan = ProtocolRegistrationPlan(scheme: scheme, executable: 'y');
        expect(plan.protocolKey, contains(scheme));
      }
      expect(protocolSchemes, contains('pigcat'));
      expect(protocolSchemes, contains('clash'));
    });
  });

  group('LinuxProtocolRegistrationPlan', () {
    test('builds desktop entry paths', () {
      const plan = LinuxProtocolRegistrationPlan(
        schemes: ['pigcat', 'clash'],
        executable: '/usr/bin/pigcat',
        applicationsDir: '/home/user/.local/share/applications',
      );
      expect(plan.desktopId, 'pigcat-url-handler.desktop');
      expect(
        plan.desktopPath,
        '/home/user/.local/share/applications/pigcat-url-handler.desktop',
      );
      expect(plan.mimeTypes, [
        'x-scheme-handler/pigcat',
        'x-scheme-handler/clash',
      ]);
      expect(plan.xdgMimeArguments, [
        'default',
        'pigcat-url-handler.desktop',
        'x-scheme-handler/pigcat',
        'x-scheme-handler/clash',
      ]);
    });

    test('builds desktop entry content', () {
      const plan = LinuxProtocolRegistrationPlan(
        schemes: ['pigcat'],
        executable: '/usr/bin/pigcat',
        applicationsDir: '/tmp',
      );
      final entry = plan.desktopEntry;
      expect(entry, contains('[Desktop Entry]'));
      expect(entry, contains('Type=Application'));
      expect(entry, contains('Name=PigCat'));
      expect(entry, contains('NoDisplay=true'));
      expect(entry, contains('MimeType=x-scheme-handler/pigcat;'));
    });

    test('quotes executable with special characters', () {
      const plan = LinuxProtocolRegistrationPlan(
        schemes: ['pigcat'],
        executable: r'/path/with $pecial "chars"',
        applicationsDir: '/tmp',
      );
      final exec = plan.exec;
      expect(exec, contains(r'\$pecial'));
      expect(exec, contains(r'\"chars\"'));
      expect(exec, endsWith(' %u'));
    });

    test('escapes backslashes and backticks', () {
      const plan = LinuxProtocolRegistrationPlan(
        schemes: ['pigcat'],
        executable: r'C:\path`with`',
        applicationsDir: '/tmp',
      );
      final exec = plan.exec;
      expect(exec, contains(r'C:\\path'));
      expect(exec, contains(r'\`with\`'));
    });

    test('escapes percent signs', () {
      const plan = LinuxProtocolRegistrationPlan(
        schemes: ['pigcat'],
        executable: '/path/100%',
        applicationsDir: '/tmp',
      );
      expect(plan.exec, contains('100%%'));
    });
  });
}
