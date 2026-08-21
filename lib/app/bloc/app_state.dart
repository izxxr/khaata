import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// The global application state.
/// 
/// For now, this only manages the theme mode settings.
class AppState {
  const AppState({
    required this.themeMode,
    required this.username,
    required this.onboardingComplete,
  });

  /// The app's current theme mode.
  final ThemeMode themeMode;

  /// The username displayed in app.
  final String? username;

  /// Whether the user has completed onboarding steps.
  final bool onboardingComplete;

  /// Copy the app state with provided overrides.
  AppState copyWith({
    ThemeMode? themeMode,
    String? username,
    bool? onboardingComplete,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      username: username ?? this.username,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  /// Builds the initial state from the stored shared preferences.
  static Future<AppState> buildInitialState() async {
    final prefs = await SharedPreferences.getInstance();

    final themeName = prefs.getString('themeMode');
    final username = prefs.getString('username');
    final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

    final themeMode = switch (themeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return AppState(
      themeMode: themeMode,
      username: username,
      onboardingComplete: onboardingComplete
    );
  }
}
