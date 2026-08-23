import 'package:flutter/material.dart';

/// Base event for global application state update.
sealed class AppEvent {}


/// Event invoked when user updates theme from settings.
final class ThemeModeUpdated extends AppEvent {
  ThemeModeUpdated({required this.newThemeMode});

  /// The updated theme mode.
  final ThemeMode newThemeMode;
}

/// Event invoked when user updates the time format from settings.
final class TimeFormatUpdated extends AppEvent {
  TimeFormatUpdated({required this.is24HoursFormat});

  /// The updated theme mode.
  final bool is24HoursFormat;
}

/// Event invoked when a user updates their username.
final class UsernameUpdated extends AppEvent {
  UsernameUpdated({required this.newUsername});

  /// The updated username.
  final String newUsername;
}

/// Event invoked when user completes the onboarding.
final class OnboardingCompleted extends AppEvent {}

/// Event invoked when user completes the onboarding.
final class StateReset extends AppEvent {}
