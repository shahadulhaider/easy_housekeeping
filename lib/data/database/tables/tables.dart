import 'package:drift/drift.dart';

class ItemCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameBn => text().nullable()();
  TextColumn get type => text()();
  TextColumn get defaultUnit => text().withDefault(const Constant('pc'))();
  TextColumn get icon => text().nullable()();
  IntColumn get parentCategoryId => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameBn => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get barcode => text().nullable()();
  IntColumn get categoryId => integer().references(ItemCategories, #id)();
  IntColumn get locationId => integer().nullable().references(Locations, #id)();
  TextColumn get type => text()();
  TextColumn get photoPath => text().nullable()();
  RealColumn get currentStock => real().withDefault(const Constant(0))();
  TextColumn get unit => text().withDefault(const Constant('pc'))();
  RealColumn get minimumStock => real().withDefault(const Constant(0))();
  RealColumn get defaultPurchaseQty => real().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  RealColumn get price => real().nullable()();
  DateTimeColumn get warrantyExpiry => dateTime().nullable()();
  TextColumn get serialNumber => text().nullable()();
  TextColumn get condition => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class Locations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameBn => text().nullable()();
  IntColumn get parentLocationId => integer().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class HouseholdMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get staffRole => text().nullable()();
  TextColumn get phone => text().nullable()();
  RealColumn get monthlySalary => real().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class PurchaseEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get totalAmount => real()();
  TextColumn get marketName => text().nullable()();
  IntColumn get purchasedById =>
      integer().nullable().references(HouseholdMembers, #id)();
  TextColumn get receiptPhotoPath => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class PurchaseLineItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseEntryId => integer().references(PurchaseEntries, #id)();
  IntColumn get itemId => integer().references(Items, #id)();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get unitPrice => real()();
  RealColumn get totalPrice => real()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
}

class ConsumptionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(Items, #id)();
  RealColumn get quantity => real()();
  DateTimeColumn get date => dateTime()();
  IntColumn get consumedById =>
      integer().nullable().references(HouseholdMembers, #id)();
  IntColumn get headcountAtTime => integer().nullable()();
  TextColumn get notes => text().nullable()();
}

class DailyHeadcounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get baseCount => integer()();
  IntColumn get guestCount => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {date},
  ];
}

class StaffPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get memberId => integer().references(HouseholdMembers, #id)();
  TextColumn get month => text()();
  RealColumn get amount => real()();
  DateTimeColumn get paidDate => dateTime().nullable()();
  TextColumn get type => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  IntColumn get targetItemId => integer().nullable().references(Items, #id)();
  IntColumn get targetMemberId =>
      integer().nullable().references(HouseholdMembers, #id)();
  DateTimeColumn get triggerDate => dateTime().nullable()();
  TextColumn get message => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastNotified => dateTime().nullable()();
}

class ItemPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(Items, #id)();
  TextColumn get photoPath => text()();
  TextColumn get caption => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class ServiceHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(Items, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  RealColumn get cost => real().nullable()();
  TextColumn get provider => text().nullable()();
}

class BarcodeCache extends Table {
  TextColumn get barcode => text()();
  TextColumn get productName => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get categoryHint => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get rawJson => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {barcode};
}

class BazarTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get itemIds => text()();
  DateTimeColumn get createdAt => dateTime()();
}
