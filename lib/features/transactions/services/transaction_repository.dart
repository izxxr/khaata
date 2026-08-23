import 'package:drift/drift.dart';
import 'package:khaata/database/database.dart';

/// Repository for managing transactions stored in SQLite database
class TransactionRepository {
  const new({required this.db});

  final AppDatabase db;

  /// Streams the list of all transactions associated to a specific account.
  /// 
  /// This uses Drift's watch and streams the transactions once the underlying
  /// accounts data changes.
  Stream<List<Transaction>> watchTransactions(int? accountId, int? limit) {
    var query = db.select(db.transactions);

    if (accountId != null) {
      query = query..where((t) => t.accountId.equals(accountId));
    }

    if (limit != null) {
      query = query..limit(limit);
    }

    query = query..orderBy([
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
    ]);

    return query.watch();
  }

  /// Gets a transaction from its ID.
  Stream<Transaction> getTransaction(int id) {
    return (db.select(db.transactions)..where((t) => t.id.equals(id))).watchSingle();
  }

  /// Creates a new transaction with given details.
  /// 
  /// Returns the ID of created transaction.
  Future<int> createTransaction(
    int accountId,
    String title,
    int amount,
    {
      String? description,
      DateTime? createdAt
    }
  ) async {
    return await db.into(db.transactions).insert(TransactionsCompanion.insert(
      accountId: accountId,
      title: title,
      amount: amount,
      createdAt: createdAt != null ? Value(createdAt) : Value.absent(),
      description: Value(description),
    ));
  }

  /// Updates a transaction.
  Future<void> updateTransaction(
    int id,
    {
      String? title,
      int? amount,
      String? description,
      DateTime? createdAt,
    }
  ) async {
    await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(TransactionsCompanion(
      title: title != null ? Value(title) : Value.absent(),
      amount: amount != null ? Value(amount) : Value.absent(),
      description: description != null ? Value(description) : Value.absent(),
      createdAt: createdAt != null ? Value(createdAt) : Value.absent(),
    ));
  }

  /// Deletes a transaction..
  Future<void> deleteTransaction(int id) async {
    await (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
