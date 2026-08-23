import 'package:drift/drift.dart';
import 'package:khaata/database/database.dart';

/// Repository for managing transactions stored in SQLite database
class TransactionRepository {
  const new({required this.db});

  final AppDatabase db;

  /// Streams the balance computed from account's transactions.
  Stream<int> watchBalance(int? accountId) {
    final sum = db.transactions.amount.sum();

    if (accountId != null) {
      final query = db.selectOnly(db.transactions)
        ..addColumns([sum])
        ..where(
          db.transactions.accountId.equals(accountId),
        );

      return query.map((row) => row.read(sum) ?? 0).watchSingle();
    }

    final query = db.selectOnly(db.transactions).join([
      innerJoin(
        db.accounts,
        db.accounts.id.equalsExp(
          db.transactions.accountId,
        ),
      ),
    ])
      ..addColumns([sum])
      ..where(
        db.accounts.isolatedAccount.equals(false),
      );

    return query.map((row) => row.read(sum) ?? 0).watchSingle();
  }

  /// Streams the list of transactions.
  ///
  /// If [accountId] is provided, returns transactions for that account.
  /// If [accountId] is null, returns transactions from non-isolated accounts.
  Stream<List<Transaction>> watchTransactions(
    int? accountId,
    int? limit,
  ) {
    if (accountId != null) {
      var query = db.select(db.transactions)
        ..where((t) => t.accountId.equals(accountId));

      if (limit != null) {
        query = query..limit(limit);
      }

      query = query
        ..orderBy([
          (t) => OrderingTerm(
            expression: t.createdAt,
            mode: OrderingMode.desc,
          ),
        ]);

      return query.watch();
    }

    final query = db.select(db.transactions).join([
      innerJoin(
        db.accounts,
        db.accounts.id.equalsExp(db.transactions.accountId),
      ),
    ])
      ..where(
        db.accounts.isolatedAccount.equals(false),
      )
      ..orderBy([
        OrderingTerm(
          expression: db.transactions.createdAt,
          mode: OrderingMode.desc,
        ),
      ]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(db.transactions)).toList(),
    );
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
