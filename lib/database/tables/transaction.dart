import 'package:drift/drift.dart';
import 'package:khaata/common/helpers.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/database/tables/account.dart';
import 'package:khaata/database/tables/category.dart';
import 'package:khaata/database/tables/counterparty.dart';


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
  IntColumn get accountId => integer()
    .references(Accounts, #id, onDelete: KeyAction.cascade)();

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
  TextColumn get title => text()
    .withLength(min: 0, max: 32)
    .nullable()
    .withDefault(const Constant(null))();

  /// The transaction's optional description.
  TextColumn get description => text().nullable().withLength(min: 0, max: 128)();

  /// The time when this transaction was performed.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// The category's ID that this transaction is assigned to, if any.
  IntColumn get categoryId => integer()
    .references(Categories, #id, onDelete: KeyAction.setNull)
    .withDefault(const Constant(null))
    .nullable()();

  /// The ID of counterparty in this transaction.
  IntColumn get counterpartyId => integer()
    .references(Counterparties, #id, onDelete: KeyAction.setNull)
    .withDefault(const Constant(null))
    .nullable()();

  /// The ID of other transaction that is associated to this.
  /// 
  /// This is the ID of transaction that either created this
  /// transaction or was created by this transaction. For example,
  /// in the case of transfers, this indicates the corresponding
  /// transaction in destination account or source account.
  IntColumn get associatedTransactionId => integer()
    .references(Transactions, #id, onDelete: KeyAction.cascade)
    .withDefault(const Constant(null))
    .nullable()();
}


extension TransactionExtension on Transaction {
  /// Parses the transaction amount using [helpers.parseTransactionAmount] function.
  String parseAmount({ bool stripSign = false }) {
    return parseTransactionAmount(amount, stripSign: stripSign);
  }

  /// Gets the title for this transaction.
  /// 
  /// This returns a default title if the transaction has no
  /// user defined title.
  String getTitle() {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }

    if (amount > 0) {
      return "Incoming transaction";
    }

    return "Outgoing transaction";
  }
}
