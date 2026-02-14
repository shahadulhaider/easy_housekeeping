import 'package:easy_housekeeping/data/services/seed_data_service.dart';

/// Example household member seed data.
/// Copy this file to seed_members.dart and fill in your real family details.
///
/// Roles: 'admin', 'family', 'staff'
/// Staff roles: 'cook', 'caregiver', 'assistant'
const List<SeedMember> seedMembers = [
  // Admins (primary app users)
  SeedMember(name: 'Admin User', role: 'admin'),
  SeedMember(name: 'Spouse', role: 'admin'),

  // Family members
  SeedMember(name: 'Child', role: 'family'),

  // Staff (optional — remove if you don't have household staff)
  SeedMember(
    name: 'Cook',
    role: 'staff',
    staffRole: 'cook',
    monthlySalary: 8000,
  ),
  SeedMember(
    name: 'Caregiver',
    role: 'staff',
    staffRole: 'caregiver',
    monthlySalary: 7000,
  ),
  SeedMember(
    name: 'Assistant',
    role: 'staff',
    staffRole: 'assistant',
    monthlySalary: 5000,
  ),
];
