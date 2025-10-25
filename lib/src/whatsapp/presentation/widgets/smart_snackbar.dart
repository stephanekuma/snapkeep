import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum SnackBarType { success, error, warning, info }

class SmartSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            FaIcon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static Color _getColorForType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
        return Colors.blue;
    }
  }

  static IconData _getIconForType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return FontAwesomeIcons.circleCheck;
      case SnackBarType.error:
        return FontAwesomeIcons.circleExclamation;
      case SnackBarType.warning:
        return FontAwesomeIcons.triangleExclamation;
      case SnackBarType.info:
        return FontAwesomeIcons.circleInfo;
    }
  }
}
