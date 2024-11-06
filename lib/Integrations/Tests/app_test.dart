import 'dart:async';

import 'package:appium_driver/async_io.dart';

Future<void> clickButton() async {
  // Set up the WebDriver options for Appium with the Chromium driver
  final capabilities = {
    'platformName': 'Android',
    'appium:deviceName': 'Hassan_Pro', // Change as needed for your emulator/device
    'appium:automationName': 'Flutter',
    'appium:app': 'C:\\Users\\Hassan\\Desktop\\DefaultApp\\Default_Flutter_App\\build\\app\\outputs\\flutter-apk\\app-debug.apk',
    'noReset': true,
    'fullReset': false,
  };

  // Connect to Appium server
  final AppiumWebDriver driver = await createDriver(
    uri: Uri.parse('http://192.168.30.217:8000/'), // Appium server URL
    desired: capabilities,
    spec: WebDriverSpec.Auto,
  );

  try {
    await Future.delayed(const Duration(seconds: 5));

    List<String> contexts = await driver.contexts.getAvailableContexts();
    print('Available contexts: $contexts');

    // Switch to the webview context (assuming the webview is the second context)
    final webviewContext = contexts.firstWhere((context) => context.contains('WEBVIEW'));
    await driver.contexts.setContext(webviewContext);

    // Find the button by its ID, class, or any other attribute
    final button = await driver.findElement(const AppiumBy.accessibilityId('get-started__header'));

    // Click the button
    await button.click();
    print('Button clicked successfully!');

    // Optionally, you can add assertions or validations here
  } catch (e) {
    print('Error: $e');
  }
}
