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
}
