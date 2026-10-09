import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';

typedef DesktopDragItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index, Widget dragHandle);

/// §3 drag-sort list: `drag_indicator` handle, semi-transparent dragged row,
/// 2px accent insertion line, 180ms settle animation. Rows share one fixed
/// [itemExtent] so drop targets resolve arithmetically.
class DesktopDragList<T> extends StatefulWidget {
  const DesktopDragList({
    super.key,
    required this.items,
    required this.itemExtent,
    required this.itemBuilder,
    required this.onReorder,
  });

  final List<T> items;
  final double itemExtent;
  final DesktopDragItemBuilder<T> itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  State<DesktopDragList<T>> createState() => _DesktopDragListState<T>();
}

class _DesktopDragListState<T> extends State<DesktopDragList<T>> {
  static const _settle = Duration(milliseconds: 180);

  int? _dragIndex;
  int _targetIndex = 0;
  double _dragDy = 0;

  void _beginDrag(int index) {
    setState(() {
      _dragIndex = index;
      _targetIndex = index;
      _dragDy = 0;
    });
  }

  void _updateDrag(double dy) {
    final dragIndex = _dragIndex;
    if (dragIndex == null) return;
    final raw = dragIndex + dy / widget.itemExtent;
    final target = raw.round().clamp(0, widget.items.length - 1);
    setState(() {
      _dragDy = dy;
      _targetIndex = target;
    });
  }

  void _endDrag() {
    final dragIndex = _dragIndex;
    final targetIndex = _targetIndex;
    setState(() {
      _dragIndex = null;
      _dragDy = 0;
    });
    if (dragIndex != null && targetIndex != dragIndex) {
      widget.onReorder(dragIndex, targetIndex);
    }
  }

  double _rowShift(int index) {
    final dragIndex = _dragIndex;
    if (dragIndex == null || index == dragIndex) return 0;
    final extent = widget.itemExtent;
    if (_targetIndex > dragIndex) {
      return index > dragIndex && index <= _targetIndex ? -extent : 0;
    }
    return index < dragIndex && index >= _targetIndex ? extent : 0;
  }

  double get _insertionY {
    final dragIndex = _dragIndex ?? 0;
    final extent = widget.itemExtent;
    if (_targetIndex == dragIndex) return -10;
    if (_targetIndex < dragIndex) return _targetIndex * extent - 1;
    return (_targetIndex + 1) * extent - 1;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesktopThemeTokens>();
    final accent = tokens?.accent ?? Theme.of(context).colorScheme.primary;
    final items = widget.items;
    final extent = widget.itemExtent;
    return SizedBox(
      height: items.length * extent,
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            AnimatedContainer(
              duration: _settle,
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0,
                i * extent + _rowShift(i),
                0,
              ),
              child: SizedBox(
                height: extent,
                child: i == _dragIndex
                    ? Opacity(
                        opacity: 0.55,
                        child: Transform.translate(
                          offset: Offset(0, _dragDy),
                          child: widget.itemBuilder(
                            context,
                            items[i],
                            i,
                            const _DragHandle(),
                          ),
                        ),
                      )
                    : widget.itemBuilder(
                        context,
                        items[i],
                        i,
                        _DragHandle(
                          index: i,
                          onBegin: _beginDrag,
                          onUpdate: _updateDrag,
                          onEnd: _endDrag,
                        ),
                      ),
              ),
            ),
          if (_dragIndex != null && _targetIndex != _dragIndex)
            AnimatedPositioned(
              duration: _settle,
              curve: Curves.easeOut,
              top: _insertionY,
              left: 8,
              right: 8,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatefulWidget {
  const _DragHandle({this.index, this.onBegin, this.onUpdate, this.onEnd});

  final int? index;
  final void Function(int index)? onBegin;
  final void Function(double dy)? onUpdate;
  final VoidCallback? onEnd;

  @override
  State<_DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<_DragHandle> {
  double _startDy = 0;
  double _dy = 0;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.index != null;
    final icon = Icon(
      Icons.drag_indicator,
      size: 20,
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
    );
    if (!interactive) return icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (details) {
        _startDy = details.globalPosition.dy;
        _dy = 0;
        widget.onBegin?.call(widget.index!);
      },
      onVerticalDragUpdate: (details) {
        _dy = details.globalPosition.dy - _startDy;
        widget.onUpdate?.call(_dy);
      },
      onVerticalDragEnd: (_) => widget.onEnd?.call(),
      onVerticalDragCancel: () => widget.onEnd?.call(),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Padding(padding: const EdgeInsets.all(8), child: icon),
      ),
    );
  }
}
