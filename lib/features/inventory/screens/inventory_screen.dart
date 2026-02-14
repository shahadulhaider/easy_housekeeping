import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_housekeeping/core/theme/app_colors.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/core/widgets/empty_state_widget.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/features/inventory/providers/inventory_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventory),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.consumables),
            Tab(text: l10n.durables),
            Tab(text: l10n.locations),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsumablesTab(theme),
          _buildDurablesTab(theme),
          _buildLocationsTab(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/inventory/item/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildConsumablesTab(ThemeData theme) {
    final consumablesAsync = ref.watch(consumableItemsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return consumablesAsync.when(
      data: (items) => categoriesAsync.when(
        data: (categories) {
          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.shopping_basket,
              title: AppLocalizations.of(context).noConsumableItems,
              subtitle: AppLocalizations.of(context).tapPlusToAddConsumable,
            );
          }
          final catMap = <int, String>{};
          for (final c in categories) {
            catMap[c.id] = c.nameBn != null
                ? '${c.name} (${c.nameBn})'
                : c.name;
          }
          final grouped = <String, List<Item>>{};
          for (final item in items) {
            final catName =
                catMap[item.categoryId] ??
                AppLocalizations.of(context).uncategorized;
            grouped.putIfAbsent(catName, () => []).add(item);
          }
          final sortedKeys = grouped.keys.toList()..sort();
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: sortedKeys.length,
            itemBuilder: (context, catIdx) {
              final cat = sortedKeys[catIdx];
              final catItems = grouped[cat]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      cat,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...catItems.map((item) => _buildConsumableItem(theme, item)),
                  const Divider(height: 1),
                ],
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildConsumableItem(ThemeData theme, Item item) {
    final ratio = item.minimumStock > 0
        ? (item.currentStock / (item.minimumStock * 3)).clamp(0.0, 1.0)
        : 0.5;
    final daysLeft = item.minimumStock > 0
        ? (item.currentStock / item.minimumStock * 5).round()
        : null;
    final stockColor = ratio < 0.15
        ? AppColors.stockLow
        : ratio < 0.5
        ? AppColors.stockMedium
        : AppColors.stockHigh;
    return ListTile(
      title: Text(item.name),
      subtitle: Row(
        children: [
          Text('${item.currentStock} ${item.unit}'),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: ratio,
              color: stockColor,
              backgroundColor: stockColor.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
      trailing: daysLeft != null
          ? Chip(
              label: Text(
                '~${daysLeft}d',
                style: TextStyle(color: stockColor, fontSize: 12),
              ),
              backgroundColor: stockColor.withValues(alpha: 0.1),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )
          : null,
      onTap: () => context.push('/inventory/item/${item.id}'),
    );
  }

  Widget _buildDurablesTab(ThemeData theme) {
    final durablesAsync = ref.watch(durableItemsProvider);

    return durablesAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.devices,
            title: AppLocalizations.of(context).noDurableItems,
            subtitle: AppLocalizations.of(context).tapPlusToAddDurable,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.devices,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              title: Text(item.name),
              subtitle: Text(item.description ?? ''),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (item.condition != null)
                    Chip(
                      label: Text(
                        item.condition!,
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    ),
                  if (item.warrantyExpiry != null)
                    Text(
                      AppLocalizations.of(context).warrantyDate(
                        '${item.warrantyExpiry!.year}-${item.warrantyExpiry!.month.toString().padLeft(2, '0')}-${item.warrantyExpiry!.day.toString().padLeft(2, '0')}',
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
              onTap: () => context.push('/inventory/item/${item.id}'),
            );
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildLocationsTab(ThemeData theme) {
    final locationsAsync = ref.watch(allLocationsProvider);

    return locationsAsync.when(
      data: (locations) {
        if (locations.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.place,
            title: AppLocalizations.of(context).noLocations,
            subtitle: AppLocalizations.of(context).addLocationsFromSettings,
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: locations.length,
          itemBuilder: (context, i) {
            final loc = locations[i];
            final icon = _locationIcon(loc.name);
            return Card(
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: theme.colorScheme.primary),
                      const Spacer(),
                      Text(
                        loc.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        loc.nameBn ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  IconData _locationIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('kitchen')) return Icons.kitchen;
    if (lower.contains('bedroom')) return Icons.bed;
    if (lower.contains('bathroom')) return Icons.bathroom;
    if (lower.contains('living')) return Icons.living;
    if (lower.contains('store') || lower.contains('pantry')) {
      return Icons.shelves;
    }
    if (lower.contains('balcony')) return Icons.balcony;
    return Icons.place;
  }
}
