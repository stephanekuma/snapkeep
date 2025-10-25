import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TagSystem extends StatefulWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;

  const TagSystem({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  State<TagSystem> createState() => _TagSystemState();
}

class _TagSystemState extends State<TagSystem> {
  final TextEditingController _tagController = TextEditingController();

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !widget.selectedTags.contains(tag.trim())) {
      setState(() {
        widget.onTagsChanged([...widget.selectedTags, tag.trim()]);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      widget.onTagsChanged(
        widget.selectedTags.where((t) => t != tag).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input pour ajouter un tag
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Ajouter un tag...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
                onSubmitted: _addTag,
              ),
            ),
            SizedBox(width: 8.w),
            IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: FaIcon(
                FontAwesomeIcons.plus,
                size: 16.sp,
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Tags sélectionnés
        if (widget.selectedTags.isNotEmpty) ...[
          Text(
            'Tags sélectionnés:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.selectedTags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
                deleteIcon: FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 12.sp,
                ),
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12.sp,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
        ],

        // Tags disponibles
        if (widget.availableTags.isNotEmpty) ...[
          Text(
            'Tags disponibles:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.availableTags
                .where((tag) => !widget.selectedTags.contains(tag))
                .map((tag) {
              return ActionChip(
                label: Text(tag),
                onPressed: () => _addTag(tag),
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12.sp,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
