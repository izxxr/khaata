import 'package:flutter/material.dart';

/// Base event for global application state update.
sealed class AppEvent {}


/// Event invoked when user updates theme from settings.
final class ThemeModeUpdated extends AppEvent {
  ThemeModeUpdated({required this.newThemeMode});

  /// The updated theme mode.
  final ThemeMode newThemeMode;
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
