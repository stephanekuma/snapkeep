import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CloudSyncManager extends StatefulWidget {
  final bool isEnabled;
  final Function(bool) onSyncToggled;
  final VoidCallback? onSyncNow;

  const CloudSyncManager({
    super.key,
    required this.isEnabled,
    required this.onSyncToggled,
    this.onSyncNow,
  });

  @override
  State<CloudSyncManager> createState() => _CloudSyncManagerState();
}

class _CloudSyncManagerState extends State<CloudSyncManager>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startSync() {
    setState(() {
      _isSyncing = true;
    });
    _animationController.repeat();

    // Simulation de la synchronisation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
        _animationController.stop();
        _animationController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.cloud,
                  size: 20.sp,
                  color: widget.isEnabled ? Colors.blue : Colors.grey,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Synchronisation Cloud',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: widget.isEnabled,
                  onChanged: widget.onSyncToggled,
                ),
              ],
            ),
            if (widget.isEnabled) ...[
              SizedBox(height: 16.h),
              Text(
                'Synchronisez vos médias avec le cloud pour y accéder depuis tous vos appareils.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSyncing ? null : _startSync,
                      icon: _isSyncing
                          ? AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value * 2 * 3.14159,
                                  child: FaIcon(
                                    FontAwesomeIcons.spinner,
                                    size: 16.sp,
                                  ),
                                );
                              },
                            )
                          : FaIcon(
                              FontAwesomeIcons.arrowsRotate,
                              size: 16.sp,
                            ),
                      label: Text(_isSyncing
                          ? 'Synchronisation...'
                          : 'Synchroniser maintenant'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Statut de synchronisation
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _isSyncing
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      _isSyncing
                          ? FontAwesomeIcons.spinner
                          : FontAwesomeIcons.circleCheck,
                      size: 16.sp,
                      color: _isSyncing ? Colors.blue : Colors.green,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _isSyncing
                          ? 'Synchronisation en cours...'
                          : 'Dernière synchronisation: Il y a 2 heures',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _isSyncing ? Colors.blue : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
