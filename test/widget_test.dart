import 'package:flutter_test/flutter_test.dart';
import 'package:cnpm_24ct1_leanhquan/main.dart';

void main() {
  testWidgets('GoRide VN app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GoRideApp());
    expect(find.byType(GoRideApp), findsOneWidget);
  });
}
