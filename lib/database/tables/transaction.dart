import 'package:drift/drift.dart';
import 'package:khaata/database/tables/account.dart';


/// Represents a transaction.
class Transactions extends Table {
  /// Unique ID of this transaction.
  IntColumn get id => integer().autoIncrement()();

  /// The ID of account that this transaction belongs to.
  /// 
  /// This is the account that **created** this transaction or the
  /// "source account".
  /// 
  /// In future, if we may add _additional_ transfer type, we may add
  /// destinationAccountId or other fields which must be distinguished
  /// from this.
  IntColumn get accountId => integer().references(Accounts, #id)();

  /// The type of this transaction.
  /// 
  /// For now, this defaults to 0 (default type) and is the only
  /// transaction type available.
  /// 
  /// In future, this will support types like "transfer" etc. -- TODO
  IntColumn get type => integer().withDefault(const Constant(0))();

  /// The amount associated with this transaction in minor units format.
  /// 
  /// Most currencies have 2 decimals so we currently use that for conversion
  /// to/from minor units format:
  /// 
  ///  Actual amount = amount / 10^n
  /// 
  /// Here, n = 2
  /// 
  /// Once currencies are implemented, we may need to separately store the intended
  /// currency and its number of decimals information. - TODO
  IntColumn get amount => integer()();

  /// The transaction's title.
  TextColumn get title => text().withLength(min: 2, max: 32)();

  /// The transaction's optional description.
  TextColumn get description => text().nullable().withLength(min: 0, max: 128)();

  /// The time when this transaction was performed.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
