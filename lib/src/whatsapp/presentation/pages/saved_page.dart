import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/widgets/loader.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/selectable_media_grid.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/search_and_filter_bar.dart';
import 'package:snapkeep/src/whatsapp/presentation/pages/status_page.dart';

@RoutePage()
class SavedPage extends StatefulWidget {
  const SavedPage({super.key, this.onFilterChanged});

  final Function(FilterOptions)? onFilterChanged;

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  FilterOptions _currentFilter = FilterOptions.all;
  List<Status> _filteredStatuses = [];
  List<Status> _allStatuses = [];
  StreamSubscription<FilterOptions>? _filterSubscription;

  void _applyFilters() {
    setState(() {
      _filteredStatuses = _allStatuses.where((status) {
        // Type filter only
        final matchesType = _currentFilter == FilterOptions.all ||
            (_currentFilter == FilterOptions.images && !status.isVideo) ||
            (_currentFilter == FilterOptions.videos && status.isVideo);

        return matchesType;
      }).toList();
    });
  }

  void _updateStatuses(List<Status> statuses) {
    setState(() {
      _allStatuses = statuses;
    });
    _applyFilters();
  }

  @override
  void initState() {
    super.initState();
    // Écouter les changements de filtre depuis StatusPage
    _filterSubscription = FilterController.stream.listen((filter) {
      setState(() {
        _currentFilter = filter;
      });
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _filterSubscription?.cancel();
    super.dispose();
  }

  void changeFilter(FilterOptions newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<StatusBloc, StatusState>(
        listener: (context, state) {
          if (state is StatusLoadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LoadingStatus) {
            return const Loader();
          }

          if (state is StatusLoadFailure) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/errors/error.png'),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            );
          }

          if (state is StatusLoaded) {
            // Update statuses if they have changed
            if (_allStatuses != state.statuses) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateStatuses(state.statuses);
              });
            }

            if (_filteredStatuses.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/errors/empty.png'),
                  Text(
                    _currentFilter != FilterOptions.all
                        ? 'Aucun résultat trouvé'
                        : 'No saved statuses found',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              );
            } else {
              return SelectableMediaGrid(
                statuses: _filteredStatuses,
                isStored: true,
              );
            }
          }

          return Container();
        },
      ),
    );
  }
}
