import 'package:drift/drift.dart';
import 'package:khaata/database/tables/category.dart';

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

  /// The default category that this counterparty maps to.
  IntColumn get defaultCategoryId => integer()
    .references(Categories, #id, onDelete: KeyAction.setNull)
    .nullable()
    .withDefault(const Constant(null))();
}
