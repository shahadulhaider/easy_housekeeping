import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/core/theme/app_colors.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/core/widgets/empty_state_widget.dart';
import 'package:easy_housekeeping/features/notifications/providers/notification_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final remindersAsync = ref.watch(activeRemindersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_none,
              title: l10n.noNotifications,
              subtitle: l10n.youreAllCaughtUp,
            );
          }

          // Group reminders by type
          final reorder = reminders.where((r) => r.type == 'reorder').toList();
          final warranty = reminders
              .where((r) => r.type == 'warranty')
              .toList();
          final salary = reminders.where((r) => r.type == 'salary').toList();
          final custom = reminders
              .where(
                (r) =>
                    r.type != 'reorder' &&
                    r.type != 'warranty' &&
                    r.type != 'salary',
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (reorder.isNotEmpty) ...[
                Text(
                  l10n.reorderAlerts,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.stockLow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...reorder.map(
                  (r) => _buildNotification(
                    theme,
                    Icons.shopping_cart,
                    r.message,
                    '',
                    AppColors.stockLow,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (warranty.isNotEmpty) ...[
                Text(
                  l10n.warrantyAlerts,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...warranty.map(
                  (r) => _buildNotification(
                    theme,
                    Icons.verified_user,
                    r.message,
                    '',
                    AppColors.warning,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (salary.isNotEmpty) ...[
                Text(
                  l10n.salaryReminders,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...salary.map(
                  (r) => _buildNotification(
                    theme,
                    Icons.payments,
                    r.message,
                    '',
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (custom.isNotEmpty) ...[
                Text(
                  l10n.otherReminders,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...custom.map(
                  (r) => _buildNotification(
                    theme,
                    Icons.notification_important,
                    r.message,
                    '',
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildNotification(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: theme.textTheme.bodySmall)
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () {},
        ),
      ),
    );
  }
}
