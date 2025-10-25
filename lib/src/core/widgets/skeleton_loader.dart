import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Widget? child;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.child,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? 8.r,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (widget.baseColor ?? Colors.grey[300]!)
                    .withOpacity(0.6 + (_animation.value * 0.4)),
                (widget.highlightColor ?? Colors.grey[100]!)
                    .withOpacity(0.6 + (_animation.value * 0.4)),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(spacing.w),
      physics: const BouncingScrollPhysics(), // Effet de rebond iOS
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing.w,
        mainAxisSpacing: spacing.w,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SkeletonLoader(
          borderRadius: 8.r,
        );
      },
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(spacing.w),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.w),
          child: SkeletonLoader(
            height: itemHeight.h,
            borderRadius: 8.r,
          ),
        );
      },
    );
  }
}
