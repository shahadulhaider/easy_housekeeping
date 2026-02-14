import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/core/utils/currency_utils.dart';
import 'package:easy_housekeeping/core/utils/date_utils.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/features/dashboard/providers/dashboard_providers.dart';
import 'package:easy_housekeeping/features/household/providers/household_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class HouseholdScreen extends ConsumerStatefulWidget {
  const HouseholdScreen({super.key});

  @override
  ConsumerState<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends ConsumerState<HouseholdScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.household),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/more/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/more/settings'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.members),
            Tab(text: l10n.whosHome),
            Tab(text: l10n.salaryTracker),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_MembersTab(), _WhosHomeTab(), _SalaryTrackerTab()],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showAddMemberDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddMemberSheet(
        onMemberAdded: () {
          ref.invalidate(allMembersForHouseholdProvider);
          ref.invalidate(familyMembersProvider);
          ref.invalidate(staffMembersProvider);
        },
      ),
    );
  }
}

// =============================================================================
// Tab 1: Members
// =============================================================================
class _MembersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final membersAsync = ref.watch(allMembersForHouseholdProvider);

    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(l10n.noMembers, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  l10n.addYourFirstMember,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        // Group by category
        final familyMembers = members
            .where((m) => m.role == 'admin' || m.role == 'family')
            .toList();
        final relativeMembers = members
            .where((m) => m.role == 'relative')
            .toList();
        final guestMembers = members.where((m) => m.role == 'guest').toList();
        final staffMembers = members.where((m) => m.role == 'staff').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (familyMembers.isNotEmpty) ...[
              _sectionHeader(theme, l10n.family),
              const SizedBox(height: 8),
              ...familyMembers.map(
                (m) => _buildMemberCard(context, theme, m, null),
              ),
              const SizedBox(height: 16),
            ],
            if (relativeMembers.isNotEmpty) ...[
              _sectionHeader(theme, l10n.relative),
              const SizedBox(height: 8),
              ...relativeMembers.map(
                (m) => _buildMemberCard(context, theme, m, null),
              ),
              const SizedBox(height: 16),
            ],
            if (guestMembers.isNotEmpty) ...[
              _sectionHeader(theme, l10n.guest),
              const SizedBox(height: 8),
              ...guestMembers.map(
                (m) => _buildMemberCard(context, theme, m, null),
              ),
              const SizedBox(height: 16),
            ],
            if (staffMembers.isNotEmpty) ...[
              _sectionHeader(theme, l10n.staff),
              const SizedBox(height: 8),
              ...staffMembers.map(
                (m) => _buildMemberCard(
                  context,
                  theme,
                  m,
                  () => context.push('/more/staff/${m.id}'),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    ThemeData theme,
    HouseholdMember member,
    VoidCallback? onTap,
  ) {
    final isStaff = member.role == 'staff';
    final icon = switch (member.role) {
      'admin' => Icons.admin_panel_settings,
      'family' => Icons.person,
      'relative' => Icons.people,
      'guest' => Icons.person_add,
      'staff' => Icons.badge,
      _ => Icons.person,
    };
    final containerColor = isStaff
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.primaryContainer;
    final onContainerColor = isStaff
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onPrimaryContainer;

    String subtitle = member.role;
    if (isStaff) {
      final salary = member.monthlySalary ?? 0;
      subtitle =
          '${member.staffRole ?? 'Staff'} · ${CurrencyUtils.formatBDT(salary)}/mo';
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: containerColor,
          child: Icon(icon, color: onContainerColor),
        ),
        title: Text(member.name),
        subtitle: Text(subtitle),
        trailing: isStaff ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}

// =============================================================================
// Tab 2: Who's Home
// =============================================================================
class _WhosHomeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final headcountAsync = ref.watch(todayHeadcountProvider);

    return Center(
      child: headcountAsync.when(
        data: (headcount) {
          final count =
              (headcount?.baseCount ?? 0) + (headcount?.guestCount ?? 0);
          return Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.peopleAtHomeToday,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.nPeople(count),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                        onPressed: count > 0
                            ? () => _saveHeadcount(ref, count - 1)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 24),
                      IconButton.filled(
                        onPressed: () => _saveHeadcount(ref, count + 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }

  Future<void> _saveHeadcount(WidgetRef ref, int newCount) async {
    final db = ref.read(databaseProvider);
    final today = AppDateUtils.startOfDay(DateTime.now());
    await db.upsertHeadcount(
      DailyHeadcountsCompanion(date: Value(today), baseCount: Value(newCount)),
    );
    ref.invalidate(todayHeadcountProvider);
  }
}

// =============================================================================
// Tab 3: Salary Tracker (embedded from salary_tracker_screen)
// =============================================================================
class _SalaryTrackerTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final staffAsync = ref.watch(staffMembersProvider);
    final currentMonth = AppDateUtils.formatMonth(DateTime.now());

    return staffAsync.when(
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

// =============================================================================
// Add Member Bottom Sheet
// =============================================================================
class _AddMemberSheet extends StatefulWidget {
  final VoidCallback onMemberAdded;
  const _AddMemberSheet({required this.onMemberAdded});

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  String _selectedRole = 'family';
  String _selectedStaffRole = 'cook';
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isStaff = _selectedRole == 'staff';

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.addMember,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.memberName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  labelText: l10n.memberRole,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'admin', child: Text(l10n.admin)),
                  DropdownMenuItem(value: 'family', child: Text(l10n.family)),
                  DropdownMenuItem(
                    value: 'relative',
                    child: Text(l10n.relative),
                  ),
                  DropdownMenuItem(value: 'guest', child: Text(l10n.guest)),
                  DropdownMenuItem(value: 'staff', child: Text(l10n.staff)),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedRole = v);
                },
              ),
              if (isStaff) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStaffRole,
                  decoration: InputDecoration(
                    labelText: l10n.staffRole,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'cook', child: Text(l10n.cook)),
                    DropdownMenuItem(
                      value: 'caregiver',
                      child: Text(l10n.caregiver),
                    ),
                    DropdownMenuItem(
                      value: 'assistant',
                      child: Text(l10n.assistant),
                    ),
                    DropdownMenuItem(value: 'driver', child: Text(l10n.driver)),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedStaffRole = v);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _salaryController,
                  decoration: InputDecoration(
                    labelText: l10n.monthlySalaryLabel,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final container = ProviderScope.containerOf(context);
    final db = container.read(databaseProvider);
    final l10n = AppLocalizations.of(context);
    final isStaff = _selectedRole == 'staff';

    final salary = isStaff
        ? double.tryParse(_salaryController.text.trim())
        : null;

    await db.insertMember(
      HouseholdMembersCompanion(
        name: Value(_nameController.text.trim()),
        role: Value(_selectedRole),
        staffRole: isStaff ? Value(_selectedStaffRole) : const Value.absent(),
        monthlySalary: salary != null ? Value(salary) : const Value.absent(),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
      ),
    );

    widget.onMemberAdded();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.memberAdded)));
    }
  }
}
