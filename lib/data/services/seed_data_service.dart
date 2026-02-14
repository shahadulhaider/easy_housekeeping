import 'package:drift/drift.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/data/services/seed_members.dart';

/// Simple data class for household member seed configuration.
class SeedMember {
  final String name;
  final String role;
  final String? staffRole;
  final double? monthlySalary;

  const SeedMember({
    required this.name,
    required this.role,
    this.staffRole,
    this.monthlySalary,
  });
}

/// Seeds the database with initial categories, locations, and household members
/// for a Bangladeshi household setup.
class SeedDataService {
  final AppDatabase db;

  SeedDataService(this.db);

  /// Seeds all reference data if the database is empty.
  /// Checks the itemCategories table as the canary — if it has rows, seeding
  /// is skipped entirely.
  Future<void> seedIfEmpty() async {
    final existingCategories = await db.getAllCategories();
    if (existingCategories.isNotEmpty) return;

    await _seedCategories();
    await _seedLocations();
    await _seedHouseholdMembers();
  }

  Future<void> _seedCategories() async {
    const consumableCategories = [
      ('Rice', 'চাল', 'kg'),
      ('Lentils', 'ডাল', 'kg'),
      ('Spices', 'মশলা', 'pc'),
      ('Cooking Oil', 'তেল', 'ltr'),
      ('Fish', 'মাছ', 'kg'),
      ('Meat', 'মাংস', 'kg'),
      ('Vegetables', 'শাক-সবজি', 'kg'),
      ('Fruits', 'ফল', 'kg'),
      ('Dairy', 'দুধ-দই', 'ltr'),
      ('Beverages', 'পানীয়', 'pc'),
      ('Cleaning Supplies', 'পরিষ্কার', 'pc'),
      ('Toiletries', 'প্রসাধনী', 'pc'),
      ('Baby Supplies', 'শিশু সামগ্রী', 'pc'),
    ];

    const durableCategories = [
      ('Kitchen Equipment', 'রান্নাঘরের সরঞ্জাম', 'pc'),
      ('Electronics', 'ইলেকট্রনিক্স', 'pc'),
      ('Furniture', 'আসবাবপত্র', 'pc'),
    ];

    for (var i = 0; i < consumableCategories.length; i++) {
      final (name, nameBn, unit) = consumableCategories[i];
      await db.insertCategory(
        ItemCategoriesCompanion.insert(
          name: name,
          type: 'consumable',
          nameBn: Value(nameBn),
          defaultUnit: Value(unit),
          sortOrder: Value(i),
        ),
      );
    }

    for (var i = 0; i < durableCategories.length; i++) {
      final (name, nameBn, unit) = durableCategories[i];
      await db.insertCategory(
        ItemCategoriesCompanion.insert(
          name: name,
          type: 'durable',
          nameBn: Value(nameBn),
          defaultUnit: Value(unit),
          sortOrder: Value(consumableCategories.length + i),
        ),
      );
    }
  }

  Future<void> _seedLocations() async {
    const locationData = [
      ('Kitchen', 'রান্নাঘর'),
      ('Bedroom', 'শোবার ঘর'),
      ('Bathroom', 'বাথরুম'),
      ('Living Room', 'বসার ঘর'),
      ('Store Room', 'ভাঁড়ার ঘর'),
      ('Balcony', 'বারান্দা'),
    ];

    for (var i = 0; i < locationData.length; i++) {
      final (name, nameBn) = locationData[i];
      await db.insertLocation(
        LocationsCompanion.insert(
          name: name,
          nameBn: Value(nameBn),
          sortOrder: Value(i),
        ),
      );
    }
  }

  /// Seeds household members from the seed_members.dart configuration.
  /// The member list is defined in seed_members.dart (gitignored for privacy).
  /// See seed_members.example.dart for the expected format.
  Future<void> _seedHouseholdMembers() async {
    final now = DateTime.now();

    for (final member in seedMembers) {
      await db.insertMember(
        HouseholdMembersCompanion.insert(
          name: member.name,
          role: member.role,
          createdAt: now,
          staffRole: Value(member.staffRole),
          monthlySalary: Value(member.monthlySalary),
        ),
      );
    }
  }
}
