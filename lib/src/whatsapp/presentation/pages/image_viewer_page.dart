// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/constants/colors.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    super.key,
    required this.status,
    this.isStored = false,
    this.allStatuses = const [],
    this.currentIndex = 0,
    this.isFromSaved = false,
  });

  final Status status;
  final bool isStored;
  final List<Status> allStatuses;
  final int currentIndex;
  final bool isFromSaved;

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isStored = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: widget.currentIndex);
    _isStored = widget.isStored;

    // Ajouter un listener pour vérifier l'état à chaque changement de page
    _pageController.addListener(_onPageChanged);

    // Si pas depuis Saved, vérifier l'état réel
    if (!widget.isFromSaved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkStoredStatus();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kDarkColor,
          content: Text(
            'Pinch to zoom\nDouble tap to save or share',
            style: TextStyle(
              color: kWhiteColor,
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
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (_pageController.page != null) {
      final newIndex = _pageController.page!.round();
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
        // Vérifier l'état du nouveau statut si pas depuis Saved
        if (!widget.isFromSaved) {
          _checkStoredStatus();
        }
      }
    }
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
                    },
                    itemCount: widget.allStatuses.length,
                    itemBuilder: (context, index) {
                      final status = widget.allStatuses[index];
                      return _buildMediaPage(status, cubit);
                    },
                  )
                : _buildMediaPage(widget.status, cubit),
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

  Widget _buildMediaPage(Status status, StatusCubit cubit) {
    if (status.isVideo) {
      return _VideoPlayerWidget(status: status);
    }

    return _buildImagePage(status, cubit);
  }

  Widget _buildImagePage(Status status, StatusCubit cubit) {
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sharing...',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          );
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
          child: InteractiveViewer(
            child: Center(
              child: Image.file(
                File(status.path),
              ),
            ),
          ),
        ),
      ],
    );
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

  void _handleShare(StatusCubit cubit, Status status) {
    cubit.share(status: status);
    _showActionFeedback('Partage en cours...', Colors.green);
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

  Future<void> _checkStoredStatus() async {
    final cubit = context.read<StatusCubit>();
    final currentStatus = widget.allStatuses.isNotEmpty
        ? widget.allStatuses[_currentIndex]
        : widget.status;
    final isStored = await cubit.isStored(path: currentStatus.path);
    print(
        'ImageViewerPage: _checkStoredStatus for ${currentStatus.path} = $isStored');
    if (mounted) {
      setState(() {
        _isStored = isStored;
      });
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
            icon: _getSaveIcon(),
            label: _getSaveLabel(),
            onTap: () => _handleSave(cubit, status),
            color: _getSaveColor(),
          ),
        ],
      ),
    );
  }

  IconData _getSaveIcon() {
    if (widget.isFromSaved) {
      return LucideIcons.trash2;
    } else if (_isStored) {
      return LucideIcons.circleCheck;
    } else {
      return LucideIcons.download;
    }
  }

  String _getSaveLabel() {
    if (widget.isFromSaved) {
      return 'Supprimer';
    } else if (_isStored) {
      return 'Sauvegardé';
    } else {
      return 'Sauvegarder';
    }
  }

  Color _getSaveColor() {
    if (widget.isFromSaved) {
      return Colors.red;
    } else if (_isStored) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
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

  void _handleSave(StatusCubit cubit, Status status) async {
    // Si c'est un check (statut déjà sauvegardé et pas depuis Saved), ne rien faire
    if (!widget.isFromSaved && _isStored) {
      return; // Ne rien faire - comportement voulu
    }

    if (widget.isFromSaved) {
      // Page Saved - supprimer le statut sauvegardé
      cubit.destroy(path: status.path);
      context.read<StatusBloc>().add(FetchStoredStatuses());
      _showActionFeedback('Image supprimée', Colors.red);
    } else {
      // Pages Images/Videos - statut non sauvegardé - sauvegarder le statut
      cubit.store(status: status);
      setState(() {
        _isStored = true;
      });
      _showActionFeedback('Image sauvegardée', Colors.green);
    }
  }
}

class PopMenu extends StatelessWidget {
  const PopMenu({
    super.key,
    required this.cubit,
    required this.widget,
  });

  final StatusCubit cubit;
  final ImageViewerPage widget;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        LucideIcons.ellipsisVertical,
        color: Colors.white,
        size: 25.sp,
      ),
      onSelected: (value) {
        if (value == 'save') {
          cubit.store(status: widget.status);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kPrimaryColor,
              content: Text(
                'Image saved',
                style: TextStyle(
                  color: kWhiteColor,
                ),
              ),
            ),
          );
        } else if (value == 'share') {
          cubit.share(status: widget.status);
        }
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: 'share',
            child: ListTile(
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
            ),
          ),
          PopupMenuItem(
            value: 'save',
            child: ListTile(
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
            ),
          ),
        ];
      },
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
