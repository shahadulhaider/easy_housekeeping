import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:easy_housekeeping/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EasyHousekeepingApp()));
    // Verify the app shell renders with bottom navigation
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
