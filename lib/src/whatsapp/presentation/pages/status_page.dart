import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:async';
import 'package:snapkeep/src/core/router/index.dart';
import 'package:snapkeep/src/core/widgets/app_drawer.dart';
import 'package:snapkeep/src/core/widgets/tab_item.dart';
import 'package:snapkeep/src/core/widgets/permission_checker.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/search_and_filter_bar.dart';

// Classe publique pour la communication entre pages
class FilterController {
  static final StreamController<FilterOptions> _controller =
      StreamController<FilterOptions>.broadcast();

  static Stream<FilterOptions> get stream => _controller.stream;

  static void addFilter(FilterOptions filter) {
    _controller.add(filter);
  }

  static void dispose() {
    _controller.close();
  }
}

@RoutePage()
class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return PermissionChecker(
      onPermissionsGranted: () {
        // Permissions accordées, on peut continuer
      },
      onPermissionsDenied: () {
        // Permissions refusées, afficher un message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions requises pour utiliser l\'application'),
            duration: Duration(seconds: 3),
          ),
        );
      },
      child: AutoTabsRouter.tabBar(
        routes: const <PageRouteInfo>[
          ImagesRoute(),
          VideosRoute(),
          SavedRoute(),
        ],
        builder: (context, child, controller) {
          switch (controller.index) {
            case 0:
              context
                  .read<StatusBloc>()
                  .add(const FetchStatuses(isVideo: false));
              break;
            case 1:
              context
                  .read<StatusBloc>()
                  .add(const FetchStatuses(isVideo: true));
              break;
            case 2:
              context.read<StatusBloc>().add(FetchStoredStatuses());
              break;
            default:
              context
                  .read<StatusBloc>()
                  .add(const FetchStatuses(isVideo: false));
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Snap Keep',
                style: TextStyle(
                  fontSize: 22.sp,
                ),
              ),
              actions: controller.index == 2
                  ? [
                      _buildFilterButton(context),
                    ]
                  : null,
              bottom: TabBar(
                controller: controller,
                tabs: const <Tab>[
                  Tab(
                    child: TabItem(
                      icon: FontAwesomeIcons.images,
                      text: 'Images',
                    ),
                  ),
                  Tab(
                    child: TabItem(
                      icon: FontAwesomeIcons.photoFilm,
                      text: 'Videos',
                    ),
                  ),
                  Tab(
                    child: TabItem(
                      icon: FontAwesomeIcons.download,
                      text: 'Saved',
                    ),
                  ),
                ],
              ),
            ),
            drawer: const AppDrawer(),
            body: child,
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return PopupMenuButton<FilterOptions>(
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: FaIcon(
          FontAwesomeIcons.filter,
          color: Colors.white,
          size: 16.sp,
        ),
      ),
      offset: Offset(0, 50.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      onSelected: (FilterOptions filter) {
        // Envoyer le filtre via le StreamController
        FilterController.addFilter(filter);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filtre appliqué: ${_getFilterDisplayName(filter)}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      itemBuilder: (context) => [
        _buildFilterMenuItem(
          icon: FontAwesomeIcons.list,
          title: 'Tous',
          value: FilterOptions.all,
        ),
        _buildFilterMenuItem(
          icon: FontAwesomeIcons.images,
          title: 'Images seulement',
          value: FilterOptions.images,
        ),
        _buildFilterMenuItem(
          icon: FontAwesomeIcons.photoFilm,
          title: 'Vidéos seulement',
          value: FilterOptions.videos,
        ),
        _buildFilterMenuItem(
          icon: FontAwesomeIcons.file,
          title: 'Fichiers volumineux',
          value: FilterOptions.large,
        ),
      ],
    );
  }

  PopupMenuItem<FilterOptions> _buildFilterMenuItem({
    required IconData icon,
    required String title,
    required FilterOptions value,
  }) {
    return PopupMenuItem<FilterOptions>(
      value: value,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: FaIcon(
                icon,
                color: Colors.blue,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
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
