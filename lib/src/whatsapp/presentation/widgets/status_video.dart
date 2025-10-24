// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:snapkeep/src/core/router/index.dart';
import 'package:snapkeep/src/core/widgets/loader.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/status_action.dart';

class StatusVideo extends StatelessWidget {
  const StatusVideo({
    super.key,
    required this.status,
    this.isStored = false,
  });

  final Status status;
  final bool isStored;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatusCubit>();

    return GestureDetector(
      onTap: () {
        context.router.push(
          VideoViewerRoute(
            status: status,
            isStored: isStored,
          ),
        );
      },
      child: FutureBuilder<String>(
        future: cubit.thumbnail(path: status.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          return snapshot.hasData && snapshot.data != null
              ? Hero(
                  tag: isStored
                      ? 'saved-video-${status.path}'
                      : 'video-${status.path}',
                  child: Stack(
                    children: <Widget>[
                      Container(
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
                              File(snapshot.data!),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: StatusAction(
                          status: status,
                          isStored: isStored,
                        ),
                      ),
                      Center(
                        child: FaIcon(
                          FontAwesomeIcons.play,
                          color: Colors.white,
                          size: 35.sp,
                        ),
                      ),
                    ],
                  ),
                )
              : const Loader();
        },
      ),
    );
  }
}
