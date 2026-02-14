import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/core/utils/date_utils.dart';

final lowStockItemsProvider = FutureProvider<List<Item>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getItemsBelowMinStock();
});

final todayHeadcountProvider = FutureProvider<DailyHeadcount?>((ref) {
  final db = ref.watch(databaseProvider);
  final today = AppDateUtils.startOfDay(DateTime.now());
  return db.getHeadcountForDate(today);
});

final recentPurchasesProvider = FutureProvider<List<PurchaseEntry>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final all = await db.getAllPurchases();
  return all.take(5).toList();
});

final monthlySpendProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final start = AppDateUtils.startOfMonth(now);
  final end = AppDateUtils.endOfMonth(now);
  final purchases = await db.getPurchasesByDateRange(start, end);
  return purchases.fold<double>(0, (sum, p) => sum + p.totalAmount);
});
