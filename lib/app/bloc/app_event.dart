import 'package:flutter/material.dart';

/// Base event for global application state update.
sealed class AppEvent {}


/// Event invoked when user updates theme from settings.
final class ThemeModeUpdated extends AppEvent {
  ThemeModeUpdated({required this.newThemeMode});

  /// The updated theme mode.
  final ThemeMode newThemeMode;
}
