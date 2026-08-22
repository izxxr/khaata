import 'package:drift/drift.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';


/// Repository for managing accounts stored in SQLite database
class AccountRepository {
  const new({required this.db});

  final AppDatabase db;

  /// Creates a new account with given details.
  /// 
  /// Returns the ID of created account.
  Future<int> createAccount(String title, {String? description, AccountColor color = .slate}) async {
    // Account.id is an integer with auto-increment and insert() returns rowid
    // which will be equivalent to Account.id in this case.
    // This will need to be changed if in future, Account.id uses some other scheme
    // of IDs.
    return await db.into(db.account).insert(AccountCompanion.insert(
      title: title,
      description: Value(description),
      color: Value(color.id),
    ));
  }

  /// Streams the list of all accounts stored in database.
  /// 
  /// This uses Drift's watch and streams the accounts once the underlying
  /// accounts data changes.
  Stream<List<AccountData>> watchAccounts() {
    return db.select(db.account).watch();
  }
}
