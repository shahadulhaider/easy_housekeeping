import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/core/utils/date_utils.dart';

final monthlyPurchasesProvider = FutureProvider<List<PurchaseEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final start = AppDateUtils.startOfMonth(now);
  final end = AppDateUtils.endOfMonth(now);
  return db.getPurchasesByDateRange(start, end);
});
