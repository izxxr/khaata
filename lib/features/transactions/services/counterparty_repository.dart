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

  /// Stream all counterparties sorted by total amount (computed from transactions)
  /// in descending order.
  /// 
  /// The result is list of (Counterparty, int, int) where last two elements are incoming
  /// and (absolute value of) outgoing amounts of corresponding counterparty respectively.
  Stream<List<(Counterparty, int, int)>> watchTopCounterparties(
    List<int> accountIds, {
    bool sortByIncome = true,
    DateTime? after,
    DateTime? before,
  }) {
    final incomeSum = db.transactions.amount.sum(
      filter: db.transactions.amount.isBiggerThanValue(0),
    );

    final outgoingSum = db.transactions.amount.sum(
      filter: db.transactions.amount.isSmallerThanValue(0),
    );

    var query = db.select(db.counterparties).join([
      innerJoin(
        db.transactions,
        db.transactions.counterpartyId.equalsExp(db.counterparties.id),
      ),
    ]);

    if (accountIds.isNotEmpty) {
      query = query..where(db.transactions.accountId.isIn(accountIds));
    }

    if (after != null) {
      query = query..where(db.transactions.createdAt.isBiggerOrEqualValue(after));
    }

    if (before != null) {
      query = query..where(db.transactions.createdAt.isSmallerOrEqualValue(before));
    }

    query..addColumns([
        incomeSum,
        outgoingSum,
      ])
      ..groupBy([db.counterparties.id])
      ..orderBy([
        OrderingTerm(
          expression: sortByIncome ? incomeSum : outgoingSum,
          mode: OrderingMode.desc,
        ),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final counterparty = row.readTable(db.counterparties);

        final income = row.read(incomeSum) ?? 0;
        final outgoing = row.read(outgoingSum) ?? 0;

        return (
          counterparty,
          income,
          outgoing.abs(),
        );
      }).toList();
    });
  }
}
