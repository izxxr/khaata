import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khaata/app/bloc/app_event.dart';
import 'package:khaata/app/bloc/app_state.dart';


/// Bloc for managing the global application state
/// 
/// For now, this bloc only manages the app theme mode.
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(super.initialState){
    on<ThemeModeUpdated>(_onThemeModeUpdated);
    on<UsernameUpdated>(_onUsernameUpdated);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<StateReset>(_onStateReset);
  }

  Future<void> _onThemeModeUpdated(
    ThemeModeUpdated event,
    Emitter<AppState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("themeMode", event.newThemeMode.name);

    emit(state.copyWith(themeMode: event.newThemeMode));
  }

  Future<void> _onUsernameUpdated(
    UsernameUpdated event,
    Emitter<AppState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("username", event.newUsername);

    emit(state.copyWith(username: event.newUsername));
  }

  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<AppState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("onboardingComplete", true);

    emit(state.copyWith(onboardingComplete: true));
  }

  Future<void> _onStateReset(
    StateReset event,
    Emitter<AppState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final state = await AppState.buildInitialState();
    emit(state);
  }
}
