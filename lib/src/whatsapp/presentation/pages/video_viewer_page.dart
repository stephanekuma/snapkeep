// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  bool _isInitialized = false;
  bool _isStored = false;
  late PageController _pageController;
  late int _currentIndex;

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
            'Double tap to save or share',
            style: TextStyle(
              color: kWhiteColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      videoPlayerController = VideoPlayerController.file(
        File(widget.status.path),
      );
      await videoPlayerController!.initialize();

      if (mounted) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          autoInitialize: true,
          autoPlay: true,
          looping: true,
          errorBuilder: (context, errorMessage) => Center(
            child: Text(errorMessage),
          ),
        );
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement de la vidéo: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatusCubit>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        elevation: 0,
        title: Text(
          'Snap Keep',
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
                      return _buildVideoPage(status, cubit);
                    },
                  )
                : _buildVideoPage(widget.status, cubit),
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

  Widget _buildVideoPage(Status status, StatusCubit cubit) {
    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: () {
            showModalBottomSheet(
              enableDrag: false,
              showDragHandle: true,
              context: context,
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 30.w,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          LucideIcons.share2,
                          size: 25.sp,
                        ),
                        title: Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                        onTap: () {
                          cubit.share(status: status);
                          context.router.maybePop();
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          LucideIcons.download,
                          size: 25.sp,
                        ),
                        title: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                        onTap: () {
                          cubit.store(status: status);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: kPrimaryColor,
                              content: Text(
                                'Video saved',
                                style: TextStyle(
                                  color: kWhiteColor,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          );
                          context.router.maybePop();
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          },
          child: _isInitialized && chewieController != null
              ? Chewie(controller: chewieController!)
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }

  void _handleShare(StatusCubit cubit, Status status) {
    cubit.share(status: status);
    _showActionFeedback('Partage en cours...', Colors.blue);
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

  void _handleSave(StatusCubit cubit, Status status) async {
    if (!_isStored) {
      cubit.store(status: status);
      await _checkStoredStatus();
      _showActionFeedback('Vidéo sauvegardée', Colors.green);
    }
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

  void _showVideoInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              LucideIcons.info,
              color: Colors.blue,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Informations',
              style: TextStyle(fontSize: 18.sp),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Nom', widget.status.path.split('/').last),
            _buildInfoRow('Taille',
                '${(File(widget.status.path).lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB'),
            _buildInfoRow('Type', 'Vidéo'),
            _buildInfoRow(
                'Statut', widget.isStored ? 'Sauvegardé' : 'Temporaire'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(StatusCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              LucideIcons.trash2,
              color: Colors.red,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Supprimer',
              style: TextStyle(fontSize: 18.sp),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette vidéo ? Cette action est irréversible.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.destroy(path: widget.status.path);
              _showActionFeedback('Vidéo supprimée', Colors.red);
              context.router.maybePop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Supprimer',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite() {
    _showActionFeedback('Ajouté aux favoris', Colors.orange);
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
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
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
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
