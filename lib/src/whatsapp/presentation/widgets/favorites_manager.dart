import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';

class FavoritesManager extends StatefulWidget {
  final Status status;
  final bool isFavorite;
  final Function(bool) onFavoriteChanged;

  const FavoritesManager({
    super.key,
    required this.status,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<FavoritesManager> createState() => _FavoritesManagerState();
}

class _FavoritesManagerState extends State<FavoritesManager>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onFavoriteChanged(!widget.isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: IconButton(
              onPressed: _toggleFavorite,
              icon: FaIcon(
                widget.isFavorite
                    ? FontAwesomeIcons.solidHeart
                    : FontAwesomeIcons.heart,
                color: widget.isFavorite ? Colors.red : Colors.grey[600],
                size: 20.sp,
              ),
            ),
          ),
        );
      },
    );
  }
}
