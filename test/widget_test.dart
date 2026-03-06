// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:diary/main.dart';

void main() {
  testWidgets('Landing page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MindfulDiaryApp());

    // Verify that the title is present.
    expect(find.text('Mindful Diary'), findsOneWidget);

    // Verify that the hero text is present.
    expect(find.text('Your Personal\nTimeless Diary'), findsOneWidget);

    // Verify main feature cards.
    expect(find.text('Daily Journal'), findsOneWidget);
    expect(find.text('Voice Entries'), findsOneWidget);
    expect(find.text('Insights & Analytics'), findsOneWidget);

    // Verify the "3 Simple Steps" section heading.
    expect(find.text('Start Your Journey in 3\nSimple Steps'), findsOneWidget);

    // Verify the final CTA button.
    expect(find.text('Create Your Diary'), findsNWidgets(2)); // One in badge (if text matches) or final CTA
  });
}
