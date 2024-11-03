// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:appium_test/Integrations/Tests/app_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('Appium Click Button Test', () async {
    // Build our app and trigger a frame.
    await clickButton();
  });
}
