import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// The global application state.
/// 
/// For now, this only manages the theme mode settings.
class AppState {
  const AppState({
    required this.themeMode,
  });

  /// The app's current theme mode.
  final ThemeMode themeMode;

  /// Copy the app state with provided overrides.
  AppState copyWith({
    ThemeMode? themeMode
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode
    );
  }

  /// Builds the initial state from the stored shared preferences.
  static Future<AppState> buildInitialState() async {
    final prefs = await SharedPreferences.getInstance();

    final themeName = prefs.getString('themeMode');
    final themeMode = switch (themeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return AppState(themeMode: themeMode);
  }
}
