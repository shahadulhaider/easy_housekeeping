import 'package:easy_housekeeping/data/database/database.dart';

/// Provides consumption analytics — EMA-based demand forecasting and
/// reorder predictions for household inventory items.
class ConsumptionService {
  final AppDatabase db;

  ConsumptionService(this.db);

  /// Calculates the Exponential Moving Average over a list of daily consumption
  /// values.
  ///
  /// Formula: EMA_today = alpha * actual + (1 - alpha) * EMA_yesterday
  ///
  /// [dailyConsumption] should be ordered oldest-first so the most recent
  /// values have the strongest weight in the final EMA.
  ///
  /// Returns 0.0 if the list is empty.
  double calculateEMA(List<double> dailyConsumption, {double alpha = 0.3}) {
    if (dailyConsumption.isEmpty) return 0.0;

    var ema = dailyConsumption.first;
    for (var i = 1; i < dailyConsumption.length; i++) {
      ema = alpha * dailyConsumption[i] + (1 - alpha) * ema;
    }
    return ema;
  }

  /// Predicts how many days of stock remain for [itemId] based on historical
  /// consumption patterns.
  ///
  /// Optionally adjusts for household headcount changes:
  ///   adjusted = raw_days * (baselineHeadcount / currentHeadcount)
  ///
  /// Returns [double.infinity] when there is no consumption data (item has
  /// never been consumed or the EMA rate is effectively zero).
  Future<double> predictDaysRemaining(
    int itemId, {
    int? currentHeadcount,
    int baselineHeadcount = 5,
  }) async {
    // Fetch consumption logs ordered oldest-first.
    final logs = await db.getConsumptionForItem(itemId);
    if (logs.isEmpty) return double.infinity;

    // getConsumptionForItem returns newest-first, so reverse.
    final sortedLogs = logs.reversed.toList();

    // Aggregate consumption by calendar day.
    final dailyTotals = <DateTime, double>{};
    for (final log in sortedLogs) {
      final day = DateTime(log.date.year, log.date.month, log.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + log.quantity;
    }

    if (dailyTotals.isEmpty) return double.infinity;

    // Build a contiguous daily series (including zero-consumption days)
    // from the first consumption day to the last.
    final sortedDays = dailyTotals.keys.toList()..sort();
    final firstDay = sortedDays.first;
    final lastDay = sortedDays.last;
    final totalDays = lastDay.difference(firstDay).inDays + 1;

    final dailySeries = <double>[];
    for (var i = 0; i < totalDays; i++) {
      final day = firstDay.add(Duration(days: i));
      dailySeries.add(dailyTotals[day] ?? 0.0);
    }

    final emaRate = calculateEMA(dailySeries);
    if (emaRate <= 0) return double.infinity;

    // Get current stock level.
    final allItems = await db.getItemsByCategory(
      (await db.getAllItems()).firstWhere((i) => i.id == itemId).categoryId,
    );
    final item = allItems.firstWhere((i) => i.id == itemId);
    final currentStock = item.currentStock;

    var daysRemaining = currentStock / emaRate;

    // Adjust for headcount if provided.
    if (currentHeadcount != null && currentHeadcount > 0) {
      daysRemaining = daysRemaining * (baselineHeadcount / currentHeadcount);
    }

    return daysRemaining;
  }

  /// Returns all items whose predicted days-remaining falls at or below
  /// [thresholdDays].
  Future<List<Item>> getItemsNeedingReorder({int thresholdDays = 7}) async {
    final allItems = await db.getAllItems();
    final needsReorder = <Item>[];

    for (final item in allItems) {
      final daysLeft = await predictDaysRemaining(item.id);
      if (daysLeft <= thresholdDays) {
        needsReorder.add(item);
      }
    }

    return needsReorder;
  }
}
