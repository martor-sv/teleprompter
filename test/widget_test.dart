import 'package:flutter_test/flutter_test.dart';
import 'package:teleprompter/main.dart';

void main() {
  testWidgets('TeleprompterApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TeleprompterApp());
    expect(find.text('PromptSmart Pro 提词器'), findsOneWidget);
  });
}
