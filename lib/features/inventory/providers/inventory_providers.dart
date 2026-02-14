import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';

final allItemsProvider = FutureProvider<List<Item>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllItems();
});

final consumableItemsProvider = FutureProvider<List<Item>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getItemsByType('consumable');
});

final durableItemsProvider = FutureProvider<List<Item>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getItemsByType('durable');
});

final allCategoriesProvider = FutureProvider<List<ItemCategory>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllCategories();
});

final allLocationsProvider = FutureProvider<List<Location>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllLocations();
});
