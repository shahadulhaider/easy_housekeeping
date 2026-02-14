import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_housekeeping/core/utils/currency_utils.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/features/household/providers/household_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class HouseholdScreen extends ConsumerWidget {
  const HouseholdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final familyAsync = ref.watch(familyMembersProvider);
    final staffAsync = ref.watch(staffMembersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.more)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.household,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          familyAsync.when(
            data: (members) => Column(
              children: members
                  .map(
                    (m) => _buildMemberCard(
                      theme,
                      m.name,
                      m.role,
                      m.role == 'admin' ? Icons.person : Icons.child_care,
                      null,
                    ),
                  )
                  .toList(),
            ),
            loading: () => const LoadingWidget(),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                l10n.staff,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/more/salary'),
                child: Text(l10n.salaryTrackerArrow),
              ),
            ],
          ),
          const SizedBox(height: 8),
          staffAsync.when(
            data: (staffList) => Column(
              children: staffList
                  .map((s) => _buildStaffCard(context, theme, s))
                  .toList(),
            ),
            loading: () => const LoadingWidget(),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.quickLinks,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/more/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(l10n.notifications),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/more/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    ThemeData theme,
    String name,
    String role,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(name),
        subtitle: Text(role),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStaffCard(
    BuildContext context,
    ThemeData theme,
    HouseholdMember staff,
  ) {
    final salary = staff.monthlySalary ?? 0;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            Icons.badge,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(staff.name),
        subtitle: Text(
          '${staff.staffRole ?? 'Staff'} · ${CurrencyUtils.formatBDT(salary)}/mo',
        ),
        trailing: Chip(
          label: Text(
            AppLocalizations.of(context).active,
            style: TextStyle(fontSize: 11, color: Colors.green),
          ),
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        onTap: () => context.push('/more/staff/${staff.id}'),
      ),
    );
  }
}
