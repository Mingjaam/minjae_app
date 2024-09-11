// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projectflutter/main.dart';

void main() {
  testWidgets('App should start with Calendar tab', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(initialDarkMode: false));
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
  });

  testWidgets('Can navigate to Friends tab', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(initialDarkMode: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person_add), findsOneWidget);
  });
}
