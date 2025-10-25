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

@RoutePage()
class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    super.key,
    required this.status,
    this.isStored = false,
  });

  final Status status;
  final bool isStored;

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  @override
  void initState() {
    super.initState();

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
  Widget build(BuildContext context) {
    final cubit = context.read<StatusCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Snap Keep',
          style: TextStyle(
            fontSize: 22.sp,
          ),
        ),
        actions: <Widget>[PopMenu(cubit: cubit, widget: widget)],
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
        child: InteractiveViewer(
          child: Center(
            child: Image.file(
              File(widget.status.path),
            ),
          ),
        ),
      ),
    );
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
      icon: FaIcon(
        FontAwesomeIcons.ellipsisVertical,
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
            ),
          ),
          PopupMenuItem(
            value: 'save',
            child: ListTile(
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
            ),
          ),
        ];
      },
    );
  }
}
