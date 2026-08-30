import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:khaata/database/tables/account.dart';
import 'package:khaata/database/tables/transaction.dart';
import 'package:khaata/database/tables/category.dart';
import 'package:khaata/database/tables/counterparty.dart';

import 'database.steps.dart';
part 'database.g.dart';


/// The Drift application database.
@DriftDatabase(tables: [Accounts, Transactions, Categories, Counterparties])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

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
    onUpgrade: _schemaUpgrade
  );
}


extension Migrations on GeneratedDatabase {
  OnUpgrade get _schemaUpgrade => stepByStep(
    from1To2: (m, schema) async {
      // From v1 to v2, transactions.account_id foreign key constraint changed
      // to include ON DELETE CASCADE. However, Drift's alterTable() does not
      // carry forward this change. So, for this migration, we are using manual
      // table rebuild.

      await m.createTable(schema.categories);
      await m.createTable(schema.counterparties);

      await customStatement('''
        CREATE TABLE transactions_new (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          account_id INTEGER NOT NULL
            REFERENCES accounts(id) ON DELETE CASCADE,
          type INTEGER NOT NULL DEFAULT 0,
          amount INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NULL,
          created_at INTEGER NOT NULL
            DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
          category_id INTEGER
            NULL DEFAULT NULL REFERENCES categories(id) ON DELETE SET NULL,
          counterparty_id INTEGER
            NULL DEFAULT NULL REFERENCES counterparties(id) ON DELETE SET NULL
        )
      ''');

      await customStatement('''
        INSERT INTO transactions_new (
          id,
          account_id,
          type,
          amount,
          title,
          description,
          created_at
        )
        SELECT
          id,
          account_id,
          type,
          amount,
          title,
          description,
          created_at
        FROM transactions
      ''');

      await customStatement('DROP TABLE transactions');

      await customStatement('''
        ALTER TABLE transactions_new
        RENAME TO transactions
      ''');
    },
  );
}