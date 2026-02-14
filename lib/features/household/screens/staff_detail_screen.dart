import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/core/utils/currency_utils.dart';
import 'package:easy_housekeeping/core/utils/date_utils.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/features/household/providers/household_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

final _staffMemberProvider = FutureProvider.family<HouseholdMember?, int>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  final all = await db.getAllMembers();
  return all.where((m) => m.id == id).firstOrNull;
});

class StaffDetailScreen extends ConsumerWidget {
  final int memberId;
  const StaffDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final memberAsync = ref.watch(_staffMemberProvider(memberId));
    final paymentsAsync = ref.watch(staffPaymentsProvider(memberId));

    return memberAsync.when(
      data: (member) {
        if (member == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.staffDetails)),
            body: Center(child: Text(l10n.memberNotFound)),
          );
        }
        final salary = member.monthlySalary ?? 0;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.staffDetails)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        member.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        member.staffRole ?? 'Staff',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${CurrencyUtils.formatBDT(salary)}${l10n.perMonth}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.paymentHistory,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              paymentsAsync.when(
                data: (payments) => payments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.noPayments,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      )
                    : Column(
                        children: payments
                            .map(
                              (p) => Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  title: Text(p.month),
                                  subtitle: p.paidDate != null
                                      ? Text(
                                          l10n.paidOn(
                                            AppDateUtils.formatDate(
                                              p.paidDate!,
                                            ),
                                          ),
                                        )
                                      : Text(l10n.pending),
                                  trailing: Text(
                                    CurrencyUtils.formatBDT(p.amount),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                loading: () => const LoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.payments),
                label: Text(l10n.recordPayment),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.staffDetails)),
        body: const LoadingWidget(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.staffDetails)),
        body: Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }
}
