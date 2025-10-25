import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchAndFilterBar extends StatefulWidget {
  const SearchAndFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final Function(String) onSearchChanged;
  final Function(FilterOptions) onFilterChanged;

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  FilterOptions _currentFilter = FilterOptions.all;
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSearchExpanded
                ? Row(
                    key: const ValueKey('search'),
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isSearchExpanded = false;
                                  _searchController.clear();
                                  widget.onSearchChanged('');
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                          ),
                          onChanged: widget.onSearchChanged,
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey('buttons'),
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearchExpanded = true;
                          });
                        },
                        icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
                      ),
                      IconButton(
                        onPressed: _showFilterBottomSheet,
                        icon: FaIcon(
                          FontAwesomeIcons.filter,
                          color: _currentFilter != FilterOptions.all
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                    ],
                  ),
          ),
          if (_currentFilter != FilterOptions.all) _buildActiveFilters(),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      child: Wrap(
        spacing: 8.w,
        children: [
          Chip(
            label: Text(_getFilterDisplayName(_currentFilter)),
            onDeleted: () {
              setState(() {
                _currentFilter = FilterOptions.all;
              });
              widget.onFilterChanged(_currentFilter);
            },
            deleteIcon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrer par',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            RadioGroup<FilterOptions>(
              groupValue: _currentFilter,
              onChanged: (FilterOptions? value) {
                setState(() {
                  _currentFilter = value!;
                });
                widget.onFilterChanged(_currentFilter);
                Navigator.pop(context);
              },
              child: Column(
                children: FilterOptions.values
                    .map((filter) => RadioListTile<FilterOptions>(
                          title: Text(_getFilterDisplayName(filter)),
                          value: filter,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterDisplayName(FilterOptions filter) {
    switch (filter) {
      case FilterOptions.all:
        return 'Tous';
      case FilterOptions.images:
        return 'Images seulement';
      case FilterOptions.videos:
        return 'Vidéos seulement';
      case FilterOptions.large:
        return 'Fichiers volumineux';
    }
  }
}

enum FilterOptions {
  all,
  images,
  videos,
  large,
}
