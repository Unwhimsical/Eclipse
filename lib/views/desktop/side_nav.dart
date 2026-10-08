import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class _MoveNavFocusIntent extends Intent {
  const _MoveNavFocusIntent(this.forward);

  final bool forward;
}

class _ActivateNavIntent extends Intent {
  const _ActivateNavIntent();
}

bool _focusIsTextInput() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context is! Element) return false;
  if (context.widget is EditableText) return true;
  var found = false;
  context.visitAncestorElements((element) {
    if (element.widget is EditableText) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// Self-drawn desktop sidebar (§2): 68/208 dual-snap widths with a draggable
/// divider, five destinations, digit-key switching, and a settings/version
/// footer. Replaces NavigationRail on desktop.
class DesktopSideNav extends StatefulWidget {
  const DesktopSideNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    required this.version,
    required this.isRunning,
    this.isMacOS = false,
  });

  static const double collapsedWidth = 68;
  static const double expandedWidth = 208;
  static const double itemHeight = 44;

  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final String version;
  final bool isRunning;
  final bool isMacOS;

  @override
  State<DesktopSideNav> createState() => _DesktopSideNavState();
}

class _DesktopSideNavState extends State<DesktopSideNav> {
  static const _digitKeys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
  ];

  double _width = DesktopSideNav.expandedWidth;
  bool _handleHover = false;
  int? _focusedIndex;

  bool get _collapsed =>
      _width <
      (DesktopSideNav.collapsedWidth + DesktopSideNav.expandedWidth) / 2;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleDigitKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleDigitKey);
    super.dispose();
  }

  /// Digit keys switch pages app-wide, independent of focus, except while a
  /// text input is focused or a dialog sits above the page.
  bool _handleDigitKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final index = _digitKeys.indexOf(event.logicalKey);
    if (index < 0 || index >= widget.items.length) return false;
    if (_focusIsTextInput()) return false;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return false;
    widget.onSelected(index);
    return true;
  }

  void _snapWidth() {
    setState(() {
      _width = _collapsed
          ? DesktopSideNav.collapsedWidth
          : DesktopSideNav.expandedWidth;
    });
  }

  void _handleMoveFocus(_MoveNavFocusIntent intent) {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) return;
    if (intent.forward) {
      focus.nextFocus();
    } else {
      focus.previousFocus();
    }
  }

  void _handleActivateFocused(_ActivateNavIntent intent) {
    final index = _focusedIndex;
    if (index != null && index < widget.items.length) {
      widget.onSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final scheme = theme.colorScheme;
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveNavFocusIntent(
          true,
        ),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveNavFocusIntent(false),
        SingleActivator(LogicalKeyboardKey.enter): _ActivateNavIntent(),
        SingleActivator(LogicalKeyboardKey.space): _ActivateNavIntent(),
      },
      child: Actions(
        actions: {
          _MoveNavFocusIntent: CallbackAction<_MoveNavFocusIntent>(
            onInvoke: _handleMoveFocus,
          ),
          _ActivateNavIntent: CallbackAction<_ActivateNavIntent>(
            onInvoke: _handleActivateFocused,
          ),
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              key: const ValueKey('desktopSideNavPane'),
              width: _width,
              color: tokens?.bg1 ?? scheme.surfaceContainer,
              child: Column(
                children: [
                  if (widget.isMacOS) const SizedBox(height: 22),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        for (var i = 0; i < widget.items.length; i++)
                          _SideNavItemButton(
                            icon: widget.items[i].icon,
                            label: widget.items[i].label.label,
                            selected: i == widget.currentIndex,
                            collapsed: _collapsed,
                            onTap: () => widget.onSelected(i),
                            onFocusChange: (focused) {
                              setState(() {
                                _focusedIndex = focused ? i : null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  _buildFooter(context),
                ],
              ),
            ),
            _buildHandle(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final scheme = theme.colorScheme;
    final lineColor = _handleHover
        ? (tokens?.accent.withValues(alpha: 0.4) ??
              scheme.primary.withValues(alpha: 0.4))
        : scheme.outlineVariant;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _handleHover = true),
      onExit: (_) => setState(() => _handleHover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          setState(() {
            _width = (_width + details.delta.dx).clamp(
              DesktopSideNav.collapsedWidth,
              DesktopSideNav.expandedWidth,
            );
          });
        },
        onHorizontalDragEnd: (_) => _snapWidth(),
        onDoubleTap: () {
          setState(() {
            _width = _collapsed
                ? DesktopSideNav.expandedWidth
                : DesktopSideNav.collapsedWidth;
          });
        },
        child: Container(
          width: 12,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: _handleHover ? 3 : 1,
            height: double.infinity,
            color: lineColor,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final scheme = theme.colorScheme;
    final appLocalizations = context.appLocalizations;
    final settingsIndex = widget.items.indexWhere(
      (item) => item.label == PageLabel.settings,
    );
    final settingsSelected = settingsIndex == widget.currentIndex;
    final accent = tokens?.accent ?? scheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 1,
          thickness: 1,
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _collapsed ? 4 : 12,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: _collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            spacing: 8,
            children: [
              IconButton(
                tooltip: appLocalizations.settings,
                onPressed: settingsIndex == -1
                    ? null
                    : () => widget.onSelected(settingsIndex),
                iconSize: 20,
                style: _collapsed
                    ? const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: WidgetStatePropertyAll(Size(32, 32)),
                        padding: WidgetStatePropertyAll(EdgeInsets.all(6)),
                      )
                    : null,
                color: settingsSelected ? accent : scheme.onSurfaceVariant,
                icon: const Icon(Icons.settings_outlined),
              ),
              if (!_collapsed)
                Expanded(
                  child: Text(
                    widget.version,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tokens?.text3 ?? scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isRunning
                      ? (tokens?.success ?? scheme.primary)
                      : (tokens?.text3 ?? scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideNavItemButton extends StatefulWidget {
  const _SideNavItemButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.onTap,
    required this.onFocusChange,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;
  final ValueChanged<bool> onFocusChange;

  @override
  State<_SideNavItemButton> createState() => _SideNavItemButtonState();
}

class _SideNavItemButtonState extends State<_SideNavItemButton> {
  final _focusNode = FocusNode();

  bool _hover = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final scheme = theme.colorScheme;
    final accent = tokens?.accent ?? scheme.primary;
    final capsuleColor = widget.selected
        ? (tokens?.accentSoft ?? scheme.primary.withValues(alpha: 0.14))
        : _pressed
        ? (tokens?.bg3 ?? scheme.surfaceContainerHighest)
        : _hover
        ? (tokens?.bg3.withValues(alpha: 0.6) ??
              scheme.surfaceContainerHighest.withValues(alpha: 0.6))
        : Colors.transparent;
    final foreground = widget.selected
        ? accent
        : (tokens?.text2 ?? scheme.onSurfaceVariant);
    final capsule = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: DesktopSideNav.itemHeight,
        decoration: ShapeDecoration(
          shape: const RoundedSuperellipseBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          color: capsuleColor,
        ),
        child: Row(
          mainAxisAlignment: widget.collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            const SizedBox(width: 12),
            IconTheme(
              data: IconThemeData(color: foreground, size: 22),
              child: widget.icon,
            ),
            if (!widget.collapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
            ] else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (value) {
        widget.onFocusChange(value);
        setState(() => _focused = value);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: Container(
            decoration: _focused
                ? ShapeDecoration(
                    shape: RoundedSuperellipseBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      side: BorderSide(
                        color: accent.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                  )
                : null,
            padding: _focused ? const EdgeInsets.all(2) : EdgeInsets.zero,
            child: widget.collapsed
                ? Tooltip(
                    message: widget.label,
                    waitDuration: const Duration(milliseconds: 400),
                    child: capsule,
                  )
                : capsule,
          ),
        ),
      ),
    );
  }
}
