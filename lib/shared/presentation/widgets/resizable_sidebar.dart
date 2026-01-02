import 'package:flutter/material.dart';
import 'package:open_git/shared/core/di/injectable.dart';
import 'package:open_git/shared/core/services/ui_preferences_service.dart';
import 'package:open_git/shared/presentation/widgets/ui_layout_constraints.dart';

class ResizableSidebar extends StatefulWidget {
  final Widget child;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;

  const ResizableSidebar({
    super.key,
    required this.child,
    this.initialWidth = UiLayoutConstraints.repositorySidebarDefaultWidth,
    this.minWidth = UiLayoutConstraints.repositorySidebarMinWidth,
    this.maxWidth = UiLayoutConstraints.repositorySidebarMaxWidth,
  });

  @override
  State<ResizableSidebar> createState() {
    return _ResizableSidebarState();
  }
}

class _ResizableSidebarState extends State<ResizableSidebar> {
  late double _width;
  final UiPreferencesService uiPreferencesService = getIt();

  @override
  void initState() {
    super.initState();
    _width = uiPreferencesService.getSidebarWidth() ?? widget.initialWidth;
  }

  void _updateWidth(double delta) {
    setState(() {
      _width += delta;
      _width = _width.clamp(
        widget.minWidth,
        widget.maxWidth,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Stack(
        children: [
          Positioned.fill(
            child: widget.child,
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: () async {
                  setState(() {
                    _width = widget.initialWidth;
                  });
                  await uiPreferencesService.setSidebarWidth(_width);
                },
                onHorizontalDragUpdate: (details) {
                  _updateWidth(details.delta.dx);
                },
                onHorizontalDragEnd: (_) async {
                  await uiPreferencesService.setSidebarWidth(_width);
                },
                child: Container(
                  width: 8,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
