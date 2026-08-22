import 'package:drift/drift.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';


/// Repository for managing accounts stored in SQLite database
class AccountRepository {
  const new({required this.db});

  final AppDatabase db;

  /// Streams the list of all accounts stored in database.
  /// 
  /// This uses Drift's watch and streams the accounts once the underlying
  /// accounts data changes.
  Stream<List<Account>> watchAccounts() {
    return db.select(db.accounts).watch();
  }

  /// Streams the balance computed from account's transactions.
  Stream<int> watchBalance(int accountId) {
    final sum = db.transactions.amount.sum();

    final query = db.selectOnly(db.transactions)
                    ..addColumns([sum])
                    ..where(db.transactions.accountId.equals(accountId));

    return query.map((row) => row.read(sum)!).watchSingle();
  }

  /// Computes the account balance and returns it.
  Future<int> getBalance(int accountId) {
    final sum = db.transactions.amount.sum();

    final query = db.selectOnly(db.transactions)
                    ..addColumns([sum])
                    ..where(db.transactions.accountId.equals(accountId));

    return query.map((row) => row.read(sum)!).getSingle();
  }

  /// Streams the list of all accounts stored in database.
  /// 
  /// This uses Drift's watch and streams the accounts once the underlying
  /// accounts data changes.
  Stream<Account> getAccount(int id) {
    return (db.select(db.accounts)..where((a) => a.id.equals(id))).watchSingle();
  }

  /// Creates a new account with given details.
  /// 
  /// Returns the ID of created account.
  Future<int> createAccount(String title, {String? description, AccountColor color = .slate}) async {
    // Account.id is an integer with auto-increment and insert() returns rowid
    // which will be equivalent to Account.id in this case.
    // This will need to be changed if in future, Account.id uses some other scheme
    // of IDs.
    return await db.into(db.accounts).insert(AccountsCompanion.insert(
      title: title,
      description: Value(description),
      color: Value(color.id),
    ));
  }

  /// Updates an account.
  Future<void> updateAccount(int id, {String? title, String? description, AccountColor? color}) async {
    await (db.update(db.accounts)..where((a) => a.id.equals(id))).write(AccountsCompanion(
      title: title != null ? Value(title) : Value.absent(),
      description: description != null ? Value(description) : Value.absent(),
      color: color != null ? Value(color.id) : Value.absent(),
    ));
  }

  /// Deletes an account.
  Future<void> deleteAccount(int id) async {
    await (db.delete(db.accounts)..where((a) => a.id.equals(id))).go();
  }
}
