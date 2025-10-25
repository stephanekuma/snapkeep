// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/router/index.dart';
import 'package:snapkeep/src/core/widgets/loader.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/status_action.dart';
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

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(
          VideoViewerRoute(
            status: widget.status,
            isStored: widget.isStored,
          ),
        );
      },
      child: Container(
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
            StatusAction(
              status: widget.status,
              isStored: widget.isStored,
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
      ),
    );
  }
}
