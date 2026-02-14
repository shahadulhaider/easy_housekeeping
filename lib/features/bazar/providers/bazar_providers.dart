import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';

final allPurchasesProvider = FutureProvider<List<PurchaseEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllPurchases();
});

final purchaseLineItemsProvider =
    FutureProvider.family<List<PurchaseLineItem>, int>((ref, id) {
      final db = ref.watch(databaseProvider);
      return db.getLineItemsForPurchase(id);
    });

final allMembersProvider = FutureProvider<List<HouseholdMember>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllMembers();
});
