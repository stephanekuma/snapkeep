import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmartProgressIndicator extends StatefulWidget {
  final double progress;
  final String? message;
  final bool isIndeterminate;
  final Color? color;
  final Color? backgroundColor;

  const SmartProgressIndicator({
    super.key,
    required this.progress,
    this.message,
    this.isIndeterminate = false,
    this.color,
    this.backgroundColor,
  });

  @override
  State<SmartProgressIndicator> createState() => _SmartProgressIndicatorState();
}

class _SmartProgressIndicatorState extends State<SmartProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(SmartProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.message != null) ...[
            Text(
              widget.message!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
          ],
          SizedBox(
            height: 6.h,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: widget.isIndeterminate ? null : _animation.value,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),
          if (!widget.isIndeterminate) ...[
            SizedBox(height: 8.h),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
