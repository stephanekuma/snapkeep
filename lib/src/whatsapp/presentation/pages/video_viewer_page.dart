// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:snapkeep/src/core/constants/colors.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class VideoViewerPage extends StatefulWidget {
  const VideoViewerPage({
    super.key,
    required this.status,
    this.isStored = false,
  });

  final Status status;
  final bool isStored;

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

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
        actions: <Widget>[
          _buildModernActionMenu(cubit),
        ],
      ),
      body: GestureDetector(
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
                      leading: FaIcon(
                        FontAwesomeIcons.shareFromSquare,
                        size: 25.sp,
                      ),
                      title: Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                      onTap: () {
                        cubit.share(status: widget.status);

                        context.router.maybePop();
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.download,
                        size: 25.sp,
                      ),
                      title: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                      onTap: () {
                        cubit.store(status: widget.status);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: kPrimaryColor,
                            content: Text(
                              'Image saved',
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
    );
  }

  Widget _buildModernActionMenu(StatusCubit cubit) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton Share avec animation
          _buildActionButton(
            icon: FontAwesomeIcons.shareFromSquare,
            label: 'Partager',
            onTap: () => _handleShare(cubit),
            color: Colors.blue,
          ),
          SizedBox(width: 12.w),
          // Bouton Save avec animation
          _buildActionButton(
            icon: FontAwesomeIcons.download,
            label: 'Sauvegarder',
            onTap: () => _handleSave(cubit),
            color: Colors.green,
          ),
          SizedBox(width: 8.w),
          // Menu plus d'options
          _buildMoreOptionsMenu(cubit),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                color: Colors.white,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreOptionsMenu(StatusCubit cubit) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: FaIcon(
          FontAwesomeIcons.ellipsisVertical,
          color: Colors.white,
          size: 16.sp,
        ),
      ),
      offset: Offset(0, 50.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      onSelected: (value) {
        switch (value) {
          case 'info':
            _showVideoInfo();
            break;
          case 'delete':
            _showDeleteConfirmation(cubit);
            break;
          case 'favorite':
            _toggleFavorite();
            break;
        }
      },
      itemBuilder: (context) => [
        _buildMenuItem(
          icon: FontAwesomeIcons.circleInfo,
          title: 'Informations',
          subtitle: 'Détails du fichier',
          value: 'info',
        ),
        _buildMenuItem(
          icon: FontAwesomeIcons.heart,
          title: 'Ajouter aux favoris',
          subtitle: 'Marquer comme important',
          value: 'favorite',
        ),
        _buildMenuItem(
          icon: FontAwesomeIcons.trash,
          title: 'Supprimer',
          subtitle: 'Retirer de la galerie',
          value: 'delete',
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : Colors.grey[700];

    return PopupMenuItem<String>(
      value: value,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: FaIcon(
                icon,
                color: color,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleShare(StatusCubit cubit) {
    cubit.share(status: widget.status);
    _showActionFeedback('Partage en cours...', Colors.blue);
  }

  void _handleSave(StatusCubit cubit) {
    cubit.store(status: widget.status);
    _showActionFeedback('Vidéo sauvegardée', Colors.green);
  }

  void _showActionFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.circleCheck,
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
            FaIcon(
              FontAwesomeIcons.circleInfo,
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
            FaIcon(
              FontAwesomeIcons.trash,
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
}
