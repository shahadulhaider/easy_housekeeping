import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:easy_housekeeping/data/database/tables/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    ItemCategories,
    Items,
    Locations,
    HouseholdMembers,
    PurchaseEntries,
    PurchaseLineItems,
    ConsumptionLogs,
    DailyHeadcounts,
    StaffPayments,
    Reminders,
    ItemPhotos,
    ServiceHistoryEntries,
    BarcodeCache,
    BazarTemplates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'easy_housekeeping');
  }

  // --- Item Categories ---
  Future<List<ItemCategory>> getAllCategories() => select(itemCategories).get();

  Future<List<ItemCategory>> getCategoriesByType(String type) =>
      (select(itemCategories)..where((c) => c.type.equals(type))).get();

  Future<int> insertCategory(ItemCategoriesCompanion entry) =>
      into(itemCategories).insert(entry);

  // --- Items ---
  Future<List<Item>> getAllItems() => select(items).get();

  Future<List<Item>> getItemsByType(String type) =>
      (select(items)..where((i) => i.type.equals(type))).get();

  Future<List<Item>> getItemsByCategory(int categoryId) =>
      (select(items)..where((i) => i.categoryId.equals(categoryId))).get();

  Future<List<Item>> getItemsBelowMinStock() => (select(
    items,
  )..where((i) => i.currentStock.isSmallerThan(i.minimumStock))).get();

  Future<Item?> getItemByBarcode(String barcode) => (select(
    items,
  )..where((i) => i.barcode.equals(barcode))).getSingleOrNull();

  Future<int> insertItem(ItemsCompanion entry) => into(items).insert(entry);

  Future<bool> updateItem(ItemsCompanion entry) => update(items).replace(entry);

  Future<int> deleteItem(int id) =>
      (delete(items)..where((i) => i.id.equals(id))).go();

  // --- Locations ---
  Future<List<Location>> getAllLocations() => select(locations).get();

  Future<int> insertLocation(LocationsCompanion entry) =>
      into(locations).insert(entry);

  // --- Household Members ---
  Future<List<HouseholdMember>> getAllMembers() =>
      select(householdMembers).get();

  Future<List<HouseholdMember>> getActiveStaff() => (select(
    householdMembers,
  )..where((m) => m.role.equals('staff') & m.isActive.equals(true))).get();

  Future<int> insertMember(HouseholdMembersCompanion entry) =>
      into(householdMembers).insert(entry);

  // --- Purchase Entries ---
  Future<List<PurchaseEntry>> getAllPurchases() => (select(
    purchaseEntries,
  )..orderBy([(p) => OrderingTerm.desc(p.date)])).get();

  Future<List<PurchaseEntry>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  ) =>
      (select(purchaseEntries)
            ..where(
              (p) =>
                  p.date.isBiggerOrEqualValue(start) &
                  p.date.isSmallerOrEqualValue(end),
            )
            ..orderBy([(p) => OrderingTerm.desc(p.date)]))
          .get();

  Future<int> insertPurchase(PurchaseEntriesCompanion entry) =>
      into(purchaseEntries).insert(entry);

  // --- Purchase Line Items ---
  Future<List<PurchaseLineItem>> getLineItemsForPurchase(int purchaseId) =>
      (select(
        purchaseLineItems,
      )..where((l) => l.purchaseEntryId.equals(purchaseId))).get();

  Future<int> insertLineItem(PurchaseLineItemsCompanion entry) =>
      into(purchaseLineItems).insert(entry);

  // --- Consumption Logs ---
  Future<List<ConsumptionLog>> getConsumptionForItem(int itemId) =>
      (select(consumptionLogs)
            ..where((c) => c.itemId.equals(itemId))
            ..orderBy([(c) => OrderingTerm.desc(c.date)]))
          .get();

  Future<int> insertConsumption(ConsumptionLogsCompanion entry) =>
      into(consumptionLogs).insert(entry);

  // --- Daily Headcounts ---
  Future<DailyHeadcount?> getHeadcountForDate(DateTime date) => (select(
    dailyHeadcounts,
  )..where((h) => h.date.equals(date))).getSingleOrNull();

  Future<int> upsertHeadcount(DailyHeadcountsCompanion entry) =>
      into(dailyHeadcounts).insertOnConflictUpdate(entry);

  // --- Staff Payments ---
  Future<List<StaffPayment>> getPaymentsForMember(int memberId) =>
      (select(staffPayments)
            ..where((p) => p.memberId.equals(memberId))
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .get();

  Future<List<StaffPayment>> getPaymentsForMonth(String month) =>
      (select(staffPayments)..where((p) => p.month.equals(month))).get();

  Future<int> insertPayment(StaffPaymentsCompanion entry) =>
      into(staffPayments).insert(entry);

  // --- Reminders ---
  Future<List<Reminder>> getActiveReminders() =>
      (select(reminders)..where((r) => r.isActive.equals(true))).get();

  Future<int> insertReminder(RemindersCompanion entry) =>
      into(reminders).insert(entry);

  // --- Item Photos ---
  Future<List<ItemPhoto>> getPhotosForItem(int itemId) =>
      (select(itemPhotos)..where((p) => p.itemId.equals(itemId))).get();

  Future<int> insertPhoto(ItemPhotosCompanion entry) =>
      into(itemPhotos).insert(entry);

  // --- Service History ---
  Future<List<ServiceHistoryEntry>> getServiceHistory(int itemId) =>
      (select(serviceHistoryEntries)
            ..where((s) => s.itemId.equals(itemId))
            ..orderBy([(s) => OrderingTerm.desc(s.date)]))
          .get();

  Future<int> insertServiceEntry(ServiceHistoryEntriesCompanion entry) =>
      into(serviceHistoryEntries).insert(entry);

  // --- Barcode Cache ---
  Future<BarcodeCacheData?> getCachedBarcode(String barcode) => (select(
    barcodeCache,
  )..where((b) => b.barcode.equals(barcode))).getSingleOrNull();

  Future<int> cacheBarcode(BarcodeCacheCompanion entry) =>
      into(barcodeCache).insertOnConflictUpdate(entry);

  // --- Bazar Templates ---
  Future<List<BazarTemplate>> getAllTemplates() => select(bazarTemplates).get();

  Future<int> insertTemplate(BazarTemplatesCompanion entry) =>
      into(bazarTemplates).insert(entry);
}
