import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

Future<void> triggerButtonClick({
  required String? loginId,
  required String? userId,
  required String? password,
  required String? appPath,
  required String? deviceName,
  required String? driverPath,
  required String? serverUrl,
}) async {
  final url = Uri.parse("http://192.168.30.235:6000/click-button");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "loginId": loginId!,
        "userId": userId!,
        "password": password!,
        "app": appPath!,
        "deviceName": deviceName!,
        "driverPath": driverPath!,
        "serverUrl": serverUrl!,
      }),
    );
    log("Appium Server Response is: ${response.body}", name: "appium service");
    final responseData = json.decode(response.body);
    if (responseData['status'] == 'success') {
      print("Button click triggered successfully.");
    } else {
      print("Error: ${responseData['message']}");
    }
  } catch (error) {
    print("Failed to trigger button click: $error");
  }
}
