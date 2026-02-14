import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/core/utils/currency_utils.dart';
import 'package:easy_housekeeping/core/utils/date_utils.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/features/household/providers/household_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class SalaryTrackerScreen extends ConsumerWidget {
  const SalaryTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final staffAsync = ref.watch(staffMembersProvider);
    final currentMonth = AppDateUtils.formatMonth(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.salaryTracker)),
      body: staffAsync.when(
        data: (staffList) {
          final totalSalary = staffList.fold<double>(
            0,
            (sum, s) => sum + (s.monthlySalary ?? 0),
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        currentMonth,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.totalWithAmount(
                          CurrencyUtils.formatBDT(totalSalary),
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.staffMembers(staffList.length),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...staffList.map((s) => _buildStaffRow(theme, s, l10n)),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStaffRow(
    ThemeData theme,
    HouseholdMember staff,
    AppLocalizations l10n,
  ) {
    final salary = staff.monthlySalary ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                Icons.badge,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.name, style: theme.textTheme.titleSmall),
                  Text(
                    staff.staffRole ?? 'Staff',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatBDT(salary),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(onPressed: () {}, child: Text(l10n.pay)),
          ],
        ),
      ),
    );
  }
}
