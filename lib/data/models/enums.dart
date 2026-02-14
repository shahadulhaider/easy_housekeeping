enum ItemType {
  consumable,
  durable;

  String get label => switch (this) {
    consumable => 'Consumable',
    durable => 'Durable',
  };
}

enum MemberRole {
  admin,
  family,
  staff;

  String get label => switch (this) {
    admin => 'Admin',
    family => 'Family',
    staff => 'Staff',
  };
}

enum StaffRole {
  cook,
  caregiver,
  assistant;

  String get label => switch (this) {
    cook => 'Cook',
    caregiver => 'Baby Caregiver',
    assistant => 'Assistant',
  };
}

enum PaymentType {
  salary,
  advance,
  deduction;

  String get label => switch (this) {
    salary => 'Salary',
    advance => 'Advance',
    deduction => 'Deduction',
  };
}

enum ReminderType {
  reorder,
  warranty,
  salary,
  custom;

  String get label => switch (this) {
    reorder => 'Reorder',
    warranty => 'Warranty',
    salary => 'Salary',
    custom => 'Custom',
  };
}

enum ItemCondition {
  newItem,
  good,
  fair,
  needsRepair,
  replaced;

  String get label => switch (this) {
    newItem => 'New',
    good => 'Good',
    fair => 'Fair',
    needsRepair => 'Needs Repair',
    replaced => 'Replaced',
  };
}
