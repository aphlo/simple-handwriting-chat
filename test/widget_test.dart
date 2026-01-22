import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_handwriting_chat/main.dart';

void main() {
  testWidgets('App renders with toolbar buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const SimpleHandwritingChatApp());

    expect(find.byIcon(Icons.undo), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('Settings button opens bottom sheet', (WidgetTester tester) async {
    await tester.pumpWidget(const SimpleHandwritingChatApp());

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Stroke Color'), findsOneWidget);
  });
}
