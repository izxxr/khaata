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
  }

  Future<void> _onThemeModeUpdated(
    ThemeModeUpdated event,
    Emitter<AppState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("themeMode", event.newThemeMode.name);

    emit(state.copyWith(themeMode: event.newThemeMode));
  }
}
