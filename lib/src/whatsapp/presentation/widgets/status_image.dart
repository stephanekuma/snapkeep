// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StatusImage extends StatefulWidget {
  const StatusImage({
    super.key,
    required this.status,
    this.isStored = false,
  });

  final Status status;
  final bool isStored;

  @override
  State<StatusImage> createState() => _StatusImageState();
}

class _StatusImageState extends State<StatusImage> {
  bool _isStored = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _isStored = widget.isStored;
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
  void didUpdateWidget(StatusImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status.path != widget.status.path) {
      _checkStoredStatus();
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

    String message = '';

    if (widget.isStored) {
      // Page Saved - supprimer le statut sauvegardé
      cubit.destroy(path: widget.status.path);
      context.read<StatusBloc>().add(FetchStoredStatuses());
      message = 'Image deleted';
    } else {
      // Pages Images/Videos - sauvegarder le statut
      cubit.store(status: widget.status);
      message = 'Image saved';
    }

    // Mettre à jour l'état immédiatement
    setState(() {
      if (widget.isStored) {
        // Page Saved - on supprime, donc _isStored devient false
        _isStored = false;
      } else {
        // Pages Images/Videos - on sauvegarde, donc _isStored devient true
        _isStored = true;
      }
    });

    // Vérifier l'état réel après un court délai
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkStoredStatus();
      }
    });

    if (mounted) {
      _showActionFeedback(message, widget.isStored ? Colors.red : Colors.green);
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
        image: DecorationImage(
          image: FileImage(
            File(widget.status.path),
          ),
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
        ],
      ),
    );
  }
}
