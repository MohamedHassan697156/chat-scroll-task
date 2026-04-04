import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatscrollchallenge/main.dart';

void main() {
  testWidgets('API key screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatScrollChallenge());

    expect(find.text('Chat Auto-Scroll Challenge'), findsOneWidget);
    expect(find.textContaining('Gemini API key'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Start Chat'), findsOneWidget);
  });
}
