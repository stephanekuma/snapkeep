// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/constants/colors.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StatusAction extends StatelessWidget {
  const StatusAction({
    super.key,
    required this.status,
    this.isStored = false,
  });

  final Status status;
  final bool isStored;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatusCubit>();

    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    String message = '';

                    if (!status.isVideo) {
                      message = isStored ? 'Image deleted' : 'Image saved';
                    } else {
                      message = isStored ? 'Video deleted' : 'Video saved';
                    }

                    if (isStored) {
                      cubit.destroy(path: status.path);

                      context.read<StatusBloc>().add(FetchStoredStatuses());
                    } else {
                      cubit.store(status: status);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: isStored ? Colors.red : kPrimaryColor,
                        content: Text(
                          message,
                          style: TextStyle(
                            color: kWhiteColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    isStored ? LucideIcons.trash2 : LucideIcons.download,
                    color: kWhiteColor,
                    size: 25.sp,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    cubit.share(status: status);
                  },
                  icon: Icon(
                    LucideIcons.share2,
                    color: kWhiteColor,
                    size: 25.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
