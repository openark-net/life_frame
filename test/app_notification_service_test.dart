import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:life_frame/services/app_notification_service.dart';
import 'package:talker/talker.dart';

void main() {
  late AppNotificationService service;

  setUp(() {
    Get.put<Talker>(Talker());
    service = Get.put(AppNotificationService());
  });

  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester) {
    return tester.pumpWidget(
      GetCupertinoApp(
        home: const CupertinoPageScaffold(child: SizedBox.shrink()),
      ),
    );
  }

  testWidgets('shows a banner and dismisses it after its display duration', (
    tester,
  ) async {
    await pumpApp(tester);

    service.showSuccess('Success', 'Daily photo captured successfully!');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Daily photo captured successfully!'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Daily photo captured successfully!'), findsNothing);
  });

  testWidgets('replaces the active banner when a new one is shown', (
    tester,
  ) async {
    await pumpApp(tester);

    service.showError('Error', 'first message');
    await tester.pump();
    service.showSuccess('Success', 'second message');
    await tester.pump();

    expect(find.text('first message'), findsNothing);
    expect(find.text('second message'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('dismisses the banner when tapped', (tester) async {
    await pumpApp(tester);

    service.showSuccess('Success', 'tap to dismiss');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('tap to dismiss'));
    await tester.pumpAndSettle();

    expect(find.text('tap to dismiss'), findsNothing);
  });

  testWidgets('drops the notification when no overlay is available', (
    tester,
  ) async {
    expect(() => service.showError('Error', 'no overlay yet'), returnsNormally);
  });
}
