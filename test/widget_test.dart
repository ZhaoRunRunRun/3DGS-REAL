import 'package:flutter_test/flutter_test.dart';
import 'package:three_dgs_real/app.dart';

void main() {
  testWidgets('renders dashboard title', (tester) async {
    await tester.pumpWidget(const ThreeDgsRealApp());

    expect(find.text('3DGS REAL'), findsOneWidget);
    expect(find.text('采集与建模控制台'), findsOneWidget);
  });
}
