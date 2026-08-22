import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/app/router.dart';
import 'package:khaata/app/app.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/bloc/app_state.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = await AppState.buildInitialState();
  final appBloc = AppBloc(state);
  final database = AppDatabase();
  final router = createRouter(appBloc);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => AccountRepository(db: database)
        )
      ],
      child: BlocProvider.value(
        value: appBloc,
        child: App(router: router),
      )
    )
  );
}
