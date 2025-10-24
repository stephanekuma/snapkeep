// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/router/index.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/status_action.dart';

class StatusImage extends StatelessWidget {
  const StatusImage({
    super.key,
    required this.status,
    this.isStored = false,
  });

  final Status status;
  final bool isStored;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(
          ImageViewerRoute(
            status: status,
            isStored: isStored,
          ),
        );
      },
      child: Hero(
        tag: isStored ? 'saved-${status.path}' : status.path,
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
            image: DecorationImage(
              image: FileImage(
                File(status.path),
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: StatusAction(
            status: status,
            isStored: isStored,
          ),
        ),
      ),
    );
  }
}
