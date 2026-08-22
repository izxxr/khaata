import 'package:drift/drift.dart';


/// Represents a financial account.
class Accounts extends Table {
  /// Unique ID of this account.
  IntColumn get id => integer().autoIncrement()();

  /// The account's title.
  TextColumn get title => text().withLength(min: 2, max: 32)();

  /// The account's optional description.
  TextColumn get description => text().nullable().withLength(min: 0, max: 256)();

  /// The account's display color.
  IntColumn get color => integer().withDefault(const Constant(0))();

  /// The time when this account was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
