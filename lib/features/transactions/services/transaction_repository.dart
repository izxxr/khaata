import 'package:drift/drift.dart';
import 'package:khaata/database/database.dart';

/// Repository for managing transactions and associated information
/// stored in SQLite database
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
  Stream<List<(Transaction, $$TransactionsTableReferences)>> watchTransactions(
    int? accountId,
    int? limit,
    {
      bool fetchAccount = false,
      bool fetchCategory = false,
      bool fetchCounterparty = false,
    }
  ) {
    var manager = db.managers.transactions;
    var query =
      accountId != null ?
        manager.filter((f) => f.accountId.id(accountId))
      : manager.filter((f) => f.accountId.isolatedAccount(false));

    query = query.orderBy((o) => o.createdAt.desc());

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.withReferences(
      (pf) => pf(
        accountId: fetchAccount,
        categoryId: fetchCategory,
        counterpartyId: fetchCounterparty
      )
    ).watch();
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
      DateTime? createdAt,
      int? categoryId,
      int? counterpartyId,
    }
  ) async {
    return await db.into(db.transactions).insert(TransactionsCompanion.insert(
      accountId: accountId,
      title: title,
      amount: amount,
      createdAt: createdAt != null ? Value(createdAt) : Value.absent(),
      description: Value(description),
      categoryId: Value(categoryId),
      counterpartyId: Value(counterpartyId),
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
      Value<int?>? categoryId,
      Value<int?>? counterpartyId,
    }
  ) async {
    await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(TransactionsCompanion(
      title: title != null ? Value(title) : Value.absent(),
      amount: amount != null ? Value(amount) : Value.absent(),
      description: description != null ? Value(description) : Value.absent(),
      createdAt: createdAt != null ? Value(createdAt) : Value.absent(),
      categoryId: categoryId ?? Value.absent(),
      counterpartyId: counterpartyId ?? Value.absent(),
    ));
  }

  /// Deletes a transaction..
  Future<void> deleteTransaction(int id) async {
    await (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
