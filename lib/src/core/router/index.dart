import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:snapkeep/src/settings/presentation/pages/index.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/pages/index.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/search_and_filter_bar.dart';

part 'index.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(
          page: StatusRoute.page,
          initial: true,
          children: <AutoRoute>[
            RedirectRoute(
              path: '',
              redirectTo: ImagesRoute.name,
            ),
            CustomRoute(
              page: ImagesRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              duration: const Duration(milliseconds: 500),
            ),
            CustomRoute(
              page: VideosRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              duration: const Duration(milliseconds: 500),
            ),
            CustomRoute(
              page: SavedRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              duration: const Duration(milliseconds: 500),
            ),
          ],
        ),
        CustomRoute(
          page: ImageViewerRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 500),
        ),
        CustomRoute(
          page: VideoViewerRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 500),
        ),
        CustomRoute(
          page: SettingRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 500),
        ),
        CustomRoute(
          page: LightingModeRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 500),
        ),
        CustomRoute(
          page: StorageSettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 500),
        ),
      ];
}
