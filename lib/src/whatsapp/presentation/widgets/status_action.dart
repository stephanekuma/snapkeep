// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/constants/colors.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StatusAction extends StatefulWidget {
  const StatusAction({
    super.key,
    required this.status,
    this.isStored = false,
  });

  final Status status;
  final bool isStored;

  @override
  State<StatusAction> createState() => _StatusActionState();
}

class _StatusActionState extends State<StatusAction> {
  bool _isStored = false;

  @override
  void initState() {
    super.initState();
    _isStored = widget.isStored;
    _checkStoredStatus();
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
                  onPressed: () async {
                    String message = '';

                    if (!widget.status.isVideo) {
                      message = _isStored ? 'Image deleted' : 'Image saved';
                    } else {
                      message = _isStored ? 'Video deleted' : 'Video saved';
                    }

                    if (_isStored) {
                      cubit.destroy(path: widget.status.path);
                      context.read<StatusBloc>().add(FetchStoredStatuses());
                    } else {
                      cubit.store(status: widget.status);
                    }

                    await _checkStoredStatus();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor:
                              _isStored ? Colors.red : kPrimaryColor,
                          content: Text(
                            message,
                            style: TextStyle(
                              color: kWhiteColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    _isStored ? LucideIcons.check : LucideIcons.download,
                    color: kWhiteColor,
                    size: 25.sp,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    cubit.share(status: widget.status);
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
