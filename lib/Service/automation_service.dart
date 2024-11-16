import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

/// Function to trigger a button click on the Appium server
Future<void> triggerButtonClick({
  required String loginId,
  required String userId,
  required String password,
  required String captchaText,
  required String appPath,
  required String deviceName,
  required String driverPath,
  required String serverUrl,
}) async {
  // Define the API endpoint
  const String apiEndpoint = "http://192.168.1.2:6000/click-button";
  final Uri url = Uri.parse(apiEndpoint);

  // Ensure all required parameters are non-null
  assert(loginId.isNotEmpty, "loginId cannot be null or empty");
  assert(userId.isNotEmpty, "userId cannot be null or empty");
  assert(password.isNotEmpty, "password cannot be null or empty");
  assert(captchaText.isNotEmpty, "captchaText cannot be null or empty");
  assert(appPath.isNotEmpty, "appPath cannot be null or empty");
  assert(deviceName.isNotEmpty, "deviceName cannot be null or empty");
  assert(driverPath.isNotEmpty, "driverPath cannot be null or empty");
  assert(serverUrl.isNotEmpty, "serverUrl cannot be null or empty");

  try {
    // Prepare the request payload
    final Map<String, dynamic> payload = <String, dynamic>{
      "loginId": loginId,
      "userId": userId,
      "password": password,
      "app": appPath,
      "deviceName": deviceName,
      "driverPath": driverPath,
      "serverUrl": serverUrl,
      "captchaText": captchaText,
    };

    log("Sending request to Appium server: $apiEndpoint", name: "appium service");
    log("Payload: ${jsonEncode(payload)}", name: "appium service");

    // Make the HTTP POST request
    final http.Response response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    // Check HTTP status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Decode the response
      final dynamic responseData = jsonDecode(response.body);

      // Handle both Map and List responses
      if (responseData is Map<String, dynamic>) {
        log("Appium Server Response (Map): ${response.body}", name: "appium service");

        if (responseData['status'] == 'success') {
          log("Button click triggered successfully.", name: "appium service");
        } else {
          log("Error from Appium server: ${responseData['message']}", name: "appium service", level: 2);
        }
      } else if (responseData is List<dynamic>) {
        log("Appium Server Response (List): ${response.body}", name: "appium service");

        // Process the list if needed (example: log each item)
        for (var item in responseData) {
          log("Item: $item", name: "appium service");
        }
      } else {
        log("Unexpected response format: ${response.body}", name: "appium service", level: 2);
      }
    } else {
      log("HTTP Error: ${response.statusCode} - ${response.reasonPhrase}", name: "appium service", level: 2);
    }
  } catch (error) {
    // Handle exceptions (e.g., network issues, JSON parsing errors)
    log("Failed to trigger button click: $error", name: "appium service", level: 2);
  }
}
