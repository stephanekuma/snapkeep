// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'index.dart';

/// generated route for
/// [ImageViewerPage]
class ImageViewerRoute extends PageRouteInfo<ImageViewerRouteArgs> {
  ImageViewerRoute({
    Key? key,
    required Status status,
    bool isStored = false,
    List<Status> allStatuses = const [],
    int currentIndex = 0,
    List<PageRouteInfo>? children,
  }) : super(
          ImageViewerRoute.name,
          args: ImageViewerRouteArgs(
            key: key,
            status: status,
            isStored: isStored,
            allStatuses: allStatuses,
            currentIndex: currentIndex,
          ),
          initialChildren: children,
        );

  static const String name = 'ImageViewerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ImageViewerRouteArgs>();
      return ImageViewerPage(
        key: args.key,
        status: args.status,
        isStored: args.isStored,
        allStatuses: args.allStatuses,
        currentIndex: args.currentIndex,
      );
    },
  );
}

class ImageViewerRouteArgs {
  const ImageViewerRouteArgs({
    this.key,
    required this.status,
    this.isStored = false,
    this.allStatuses = const [],
    this.currentIndex = 0,
  });

  final Key? key;

  final Status status;

  final bool isStored;

  final List<Status> allStatuses;

  final int currentIndex;

  @override
  String toString() {
    return 'ImageViewerRouteArgs{key: $key, status: $status, isStored: $isStored, allStatuses: $allStatuses, currentIndex: $currentIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ImageViewerRouteArgs) return false;
    return key == other.key &&
        status == other.status &&
        isStored == other.isStored &&
        const ListEquality<Status>().equals(allStatuses, other.allStatuses) &&
        currentIndex == other.currentIndex;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      status.hashCode ^
      isStored.hashCode ^
      const ListEquality<Status>().hash(allStatuses) ^
      currentIndex.hashCode;
}

/// generated route for
/// [ImagesPage]
class ImagesRoute extends PageRouteInfo<void> {
  const ImagesRoute({List<PageRouteInfo>? children})
      : super(ImagesRoute.name, initialChildren: children);

  static const String name = 'ImagesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ImagesPage();
    },
  );
}

/// generated route for
/// [LightingModePage]
class LightingModeRoute extends PageRouteInfo<void> {
  const LightingModeRoute({List<PageRouteInfo>? children})
      : super(LightingModeRoute.name, initialChildren: children);

  static const String name = 'LightingModeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LightingModePage();
    },
  );
}

/// generated route for
/// [SavedPage]
class SavedRoute extends PageRouteInfo<SavedRouteArgs> {
  SavedRoute({
    Key? key,
    dynamic Function(FilterOptions)? onFilterChanged,
    List<PageRouteInfo>? children,
  }) : super(
          SavedRoute.name,
          args: SavedRouteArgs(key: key, onFilterChanged: onFilterChanged),
          initialChildren: children,
        );

  static const String name = 'SavedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SavedRouteArgs>(
        orElse: () => const SavedRouteArgs(),
      );
      return SavedPage(key: args.key, onFilterChanged: args.onFilterChanged);
    },
  );
}

class SavedRouteArgs {
  const SavedRouteArgs({this.key, this.onFilterChanged});

  final Key? key;

  final dynamic Function(FilterOptions)? onFilterChanged;

  @override
  String toString() {
    return 'SavedRouteArgs{key: $key, onFilterChanged: $onFilterChanged}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SavedRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [SettingPage]
class SettingRoute extends PageRouteInfo<void> {
  const SettingRoute({List<PageRouteInfo>? children})
      : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingPage();
    },
  );
}

/// generated route for
/// [StatusPage]
class StatusRoute extends PageRouteInfo<void> {
  const StatusRoute({List<PageRouteInfo>? children})
      : super(StatusRoute.name, initialChildren: children);

  static const String name = 'StatusRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StatusPage();
    },
  );
}

/// generated route for
/// [StorageSettingsPage]
class StorageSettingsRoute extends PageRouteInfo<void> {
  const StorageSettingsRoute({List<PageRouteInfo>? children})
      : super(StorageSettingsRoute.name, initialChildren: children);

  static const String name = 'StorageSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StorageSettingsPage();
    },
  );
}

/// generated route for
/// [VideoViewerPage]
class VideoViewerRoute extends PageRouteInfo<VideoViewerRouteArgs> {
  VideoViewerRoute({
    Key? key,
    required Status status,
    bool isStored = false,
    List<Status> allStatuses = const [],
    int currentIndex = 0,
    List<PageRouteInfo>? children,
  }) : super(
          VideoViewerRoute.name,
          args: VideoViewerRouteArgs(
            key: key,
            status: status,
            isStored: isStored,
            allStatuses: allStatuses,
            currentIndex: currentIndex,
          ),
          initialChildren: children,
        );

  static const String name = 'VideoViewerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VideoViewerRouteArgs>();
      return VideoViewerPage(
        key: args.key,
        status: args.status,
        isStored: args.isStored,
        allStatuses: args.allStatuses,
        currentIndex: args.currentIndex,
      );
    },
  );
}

class VideoViewerRouteArgs {
  const VideoViewerRouteArgs({
    this.key,
    required this.status,
    this.isStored = false,
    this.allStatuses = const [],
    this.currentIndex = 0,
  });

  final Key? key;

  final Status status;

  final bool isStored;

  final List<Status> allStatuses;

  final int currentIndex;

  @override
  String toString() {
    return 'VideoViewerRouteArgs{key: $key, status: $status, isStored: $isStored, allStatuses: $allStatuses, currentIndex: $currentIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VideoViewerRouteArgs) return false;
    return key == other.key &&
        status == other.status &&
        isStored == other.isStored &&
        const ListEquality<Status>().equals(allStatuses, other.allStatuses) &&
        currentIndex == other.currentIndex;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      status.hashCode ^
      isStored.hashCode ^
      const ListEquality<Status>().hash(allStatuses) ^
      currentIndex.hashCode;
}

/// generated route for
/// [VideosPage]
class VideosRoute extends PageRouteInfo<void> {
  const VideosRoute({List<PageRouteInfo>? children})
      : super(VideosRoute.name, initialChildren: children);

  static const String name = 'VideosRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VideosPage();
    },
  );
}
