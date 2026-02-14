import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';

final activeRemindersProvider = FutureProvider<List<Reminder>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getActiveReminders();
});
