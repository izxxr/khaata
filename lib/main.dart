import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/bloc/app_state.dart';
import 'package:khaata/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = await AppState.buildInitialState();

  runApp(
    BlocProvider(
      create: (_) => AppBloc(state),
      child: const App(),
    ),
  );
}
