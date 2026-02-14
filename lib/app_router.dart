import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';
import 'package:easy_housekeeping/features/dashboard/screens/dashboard_screen.dart';
import 'package:easy_housekeeping/features/inventory/screens/inventory_screen.dart';
import 'package:easy_housekeeping/features/inventory/screens/item_detail_screen.dart';
import 'package:easy_housekeeping/features/inventory/screens/add_item_screen.dart';
import 'package:easy_housekeeping/features/bazar/screens/bazar_list_screen.dart';
import 'package:easy_housekeeping/features/bazar/screens/add_bazar_screen.dart';
import 'package:easy_housekeeping/features/bazar/screens/bazar_detail_screen.dart';
import 'package:easy_housekeeping/features/reports/screens/reports_screen.dart';
import 'package:easy_housekeeping/features/household/screens/household_screen.dart';
import 'package:easy_housekeeping/features/household/screens/staff_detail_screen.dart';
import 'package:easy_housekeeping/features/household/screens/salary_tracker_screen.dart';
import 'package:easy_housekeeping/features/settings/screens/settings_screen.dart';
import 'package:easy_housekeeping/features/notifications/screens/notifications_screen.dart';
import 'package:easy_housekeeping/features/scanner/screens/scanner_screen.dart';
import 'package:easy_housekeeping/features/onboarding/screens/language_selection_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/language-selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventory',
              builder: (context, state) => const InventoryScreen(),
              routes: [
                GoRoute(
                  path: 'item/add',
                  builder: (context, state) => const AddItemScreen(),
                ),
                GoRoute(
                  path: 'item/:id',
                  builder: (context, state) => ItemDetailScreen(
                    itemId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bazar',
              builder: (context, state) => const BazarListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddBazarScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => BazarDetailScreen(
                    purchaseId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const HouseholdScreen(),
              routes: [
                GoRoute(
                  path: 'household',
                  builder: (context, state) => const HouseholdScreen(),
                ),
                GoRoute(
                  path: 'staff/:id',
                  builder: (context, state) => StaffDetailScreen(
                    memberId: int.parse(state.pathParameters['id']!),
                  ),
                ),
                GoRoute(
                  path: 'salary',
                  builder: (context, state) => const SalaryTrackerScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/scanner',
      builder: (context, state) => const ScannerScreen(),
    ),
  ],
);

class _AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _AppShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: l10n.dashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.inventory_2_outlined),
                selectedIcon: const Icon(Icons.inventory_2),
                label: l10n.inventory,
              ),
              NavigationDestination(
                icon: const Icon(Icons.shopping_cart_outlined),
                selectedIcon: const Icon(Icons.shopping_cart),
                label: l10n.bazar,
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: l10n.reports,
              ),
              NavigationDestination(
                icon: const Icon(Icons.more_horiz_outlined),
                selectedIcon: const Icon(Icons.more_horiz),
                label: l10n.more,
              ),
            ],
          );
        },
      ),
    );
  }
}
