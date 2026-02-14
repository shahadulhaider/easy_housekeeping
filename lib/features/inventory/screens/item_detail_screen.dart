import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/core/utils/currency_utils.dart';
import 'package:easy_housekeeping/core/utils/date_utils.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/core/theme/app_colors.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

final _itemDetailProvider = FutureProvider.family<Item?, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  final items = await db.getAllItems();
  return items.where((i) => i.id == id).firstOrNull;
});

final _itemConsumptionProvider =
    FutureProvider.family<List<ConsumptionLog>, int>((ref, id) {
      final db = ref.watch(databaseProvider);
      return db.getConsumptionForItem(id);
    });

class ItemDetailScreen extends ConsumerWidget {
  final int itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final itemAsync = ref.watch(_itemDetailProvider(itemId));
    final consumptionAsync = ref.watch(_itemConsumptionProvider(itemId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.itemDetail)),
            body: Center(child: Text(l10n.itemNotFound)),
          );
        }
        final ratio = item.minimumStock > 0
            ? (item.currentStock / (item.minimumStock * 3)).clamp(0.0, 1.0)
            : 0.5;
        final daysLeft = item.minimumStock > 0
            ? (item.currentStock / item.minimumStock * 5).round()
            : 0;
        final stockColor = ratio < 0.15
            ? AppColors.stockLow
            : ratio < 0.5
            ? AppColors.stockMedium
            : AppColors.stockHigh;

        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
            actions: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        l10n.currentStock,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${item.currentStock} ${item.unit}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: ratio,
                        color: stockColor,
                        backgroundColor: stockColor.withValues(alpha: 0.2),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.daysRemaining(daysLeft),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.consumptionLast30Days,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: consumptionAsync.when(
                  data: (logs) {
                    if (logs.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.noConsumptionData,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      );
                    }
                    final spots = List.generate(
                      logs.length.clamp(0, 30),
                      (i) => FlSpot(i.toDouble(), logs[i].quantity),
                    );
                    return LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: theme.colorScheme.primary,
                            barWidth: 2,
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const LoadingWidget(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
              if (item.price != null) ...[
                const SizedBox(height: 16),
                Text(l10n.purchaseHistory, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(AppDateUtils.formatDate(item.updatedAt)),
                  subtitle: Text('${item.currentStock} ${item.unit}'),
                  trailing: Text(
                    CurrencyUtils.formatBDT(item.price!),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.remove_circle_outline),
                label: Text(l10n.recordConsumption),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.itemDetail)),
        body: const LoadingWidget(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.itemDetail)),
        body: Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }
}
