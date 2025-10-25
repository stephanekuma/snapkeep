// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/widgets/loader.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StatusVideo extends StatefulWidget {
  const StatusVideo({
    super.key,
    required this.status,
    this.isStored = false,
  });

  final Status status;
  final bool isStored;

  @override
  State<StatusVideo> createState() => _StatusVideoState();
}

class _StatusVideoState extends State<StatusVideo> {
  String? _thumbnailPath;
  bool _isLoading = true;
  bool _isStored = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _isStored = widget.isStored;
    _loadThumbnail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStoredStatus();
    });

    // Vérifier périodiquement l'état
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _checkStoredStatus();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(StatusVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status.path != widget.status.path) {
      _checkStoredStatus();
    }
  }

  Future<void> _loadThumbnail() async {
    try {
      final cubit = context.read<StatusCubit>();
      final thumbnailPath = await cubit.thumbnail(path: widget.status.path);
      if (mounted) {
        setState(() {
          _thumbnailPath = thumbnailPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkStoredStatus() async {
    final cubit = context.read<StatusCubit>();
    final isStored = await cubit.isStored(path: widget.status.path);
    if (mounted) {
      setState(() {
        _isStored = isStored;
      });
    }
  }

  IconData _getIcon() {
    if (widget.isStored) {
      // Page Saved - toujours afficher poubelle
      return LucideIcons.trash2;
    } else if (_isStored) {
      // Pages Images/Videos - statut déjà sauvegardé - afficher check
      return LucideIcons.circleCheck;
    } else {
      // Pages Images/Videos - statut non sauvegardé - afficher téléchargement
      return LucideIcons.download;
    }
  }

  void _handleAction() async {
    final cubit = context.read<StatusCubit>();

    // Si c'est un check (statut déjà sauvegardé et pas depuis Saved), ne rien faire
    if (!widget.isStored && _isStored) {
      return; // Ne rien faire - comportement voulu
    }

    if (widget.isStored) {
      // Page Saved - afficher modal de confirmation pour suppression
      _showDeleteConfirmation(cubit);
    } else {
      // Pages Images/Videos - sauvegarder le statut directement
      cubit.store(status: widget.status);
      setState(() {
        _isStored = true;
      });
      _showActionFeedback('Vidéo sauvegardée', Colors.green);
    }
  }

  void _showDeleteConfirmation(StatusCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.trash2,
              color: Colors.red,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Supprimer la vidéo ?',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Cette action est irréversible',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text('Annuler'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(cubit);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text('Supprimer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(StatusCubit cubit) {
    cubit.destroy(path: widget.status.path);
    context.read<StatusBloc>().add(FetchStoredStatuses());
    setState(() {
      _isStored = false;
    });
    _showActionFeedback('Vidéo supprimée', Colors.red);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 2.r,
            blurRadius: 6.r,
            offset: Offset(0, 3.h),
          ),
        ],
        image: _thumbnailPath != null && _thumbnailPath!.isNotEmpty
            ? DecorationImage(
                image: FileImage(File(_thumbnailPath!)),
                fit: BoxFit.cover,
              )
            : const DecorationImage(
                image: AssetImage('assets/images/errors/empty.png'),
                fit: BoxFit.cover,
              ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: _handleAction,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: Loader(),
            )
          else
            Center(
              child: Icon(
                LucideIcons.play,
                color: Colors.white,
                size: 35.sp,
              ),
            ),
        ],
      ),
    );
  }
}
