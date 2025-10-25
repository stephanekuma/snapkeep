import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapkeep/src/core/commons/blocs/theme/theme_bloc.dart';
import 'package:snapkeep/src/core/constants/themes.dart';
import 'package:snapkeep/src/core/locator/index.dart';
import 'package:snapkeep/src/core/utils/theme.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';

import 'src/core/router/index.dart';
import 'src/whatsapp/presentation/bloc/status_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final router = AppRouter();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(
      context: context,
      font: "Inter Tight",
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => locator<ThemeBloc>(),
        ),
        BlocProvider(
          create: (_) => locator<StatusBloc>(),
        ),
        BlocProvider(
          create: (_) => locator<StatusCubit>(),
        ),
      ],
      child: ScreenUtilInit(
          designSize: const Size(371, 827),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Snapkeep',
                  themeMode: state.themeMode,
                  theme: lightTheme.copyWith(
                    textTheme: textTheme,
                  ),
                  darkTheme: darkTheme.copyWith(
                    textTheme: textTheme,
                  ),
                  routerConfig: router.config(),
                );
              },
            );
          }),
    );
  }
}
