import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:snapkeep/src/core/router/index.dart';

@RoutePage()
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.router.replace(const StatusRoute()),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 22.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: 20.h),
                ListTile(
                  onTap: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.lightBlue,
                        content: Text(
                          'Coming soon...!',
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    );
                  },
                  leading: const FaIcon(
                    FontAwesomeIcons.language,
                  ),
                  title: Text(
                    "Language",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "English",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: 2,
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 25.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  onTap: () {
                    context.router.push(const LightingModeRoute());
                  },
                  leading: FaIcon(
                    FontAwesomeIcons.themeisle,
                    size: 25.sp,
                  ),
                  title: Text(
                    "Lighting",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: RotatedBox(
                    quarterTurns: 2,
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 25.sp,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    context.router.push(const StorageSettingsRoute());
                  },
                  leading: FaIcon(
                    FontAwesomeIcons.hardDrive,
                    size: 25.sp,
                  ),
                  title: Text(
                    "Stockage",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: RotatedBox(
                    quarterTurns: 2,
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 25.sp,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.lightBlue,
                        content: Text(
                          'Coming soon...!',
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    );
                  },
                  leading: FaIcon(
                    FontAwesomeIcons.lock,
                    size: 25.sp,
                  ),
                  title: Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: RotatedBox(
                    quarterTurns: 2,
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 25.sp,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.lightBlue,
                        content: Text(
                          'Coming soon...!',
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    );
                  },
                  leading: FaIcon(
                    FontAwesomeIcons.question,
                    size: 25.sp,
                  ),
                  title: Text(
                    "Help Center",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: RotatedBox(
                    quarterTurns: 2,
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 25.sp,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            )
          ],
        ),
      ),
    );
  }
}
