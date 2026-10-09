import 'package:fl_clash/views/desktop/components/desktop_menu.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Column definition for [DesktopTable].
class DesktopColumn<T> {
  const DesktopColumn({
    required this.title,
    required this.width,
    required this.cell,
    this.minWidth = 64,
    this.resizable = true,
    this.sortable = true,
    this.sortKey,
    this.align = TextAlign.start,
  });

  final String title;
  final double width;
  final double minWidth;
  final bool resizable;
  final bool sortable;
  final Comparable Function(T row)? sortKey;
  final Widget Function(T row) cell;
  final TextAlign align;
}

/// §2 data table: fixed-height container, 36px header with click-to-sort and
/// draggable column dividers, 40px rows. Row hover uses the §1 white overlay.
class DesktopTable<T> extends StatefulWidget {
  const DesktopTable({
    super.key,
    required this.columns,
    required this.rows,
    this.rowHeight = 40,
    this.onRowTap,
    this.rowMenuBuilder,
    this.emptyLabel = '',
  });

  final List<DesktopColumn<T>> columns;
  final List<T> rows;
  final double rowHeight;
  final void Function(T row)? onRowTap;
  final List<PopupMenuEntry<VoidCallback>> Function(T row)? rowMenuBuilder;
  final String emptyLabel;

  @override
  State<DesktopTable<T>> createState() => _DesktopTableState<T>();
}

class _DesktopTableState<T> extends State<DesktopTable<T>> {
  late List<double> _widths;
  int? _sortColumn;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _widths = [for (final c in widget.columns) c.width];
  }

  @override
  void didUpdateWidget(covariant DesktopTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns.length != widget.columns.length) {
      _widths = [for (final c in widget.columns) c.width];
      _sortColumn = null;
    }
  }

  List<T> get _sortedRows {
    final rows = List<T>.of(widget.rows);
    final sortColumn = _sortColumn;
    if (sortColumn == null) return rows;
    final key = widget.columns[sortColumn].sortKey;
    if (key == null) return rows;
    rows.sort((a, b) {
      final cmp = key(a).compareTo(key(b));
      return _ascending ? cmp : -cmp;
    });
    return rows;
  }

  void _toggleSort(int index) {
    final column = widget.columns[index];
    if (!column.sortable || column.sortKey == null) return;
    setState(() {
      if (_sortColumn == index) {
        _ascending = !_ascending;
      } else {
        _sortColumn = index;
        _ascending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final headerFg = tokens?.text2 ?? theme.colorScheme.onSurfaceVariant;
    final rows = _sortedRows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, headerFg),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    widget.emptyLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: rows.length,
                  itemExtent: widget.rowHeight,
                  itemBuilder: (_, i) => _Row<T>(row: rows[i], table: widget),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Color headerFg) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          for (var i = 0; i < widget.columns.length; i++) ...[
            _HeaderCell<T>(
              table: widget,
              state: this,
              index: i,
              width: _widths[i],
              foreground: headerFg,
              accent: tokens?.accent ?? theme.colorScheme.primary,
              onResize: (dx) {
                setState(() {
                  final column = widget.columns[i];
                  _widths[i] = (_widths[i] + dx).clamp(
                    column.minWidth,
                    double.infinity,
                  );
                });
              },
            ),
            if (i < widget.columns.length - 1 && widget.columns[i].resizable)
              _ColumnDivider(
                onDrag: (dx) {
                  setState(() {
                    final column = widget.columns[i];
                    _widths[i] = (_widths[i] + dx).clamp(
                      column.minWidth,
                      double.infinity,
                    );
                  });
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _HeaderCell<T> extends StatelessWidget {
  const _HeaderCell({
    required this.table,
    required this.state,
    required this.index,
    required this.width,
    required this.foreground,
    required this.accent,
    required this.onResize,
  });

  final DesktopTable<T> table;
  final _DesktopTableState<T> state;
  final int index;
  final double width;
  final Color foreground;
  final Color accent;
  final void Function(double dx) onResize;

  @override
  Widget build(BuildContext context) {
    final column = table.columns[index];
    final sorted = state._sortColumn == index;
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => state._toggleSort(index),
      child: MouseRegion(
        cursor: column.sortable && column.sortKey != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              spacing: 4,
              children: [
                Expanded(
                  child: Text(
                    column.title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: sorted ? accent : foreground,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (column.sortable && column.sortKey != null)
                  Icon(
                    !sorted
                        ? Icons.unfold_more_rounded
                        : state._ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: sorted ? accent : foreground.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColumnDivider extends StatelessWidget {
  const _ColumnDivider({required this.onDrag});

  final void Function(double dx) onDrag;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        child: const SizedBox(width: 7, height: double.infinity),
      ),
    );
  }
}

class _Row<T> extends StatefulWidget {
  const _Row({required this.row, required this.table});

  final T row;
  final DesktopTable<T> table;

  @override
  State<_Row<T>> createState() => _RowState<T>();
}

class _RowState<T> extends State<_Row<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final columns = widget.table.columns;
    final state = context.findAncestorStateOfType<_DesktopTableState<T>>();
    final widths = state?._widths;
    Widget row = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.table.onRowTap == null
            ? null
            : () => widget.table.onRowTap!(widget.row),
        child: Container(
          color: _hover ? DesktopThemeTokens.controlHoverOverlay : null,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              for (var i = 0; i < columns.length; i++)
                SizedBox(
                  width: (widths != null && i < widths.length)
                      ? widths[i]
                      : columns[i].width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: switch (columns[i].align) {
                        TextAlign.center => Alignment.center,
                        TextAlign.end => Alignment.centerRight,
                        _ => Alignment.centerLeft,
                      },
                      child: columns[i].cell(widget.row),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    final menuBuilder = widget.table.rowMenuBuilder;
    if (menuBuilder != null) {
      row = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapUp: (details) async {
          final items = menuBuilder(widget.row);
          if (items.isEmpty) return;
          final action = await showDesktopMenu<VoidCallback>(
            context: context,
            position: details.globalPosition,
            items: items,
          );
          action?.call();
        },
        child: row,
      );
    }
    return row;
  }
}
