import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nokho_flow/app.dart';

void main() {
  testWidgets('app starts and shows its title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NokhoFlowApp()));
    expect(find.text('Nokho-Flow'), findsOneWidget);
  });
}
