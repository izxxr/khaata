import 'package:drift/drift.dart';
import 'package:khaata/database/database.dart';

/// Repository for managing transactions and associated information
/// stored in SQLite database
class TransactionRepository {
  const new({required this.db});

  final AppDatabase db;

  /// Streams the balance computed from account's transactions.
  Stream<(int, int, int)> watchAmounts(
    List<int> accountIds, {
      DateTime? after,
      DateTime? before,
    }
  ) {
    final balance = db.transactions.amount.sum();

    final income = db.transactions.amount.sum(
      filter: db.transactions.amount.isBiggerThanValue(0),
    );

    final expense = db.transactions.amount.sum(
      filter: db.transactions.amount.isSmallerThanValue(0),
    );

    var query = db.selectOnly(db.transactions)
      ..addColumns([
        balance,
        income,
        expense,
      ]);
    
    if (accountIds.isNotEmpty) {
      query = query..where(db.transactions.accountId.isIn(accountIds));
    } else {
      query = query..join([
        innerJoin(
          db.accounts,
          db.accounts.id.equalsExp(db.transactions.accountId),
        ),
      ])..where(db.accounts.isolatedAccount.equals(false));
    }

    if (after != null) {
      query = query..where(db.transactions.createdAt.isBiggerOrEqualValue(after));
    }

    if (before != null) {
      query = query..where(db.transactions.createdAt.isSmallerOrEqualValue(before));
    }

    return query.watchSingle().map((row) {
      final totalBalance = row.read(balance) ?? 0;
      final totalIncome = row.read(income) ?? 0;
      final totalExpense = row.read(expense)?.abs() ?? 0;

      return (
        totalBalance,
        totalIncome,
        totalExpense,
      );
    });
  }

  Expression<bool> _composeCategoryCounterpartyConditions(
    $$TransactionsTableFilterComposer f,
    List<int>? categoryIds,
    List<int>? counterpartyIds,
  ) {
    Expression<bool> condition = f.categoryId.id.isNull() | f.counterpartyId.id.isNull();

    if (categoryIds != null) {
      condition |= f.categoryId.id.isIn(categoryIds);
    }

    if (counterpartyIds != null) {
      condition |= f.counterpartyId.id.isIn(counterpartyIds);
    }

    return condition;
  }

  /// Searches and watches the transactions across multiple accounts.
  /// 
  /// If [accountIds] is empty, the transactions across all accounts are
  /// searched. Otherwise, only the transactions of provided accounts are
  /// returned.
  /// 
  /// [limit] controls the maximum number of returned transactions. By
  /// default, this is null which indicates no maximum limit.
  /// 
  /// [before] and [after] are used to include transactions only in
  /// or upto specific time.
  /// 
  /// [counterpartyIds] and [categoryIds] can be provided with IDs list to
  /// only include transactions from those categories or counterparties.
  /// 
  /// [includeIsolatedAccounts] indicates whether to include transactions
  /// from isolated accounts. This parameter is disregarded when [accountIds]
  /// is non-empty. Defaults to false.
  /// 
  /// [fetchAccount], [fetchCategory], and [fetchCounterparty] can be used
  /// to include information of foreign referenced relations with transactions
  /// data.
  Stream<List<(Transaction, $$TransactionsTableReferences)>> watchTransactions(
    List<int> accountIds,
    {
      String? searchQuery,
      int? limit,
      DateTime? after,
      DateTime? before,
      List<int>? categoryIds,
      List<int>? counterpartyIds,
      bool includeIsolatedAccounts = false,
      bool fetchAccount = false,
      bool fetchCategory = false,
      bool fetchCounterparty = false,
    }
  ) {
    searchQuery = (searchQuery ?? "").trim();

    var manager = db.managers.transactions;
    var query =
      accountIds.isNotEmpty ?
        manager.filter((f) => f.accountId.id.isIn(accountIds))
      : manager.filter((f) => f.accountId.isolatedAccount(includeIsolatedAccounts));

    if (after != null) {
      query = query.filter((f) => f.createdAt.isAfter(after));
    }

    if (before != null) {
      query = query.filter((f) => f.createdAt.isBefore(before));
    }

    if (categoryIds != null || counterpartyIds != null) {
      query = query.filter((f) => _composeCategoryCounterpartyConditions(f, categoryIds, counterpartyIds));
    }

    if (searchQuery.isNotEmpty) {
      final search = searchQuery.toLowerCase();

      query = query.filter((f) {
        List<Expression<bool>> conditions = [
          f.title.contains(search, caseInsensitive: true),
          f.description.contains(search, caseInsensitive: true),
        ];

        if ('incoming transaction'.contains(search)) {
          conditions.add((f.title.isNull() | f.title.equals("")) & f.amount.isBiggerThan(0));
        }

        if ('outgoing transaction'.contains(search)) {
          conditions.add((f.title.isNull() | f.title.equals("")) & f.amount.isSmallerThan(0));
        }

        var result = conditions.first;

        for (var c in conditions.skip(1)) {
          result |= c;
        }

        return result;
      });
    }

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
    int amount,
    {
      String? title,
      String? description,
      DateTime? createdAt,
      int? categoryId,
      int? counterpartyId,
    }
  ) async {
    return await db.into(db.transactions).insert(TransactionsCompanion.insert(
      accountId: accountId,
      amount: amount,
      createdAt: createdAt != null ? Value(createdAt) : Value.absent(),
      title: Value(title),
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
