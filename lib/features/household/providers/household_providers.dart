import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';

final allMembersForHouseholdProvider = FutureProvider<List<HouseholdMember>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return db.getAllMembers();
});

final familyMembersProvider = FutureProvider<List<HouseholdMember>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final all = await db.getAllMembers();
  return all.where((m) => m.role != 'staff').toList();
});

final staffMembersProvider = FutureProvider<List<HouseholdMember>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getActiveStaff();
});

final staffPaymentsProvider = FutureProvider.family<List<StaffPayment>, int>((
  ref,
  id,
) {
  final db = ref.watch(databaseProvider);
  return db.getPaymentsForMember(id);
});
