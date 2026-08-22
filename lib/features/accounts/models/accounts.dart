import 'package:drift/drift.dart';


/// IMPORTANT: Order of enum values must not be changed. New values to be added
/// at the end of the list.
enum AccountColorValues {
  blue,
  sky,
  green,
  emerald,
  amber,
  orange,
  red,
  rose,
  violet,
  fuchsia,
  teal,
  slate,
}


/// Represents a financial account.
class Account extends Table {
  /// Unique ID of this account.
  IntColumn get id => integer().autoIncrement()();

  /// The account's title.
  TextColumn get title => text().withLength(min: 2, max: 32)();

  /// The account's optional description.
  TextColumn get description => text().nullable().withLength(min: 0, max: 256)();

  /// The account's display color.
  IntColumn get color => intEnum<AccountColorValues>()();

  /// The time when this account was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
