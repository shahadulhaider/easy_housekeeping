import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/app_router.dart';
import 'package:easy_housekeeping/core/theme/app_theme.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/data/services/seed_data_service.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await SeedDataService(db).seedIfEmpty();
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const EasyHousekeepingApp(),
    ),
  );
}

class EasyHousekeepingApp extends ConsumerWidget {
  const EasyHousekeepingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final isFirstLaunch = ref.watch(isFirstLaunchProvider);

    return MaterialApp.router(
      title: 'EasyHousekeeping',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        return isFirstLaunch.when(
          data: (isFirst) {
            if (isFirst && locale == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                router.go('/language-selection');
              });
            }
            return child ?? const SizedBox.shrink();
          },
          loading: () => child ?? const SizedBox.shrink(),
          error: (_, _) => child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
