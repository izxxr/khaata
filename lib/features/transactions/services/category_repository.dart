import 'package:drift/drift.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/common/khaata_colors.dart';

/// Repository for managing categories stored in SQLite database.
class CategoryRepository {
  const new({required this.db});

  final AppDatabase db;

  /// Streams the list of categories.
  Stream<List<Category>> watchCategories() {
    return db.select(db.categories).watch();
  }

  /// Get a category by its ID.
  Future<Category> getCategory(int id) {
    return (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();
  }

  /// Creates a new category with given details.
  /// 
  /// Returns the ID of created category.
  Future<int> createCategory(
    String name,
    {
      KhaataColors? color,
    }
  ) async {
    return await db.into(db.categories).insert(CategoriesCompanion.insert(
      name: name,
      color: color != null ? Value(color.id) : Value.absent(),
    ));
  }

  /// Updates a category.
  Future<void> updateCategory(
    int id,
    {
      String? name,
      KhaataColors? color,
    }
  ) async {
    await (db.update(db.categories)..where((t) => t.id.equals(id))).write(CategoriesCompanion(
      name: name != null ? Value(name) : Value.absent(),
      color: color != null ? Value(color.id) : Value.absent(),
    ));
  }

  /// Deletes a category..
  Future<void> deleteCategory(int id) async {
    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }

  /// Stream all categories sorted by total amount (computed from transactions)
  /// in descending order.
  /// 
  /// The result is list of (Category, int, int) where last two elements are incoming
  /// and (absolute value of) outgoing amounts of corresponding category respectively.
  Stream<List<(Category, int, int)>> watchTopCategories(
    List<int> accountIds, {
    bool sortByIncome = true,
  }) {
    final incomeSum = db.transactions.amount.sum(
      filter: db.transactions.amount.isBiggerThanValue(0),
    );

    final outgoingSum = db.transactions.amount.sum(
      filter: db.transactions.amount.isSmallerThanValue(0),
    );

    var query = db.select(db.categories).join([
      innerJoin(
        db.transactions,
        db.transactions.categoryId.equalsExp(db.categories.id),
      ),
    ]);

    if (accountIds.isNotEmpty) {
      query = query..where(db.transactions.accountId.isIn(accountIds));
    }

    query..addColumns([
        incomeSum,
        outgoingSum,
      ])
      ..groupBy([db.categories.id])
      ..orderBy([
        OrderingTerm(
          expression: sortByIncome ? incomeSum : outgoingSum,
          mode: OrderingMode.desc,
        ),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final category = row.readTable(db.categories);

        final income = row.read(incomeSum) ?? 0;
        final outgoing = row.read(outgoingSum) ?? 0;

        return (
          category,
          income,
          outgoing.abs(),
        );
      }).toList();
    });
}}
