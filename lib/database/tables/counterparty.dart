import 'package:drift/drift.dart';


/// Represents a category that can be assigned to a transaction.
class Counterparties extends Table {
  /// Unique ID of this counterparty.
  IntColumn get id => integer().autoIncrement()();

  /// The counterparty's name.
  TextColumn get name => text().withLength(min: 2, max: 32)();

  /// The counterparty's optional description.
  TextColumn get description => text()
    .nullable()
    .withDefault(const Constant(null))
    .withLength(min: 0, max: 256)();
}
