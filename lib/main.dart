import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/router.dart';
import 'package:khaata/app/app.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/bloc/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = await AppState.buildInitialState();

  final appBloc = AppBloc(state);
  final router = createRouter(appBloc);

  runApp(
    BlocProvider.value(
      value: appBloc,
      child: App(router: router),
    ),
  );
}
