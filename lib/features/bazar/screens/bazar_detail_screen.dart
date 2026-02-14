import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/core/utils/currency_utils.dart';
import 'package:easy_housekeeping/core/utils/date_utils.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/features/bazar/providers/bazar_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

final _purchaseDetailProvider = FutureProvider.family<PurchaseEntry?, int>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  final all = await db.getAllPurchases();
  return all.where((p) => p.id == id).firstOrNull;
});

class BazarDetailScreen extends ConsumerWidget {
  final int purchaseId;
  const BazarDetailScreen({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final purchaseAsync = ref.watch(_purchaseDetailProvider(purchaseId));
    final lineItemsAsync = ref.watch(purchaseLineItemsProvider(purchaseId));

    return purchaseAsync.when(
      data: (purchase) {
        if (purchase == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.bazarDetails)),
            body: Center(child: Text(l10n.purchaseNotFound)),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.bazarDetails),
            actions: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.store, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              purchase.marketName ?? l10n.unknown,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppDateUtils.formatDate(purchase.date),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.items,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              lineItemsAsync.when(
                data: (lineItems) => lineItems.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.noLineItemsRecorded,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      )
                    : Column(
                        children: lineItems
                            .map(
                              (li) => ListTile(
                                title: Text('Item #${li.itemId}'),
                                subtitle: Text(
                                  '${li.quantity} ${li.unit} × ${CurrencyUtils.formatBDT(li.unitPrice)} ${l10n.each}',
                                ),
                                trailing: Text(
                                  CurrencyUtils.formatBDT(li.totalPrice),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                loading: () => const LoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.total,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatBDT(purchase.totalAmount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.receiptPhoto,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.bazarDetails)),
        body: const LoadingWidget(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.bazarDetails)),
        body: Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }
}
