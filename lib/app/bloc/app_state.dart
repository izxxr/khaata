import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  /// Format the time according to user's preferred format.
  String formatDateTime(DateTime dt, {bool shorten = true}) {
    final now = DateTime.now();

    String dateFmt = "";

    if (shorten && dt.month == now.month && dt.year == now.year) {
      int delta = now.day - dt.day;

      if (dt.day == now.day) { dateFmt = "'Today'"; }
      else if (dt.day == now.day - 1) { dateFmt = "'Yesterday'"; }
      else if (delta > 0 && delta <= 3) { dateFmt = "'$delta days ago'"; }
      else { dateFmt = "dd MMM yyy"; }
    } else {
      dateFmt = "dd MMM yyy";
    }

    return DateFormat("$dateFmt, hh:mm a").format(dt);
  }

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
