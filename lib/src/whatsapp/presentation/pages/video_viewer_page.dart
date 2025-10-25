import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/constants/colors.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class VideoViewerPage extends StatefulWidget {
  const VideoViewerPage({
    super.key,
    required this.status,
    this.isStored = false,
    this.allStatuses = const [],
    this.currentIndex = 0,
  });

  final Status status;
  final bool isStored;
  final List<Status> allStatuses;
  final int currentIndex;

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isStored = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: widget.currentIndex);
    _checkStoredStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kDarkColor,
          content: Text(
            'Pinch to zoom\nDouble tap to save or share',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatusCubit>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        title: Text(
          'Vidéo',
          style: TextStyle(
            fontSize: 22.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Contenu principal avec padding en bas pour éviter le bottom bar
          Padding(
            padding: EdgeInsets.only(bottom: 80.h), // Espace pour le bottom bar
            child: widget.allStatuses.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                      _checkStoredStatus();
                    },
                    itemCount: widget.allStatuses.length,
                    itemBuilder: (context, index) {
                      final status = widget.allStatuses[index];
                      return _VideoPlayerWidget(status: status);
                    },
                  )
                : _VideoPlayerWidget(status: widget.status),
          ),
          // Bottom navigation bar fixe
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: Offset(0, -2.h),
                  ),
                ],
              ),
              child: _buildBottomActions(
                  cubit,
                  widget.allStatuses.isNotEmpty
                      ? widget.allStatuses[_currentIndex]
                      : widget.status),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkStoredStatus() async {
    final cubit = context.read<StatusCubit>();
    final currentStatus = widget.allStatuses.isNotEmpty
        ? widget.allStatuses[_currentIndex]
        : widget.status;
    final isStored = await cubit.isStored(path: currentStatus.path);
    if (mounted) {
      setState(() {
        _isStored = isStored;
      });
    }
  }

  void _handleShare(StatusCubit cubit, Status status) {
    cubit.share(status: status);
    _showActionFeedback('Partage en cours...', Colors.blue);
  }

  void _handleSave(StatusCubit cubit, Status status) async {
    if (!_isStored) {
      cubit.store(status: status);
      await _checkStoredStatus();
      _showActionFeedback('Vidéo sauvegardée', Colors.green);
    }
  }

  void _handleRepost(StatusCubit cubit, Status status) async {
    try {
      // Partager directement vers WhatsApp
      await SocialSharingPlus.shareToSocialMedia(
        SocialPlatform.whatsapp,
        'Statut partagé depuis SnapKeep',
        media: status.path,
        isOpenBrowser: false,
        onAppNotInstalled: () {
          _showActionFeedback(
              'WhatsApp n\'est pas installé sur cet appareil', Colors.red);
        },
      );
      _showActionFeedback('Ouverture de WhatsApp...', Colors.blue);
    } catch (e) {
      _showActionFeedback('Erreur lors du partage: $e', Colors.red);
    }
  }

  Widget _buildBottomActions(StatusCubit cubit, Status status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomActionButton(
            icon: LucideIcons.rotateCcw,
            label: 'Republier',
            onTap: () => _handleRepost(cubit, status),
            color: Colors.blue,
          ),
          _buildBottomActionButton(
            icon: LucideIcons.share2,
            label: 'Partager',
            onTap: () => _handleShare(cubit, status),
            color: Colors.green,
          ),
          _buildBottomActionButton(
            icon: _isStored ? LucideIcons.check : LucideIcons.download,
            label: _isStored ? 'Sauvegardé' : 'Sauvegarder',
            onTap: () => _handleSave(cubit, status),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              LucideIcons.circleCheck,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  const _VideoPlayerWidget({required this.status});

  final Status status;

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController =
          VideoPlayerController.file(File(widget.status.path));
      await _videoPlayerController!.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.blue,
            handleColor: Colors.blue,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.lightBlue,
          ),
        );

        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized && _chewieController != null
        ? Chewie(controller: _chewieController!)
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
