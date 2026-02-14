import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_housekeeping/core/utils/currency_utils.dart';
import 'package:easy_housekeeping/core/utils/date_utils.dart';
import 'package:easy_housekeeping/core/widgets/empty_state_widget.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/features/bazar/providers/bazar_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class BazarListScreen extends ConsumerWidget {
  const BazarListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final purchasesAsync = ref.watch(allPurchasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bazarLog),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: purchasesAsync.when(
        data: (entries) => entries.isEmpty
            ? EmptyStateWidget(
                icon: Icons.shopping_cart_outlined,
                title: l10n.noBazarEntries,
                subtitle: l10n.tapPlusToLogBazar,
                actionLabel: l10n.addBazar,
                onAction: () => context.push('/bazar/add'),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(allPurchasesProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.shopping_bag,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(e.marketName ?? l10n.unknown),
                        subtitle: Text(AppDateUtils.formatDate(e.date)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyUtils.formatBDT(e.totalAmount),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (e.receiptPhotoPath != null)
                              Icon(
                                Icons.receipt_long,
                                size: 16,
                                color: theme.colorScheme.outline,
                              ),
                          ],
                        ),
                        onTap: () => context.push('/bazar/${e.id}'),
                      ),
                    );
                  },
                ),
              ),
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bazar/add'),
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.addBazar),
      ),
    );
  }
}
