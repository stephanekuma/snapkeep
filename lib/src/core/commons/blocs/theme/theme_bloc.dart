import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:snapkeep/src/core/enums/theme_type.dart';

part 'theme_event.dart';
part 'theme_state.dart';

@lazySingleton
class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    on<ChangeThemeEvent>((event, emit) {
      emit(ThemeState(themeMode: _mapThemeTypeToThemeMode(event.themeType)));
    });
  }

  ThemeMode _mapThemeTypeToThemeMode(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
        return ThemeMode.dark;
      case ThemeType.system:
        return ThemeMode.system;
    }
  }

  ThemeType _mapThemeModeToThemeType(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return ThemeType.light;
      case ThemeMode.dark:
        return ThemeType.dark;
      case ThemeMode.system:
        return ThemeType.system;
    }
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    final themeType = ThemeType.values[json['themeType'] as int];

    return ThemeState(themeMode: _mapThemeTypeToThemeMode(themeType));
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return {'themeType': _mapThemeModeToThemeType(state.themeMode).index};
  }
}
