import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _SectionHeader(l10n.appearance, theme),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.theme),
            subtitle: Text(
              themeMode == ThemeMode.system
                  ? l10n.themeSystem
                  : themeMode == ThemeMode.light
                  ? l10n.themeLight
                  : l10n.themeDark,
            ),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode, size: 18),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (v) =>
                  ref.read(themeModeProvider.notifier).state = v.first,
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          _SectionHeader(l10n.language, theme),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(
              currentLocale?.languageCode == 'bn' ? l10n.bangla : l10n.english,
            ),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'bn', label: Text('বাং')),
              ],
              selected: {currentLocale?.languageCode ?? 'en'},
              onSelectionChanged: (v) =>
                  ref.read(localeProvider.notifier).setLocale(Locale(v.first)),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          _SectionHeader(l10n.dataManagement, theme),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(l10n.manageCategories),
            subtitle: Text(l10n.enableDisableCategories),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.place),
            title: Text(l10n.manageLocations),
            subtitle: Text(l10n.editStorageLocations),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _SectionHeader(l10n.notificationsSection, theme),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: Text(l10n.lowStockAlerts),
            subtitle: Text(l10n.notifyWhenItemsRunLow),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.verified_user),
            title: Text(l10n.warrantyReminders),
            subtitle: Text(l10n.alertBeforeWarrantyExpires),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.payments),
            title: Text(l10n.salaryReminders),
            subtitle: Text(l10n.remindWhenSalaryDue),
            value: true,
            onChanged: (v) {},
          ),
          _SectionHeader(l10n.data, theme),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(l10n.backupData),
            subtitle: Text(l10n.exportDatabase),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l10n.restoreData),
            subtitle: Text(l10n.importFromBackup),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(
              l10n.clearAllData,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: Text(l10n.deleteEverything),
            onTap: () {},
          ),
          _SectionHeader(l10n.about, theme),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.appTitle),
            subtitle: Text(l10n.version),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionHeader(this.title, this.theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
