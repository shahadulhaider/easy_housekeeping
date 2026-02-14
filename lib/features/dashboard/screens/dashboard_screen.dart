import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_housekeeping/core/utils/currency_utils.dart';
import 'package:easy_housekeeping/core/utils/date_utils.dart';
import 'package:easy_housekeeping/core/widgets/stat_card.dart';
import 'package:easy_housekeeping/core/theme/app_colors.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/features/dashboard/providers/dashboard_providers.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _headcount = 6;
  bool _headcountLoaded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lowStockAsync = ref.watch(lowStockItemsProvider);
    final headcountAsync = ref.watch(todayHeadcountProvider);
    final recentPurchasesAsync = ref.watch(recentPurchasesProvider);
    final monthlySpendAsync = ref.watch(monthlySpendProvider);

    // Update headcount from DB once
    if (!_headcountLoaded) {
      headcountAsync.whenData((hc) {
        if (hc != null && !_headcountLoaded) {
          _headcountLoaded = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _headcount = hc.baseCount + hc.guestCount);
            }
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/more/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/more/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(lowStockItemsProvider);
          ref.invalidate(todayHeadcountProvider);
          ref.invalidate(recentPurchasesProvider);
          ref.invalidate(monthlySpendProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeadcountCard(theme, l10n),
            const SizedBox(height: 16),
            Text(
              l10n.runningLow,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: lowStockAsync.when(
                data: (items) => items.isEmpty
                    ? Center(
                        child: Text(
                          l10n.allItemsStocked,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: items.map((item) {
                          final ratio = item.minimumStock > 0
                              ? (item.currentStock / (item.minimumStock * 3))
                                    .clamp(0.0, 1.0)
                              : 0.5;
                          final daysLeft = item.minimumStock > 0
                              ? (item.currentStock / item.minimumStock * 5)
                                    .round()
                              : 0;
                          return _buildLowStockCard(
                            theme,
                            l10n,
                            item.name,
                            '${item.currentStock} ${item.unit}',
                            daysLeft,
                            ratio,
                          );
                        }).toList(),
                      ),
                loading: () => const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.monthlySpend,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: monthlySpendAsync.when(
                    data: (spend) => StatCard(
                      title: l10n.thisMonth,
                      value: CurrencyUtils.formatBDT(spend),
                      icon: Icons.shopping_cart,
                    ),
                    loading: () => StatCard(
                      title: l10n.thisMonth,
                      value: '...',
                      icon: Icons.shopping_cart,
                    ),
                    error: (e, s) => StatCard(
                      title: l10n.thisMonth,
                      value: '—',
                      icon: Icons.shopping_cart,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: recentPurchasesAsync.when(
                    data: (purchases) => StatCard(
                      title: l10n.bazarTrips,
                      value: '${purchases.length}',
                      icon: Icons.store,
                      color: AppColors.secondary,
                    ),
                    loading: () => StatCard(
                      title: l10n.bazarTrips,
                      value: '...',
                      icon: Icons.store,
                      color: AppColors.secondary,
                    ),
                    error: (e, s) => StatCard(
                      title: l10n.bazarTrips,
                      value: '—',
                      icon: Icons.store,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.recentBazar,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            recentPurchasesAsync.when(
              data: (purchases) => Column(
                children: purchases.isEmpty
                    ? [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.noRecentPurchases,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                        ),
                      ]
                    : purchases
                          .map(
                            (p) => _buildRecentBazarCard(
                              theme,
                              AppDateUtils.relativeTime(p.date),
                              p.marketName ?? l10n.unknown,
                              p.totalAmount,
                              p,
                            ),
                          )
                          .toList(),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bazar/add'),
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.addBazar),
      ),
    );
  }

  Widget _buildHeadcountCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.people, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.peopleAtHomeToday,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    l10n.nPeople(_headcount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: () {
                if (_headcount > 1) {
                  setState(() => _headcount--);
                  _saveHeadcount();
                }
              },
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () {
                setState(() => _headcount++);
                _saveHeadcount();
              },
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveHeadcount() {
    final db = ref.read(databaseProvider);
    final today = AppDateUtils.startOfDay(DateTime.now());
    db.upsertHeadcount(
      DailyHeadcountsCompanion(
        date: Value(today),
        baseCount: Value(_headcount),
        guestCount: const Value(0),
      ),
    );
  }

  Widget _buildLowStockCard(
    ThemeData theme,
    AppLocalizations l10n,
    String name,
    String stock,
    int daysLeft,
    double ratio,
  ) {
    final color = daysLeft <= 2
        ? AppColors.stockLow
        : daysLeft <= 5
        ? AppColors.stockMedium
        : AppColors.stockHigh;
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                stock,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: ratio,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.daysLeft(daysLeft),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBazarCard(
    ThemeData theme,
    String date,
    String market,
    double amount,
    PurchaseEntry purchase,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
        ),
        title: Text(market),
        subtitle: Text(date),
        trailing: Text(
          CurrencyUtils.formatBDT(amount),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => context.push('/bazar/${purchase.id}'),
      ),
    );
  }
}
