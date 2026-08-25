import 'package:drift/drift.dart';


/// Represents a category that can be assigned to a transaction.
class Categories extends Table {
  /// Unique ID of this categoriy.
  IntColumn get id => integer().autoIncrement()();

  /// The category's name.
  TextColumn get name => text().withLength(min: 2, max: 32)();

  /// The account's display color.
  IntColumn get color => integer().withDefault(const Constant(0))();
}
