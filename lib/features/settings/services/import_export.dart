import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';
import 'package:khaata/features/transactions/services/counterparty_repository.dart';
import 'package:khaata/features/transactions/services/category_repository.dart';

final Uuid _generator = Uuid();

Map<String, dynamic> _deserializeWithVID(
  DataClass model,
  Map<int, String> vTable,
  {
    String key = "id",
  }
) {
  final data = model.toJson();

  final actualId = data[key];
  final virtualId = _generator.v4();

  data[key] = virtualId;
  vTable[actualId] = virtualId;

  return data;
}


Map<String, dynamic> _replaceRefsWithVID(Map<String, dynamic> data, Map<String, Map<int, String>> vTables) {
  data = {...data};

  for (var ent in vTables.entries) {
    data[ent.key] = ent.value[data[ent.key]];
  }

  return data;
}


/// Exports all of accounts and transactions data as JSON.
/// 
/// The returned data replaces all auto-increment int IDs with globally unique
/// virtual UUID IDs to allow later importing without conflicting with existing records.
Future<Map<String, dynamic>> buildExportData(BuildContext context) async {
  final accounts = await (context.read<AccountRepository>().watchAccounts()).first;

  if (!context.mounted) return {};
  final transactions = await (context.read<TransactionRepository>().watchTransactions([])).first;

  if (!context.mounted) return {};
  final counterparties = await (context.read<CounterpartyRepository>().watchCounterparties()).first;

  if (!context.mounted) return {};
  final categories = await (context.read<CategoryRepository>().watchCategories()).first;

  // Pass 1: deserialize models to JSON and generate virtual ID tables (actual ID -> virtual ID)
  Map<int, String> accountVIds = {};
  Map<int, String> counterpartyVIds = {};
  Map<int, String> categoryVIds = {};
  Map<int, String> transactionVIds = {};

  var accountsData = accounts.map((a) => _deserializeWithVID(a, accountVIds)).toList();
  var categoriesData = categories.map((c) => _deserializeWithVID(c, categoryVIds)).toList();
  var counterpartiesData = counterparties.map((c) => _deserializeWithVID(c, counterpartyVIds)).toList();
  var transactionsData = transactions.map((t) => _deserializeWithVID(t.$1, transactionVIds)).toList();

  // Pass 2: replace actual IDs for referenced/foreign fields with virtual IDs
  counterpartiesData = counterpartiesData.map(
    (cd) => _replaceRefsWithVID(cd, {"defaultCategoryId": categoryVIds})
  ).toList();

  transactionsData = transactionsData.map(
    (td) => _replaceRefsWithVID(
      td,
      {
        "accountId": accountVIds,
        "categoryId": categoryVIds,
        "counterpartyId": counterpartyVIds,
        "associatedTransactionId": transactionVIds,
      }
    )
  ).toList();

  return {
    "accounts": accountsData,
    "categories": categoriesData,
    "counterparties": counterpartiesData,
    "transactions": transactionsData,
  };
}


Future<void> importData(BuildContext context, Map<String, dynamic> data) async {
  final accounts = data["accounts"]!;
  final accountsRepo = context.read<AccountRepository>();

  var accountIds = {};

  for (var ent in accounts) {
    // remove virtual ID
    final vid = ent.remove("id");
    accountIds[vid] = await accountsRepo.createAccountFromJson(ent);
  }

  if (!context.mounted) return;

  final categories = data["categories"]!;
  final categoriesRepo = context.read<CategoryRepository>();

  var categoryIds = {};

  for (var ent in categories) {
    // remove virtual ID
    final vid = ent.remove("id");
    categoryIds[vid] = await categoriesRepo.createCategoryFromJson(ent);
  }

  if (!context.mounted) return;

  final counterparties = data["counterparties"]!;
  final counterpartiesRepo = context.read<CounterpartyRepository>();

  var counterpartyIds = {};

  for (var ent in counterparties) {
    // remove virtual ID
    final vid = ent.remove("id");

    ent["defaultCategoryId"] = categoryIds[ent["defaultCategoryId"]];
    counterpartyIds[vid] = await counterpartiesRepo.createCounterpartyFromJson(ent);
  }

  if (!context.mounted) return;

  final transactions = data["transactions"]!;
  final transactionsRepo = context.read<TransactionRepository>();

  var transactionIds = {};
  var associatedTransactionIds = {};

  for (var ent in transactions) {
    // remove virtual ID
    final vid = ent.remove("id");
    final associatedVid = ent.remove("associatedTransactionId");

    ent["accountId"] = accountIds[ent["accountId"]];
    ent["categoryId"] = categoryIds[ent["categoryId"]];
    ent["counterpartyId"] = counterpartyIds[ent["counterpartyId"]];

    transactionIds[vid] = await transactionsRepo.createTransactionFromJson(ent);

    // This will have to be included in the second pass on transactions
    // table as all transactions may not be inserted at this point
    if (associatedVid != null) {
      associatedTransactionIds[transactionIds[vid]] = associatedVid;
    }
  }

  // Second pass on transactions - resolve associated transaction IDs
  for (var t in associatedTransactionIds.entries) {
    await transactionsRepo.updateTransaction(
      t.key,
      associatedTransactionId: Value(transactionIds[t.value])
    );
  }
}
