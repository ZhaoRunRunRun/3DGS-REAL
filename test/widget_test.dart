import 'package:flutter_test/flutter_test.dart';
import 'package:three_dgs_real/app.dart';

void main() {
  testWidgets('renders dashboard and actions', (tester) async {
    await tester.pumpWidget(const ThreeDgsRealApp());

    expect(find.text('3DGS REAL'), findsOneWidget);
    expect(find.text('采集与建模控制台'), findsOneWidget);
    expect(find.text('相机引导拍摄'), findsOneWidget);
    expect(find.text('导入相册照片'), findsOneWidget);
    expect(find.text('启动 3DGS 建模'), findsOneWidget);
    expect(find.text('真实相册导入'), findsOneWidget);
  });
}
