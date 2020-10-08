import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:GoEXPLORE/core/theme/app_themes.dart';
import 'package:GoEXPLORE/injection_container.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, AppThemeState> {
  final currentThemeIndex = serviceLocator<SharedPreferences>().getInt('theme');

  ThemeBloc(AppThemeState initialState) : super(initialState);

  @override
  AppThemeState get initialState => currentThemeIndex != null
      ? AppThemeState(themeData: appThemes[AppTheme.values[currentThemeIndex]])
      : AppThemeState(themeData: appThemes[AppTheme.light]);

  @override
  Stream<AppThemeState> mapEventToState(
    ThemeEvent event,
  ) async* {
    if (event is ChangeAppTheme) {
      serviceLocator<SharedPreferences>().setInt('theme', event.theme.index);
      yield AppThemeState(themeData: appThemes[event.theme]);
    }
  }
}
