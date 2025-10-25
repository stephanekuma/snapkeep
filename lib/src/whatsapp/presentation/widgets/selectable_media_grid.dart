import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:snapkeep/src/core/router/index.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/status_image.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/status_video.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/batch_action_bar.dart';

class SelectableMediaGrid extends StatefulWidget {
  const SelectableMediaGrid({
    super.key,
    required this.statuses,
    this.isStored = false,
  });

  final List<Status> statuses;
  final bool isStored;

  @override
  State<SelectableMediaGrid> createState() => _SelectableMediaGridState();
}

class _SelectableMediaGridState extends State<SelectableMediaGrid> {
  final Set<String> _selectedItems = <String>{};
  bool _isSelectionMode = false;

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }

      if (_selectedItems.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _selectAll() {
    setState(() {
      _selectedItems.addAll(widget.statuses.map((s) => s.path));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isSelectionMode) _buildSelectionBar(),
        if (_isSelectionMode && _selectedItems.isNotEmpty)
          BatchActionBar(
            selectedItems: _getSelectedStatuses(),
            onClearSelection: _exitSelectionMode,
            isStored: widget.isStored,
          ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(8.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: widget.statuses.length,
            itemBuilder: (context, index) {
              final status = widget.statuses[index];
              final isSelected = _selectedItems.contains(status.path);

              return GestureDetector(
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _enterSelectionMode();
                    _toggleSelection(status.path);
                  }
                },
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(status.path);
                  } else {
                    // Navigation normale vers le viewer
                    _navigateToViewer(status);
                  }
                },
                child: Stack(
                  children: [
                    // Media widget
                    status.isVideo
                        ? StatusVideo(status: status, isStored: widget.isStored)
                        : StatusImage(
                            status: status, isStored: widget.isStored),

                    // Selection overlay
                    if (_isSelectionMode)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 30.sp,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '${_selectedItems.length} sélectionné(s)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _selectedItems.length == widget.statuses.length
                    ? _clearSelection
                    : _selectAll,
                icon: Icon(
                  _selectedItems.length == widget.statuses.length
                      ? Icons.deselect
                      : Icons.select_all,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: _exitSelectionMode,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Status> _getSelectedStatuses() {
    return widget.statuses
        .where((status) => _selectedItems.contains(status.path))
        .toList();
  }

  void _navigateToViewer(Status status) {
    final currentIndex = widget.statuses.indexOf(status);

    if (status.isVideo) {
      context.router.push(
        VideoViewerRoute(
          status: status,
          isStored: widget.isStored,
          allStatuses: widget.statuses,
          currentIndex: currentIndex,
        ),
      );
    } else {
      context.router.push(
        ImageViewerRoute(
          status: status,
          isStored: widget.isStored,
          allStatuses: widget.statuses,
          currentIndex: currentIndex,
        ),
      );
    }
  }
}
