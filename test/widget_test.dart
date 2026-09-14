import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyai_app/core/widgets/studyai_logo.dart';

void main() {
  testWidgets('StudyAI wordmark renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: StudyAIWordmark())),
      ),
    );
    expect(find.byType(StudyAIWordmark), findsOneWidget);
  });
}
