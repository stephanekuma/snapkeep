import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnalyticsDashboard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const AnalyticsDashboard({
    super.key,
    required this.stats,
  });

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
                  FontAwesomeIcons.chartLine,
                  size: 20.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Statistiques',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Grille de statistiques
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  context,
                  'Médias totaux',
                  '${stats['totalMedia'] ?? 0}',
                  FontAwesomeIcons.images,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Images',
                  '${stats['images'] ?? 0}',
                  FontAwesomeIcons.image,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Vidéos',
                  '${stats['videos'] ?? 0}',
                  FontAwesomeIcons.video,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  'Espace utilisé',
                  '${stats['storageUsed'] ?? '0'} MB',
                  FontAwesomeIcons.hardDrive,
                  Colors.purple,
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Graphique de progression
            Text(
              'Activité récente',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 12.h),

            // Barres de progression pour les 7 derniers jours
            ...List.generate(7, (index) {
              final day = DateTime.now().subtract(Duration(days: 6 - index));
              final dayName = _getDayName(day.weekday);
              final value = (stats['dailyActivity'] as List?)?[index] ?? 0.0;

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40.w,
                      child: Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: value / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${(value * 10).toInt()}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            icon,
            size: 24.sp,
            color: color,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }
}
