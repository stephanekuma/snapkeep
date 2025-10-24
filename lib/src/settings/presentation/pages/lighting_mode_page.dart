import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:snapkeep/src/core/commons/blocs/theme/theme_bloc.dart';
import 'package:snapkeep/src/core/enums/theme_type.dart';

@RoutePage()
class LightingModePage extends StatelessWidget {
  const LightingModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        ThemeType selectedTheme;
        switch (state.themeMode) {
          case ThemeMode.system:
            selectedTheme = ThemeType.system;
            break;
          case ThemeMode.light:
            selectedTheme = ThemeType.light;
            break;
          case ThemeMode.dark:
            selectedTheme = ThemeType.dark;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Lighting Mode',
              style: TextStyle(
                fontSize: 22.sp,
              ),
            ),
          ),
          body: RadioGroup<ThemeType>(
            groupValue: selectedTheme,
            onChanged: (ThemeType? value) {
              if (value != null) {
                themeBloc.add(ChangeThemeEvent(themeType: value));
              }
            },
            child: const Column(
              children: [
                RadioListTile<ThemeType>(
                  title: Text("Light Theme"),
                  value: ThemeType.light,
                ),
                RadioListTile<ThemeType>(
                  title: Text("Dark Theme"),
                  value: ThemeType.dark,
                ),
                RadioListTile<ThemeType>(
                  title: Text("System Theme"),
                  value: ThemeType.system,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
