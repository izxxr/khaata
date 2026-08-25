import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:khaata/database/tables/account.dart';
import 'package:khaata/database/tables/transaction.dart';
import 'package:khaata/database/tables/category.dart';

part 'database.g.dart';


/// The Drift application database.
@DriftDatabase(tables: [Accounts, Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'khaata',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Enable foreign key constraints in SQLite
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}
