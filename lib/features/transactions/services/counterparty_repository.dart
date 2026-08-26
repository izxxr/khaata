import 'package:drift/drift.dart';
import 'package:khaata/database/database.dart';

/// Repository for managing categories stored in SQLite database.
class CounterpartyRepository {
  const new({required this.db});

  final AppDatabase db;

  /// Streams the list of counterparties.
  Stream<List<Counterparty>> watchCounterparties() {
    return db.select(db.counterparties).watch();
  }

  /// Creates a new counterparty with given details.
  /// 
  /// Returns the ID of created counterparty.
  Future<int> createCounterparty(
    String name,
    {
      String? description
    }
  ) async {
    return await db.into(db.counterparties).insert(CounterpartiesCompanion.insert(
      name: name,
      description: Value(description),
    ));
  }

  /// Updates a counterparty.
  Future<void> updateCounterparty(
    int id,
    {
      String? name,
      String? description,
    }
  ) async {
    await (db.update(db.counterparties)..where((t) => t.id.equals(id))).write(CounterpartiesCompanion(
      name: name != null ? Value(name) : Value.absent(),
      description: description != null ? Value(description) : Value.absent(),
    ));
  }

  /// Deletes a counterparty.
  Future<void> deleteCounterparty(int id) async {
    await (db.delete(db.counterparties)..where((c) => c.id.equals(id))).go();
  }
}
