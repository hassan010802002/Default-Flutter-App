import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

Future<void> triggerButtonClick() async {
  final url = Uri.parse("http://192.168.1.2:6000/click-button");

  try {
    final response = await http.post(url);
    final responseData = json.decode(response.body);
    log("Appium Server Response is: $responseData", name: "appium service");
    if (responseData['status'] == 'success') {
      print("Button click triggered successfully.");
    } else {
      print("Error: ${responseData['message']}");
    }
  } catch (error) {
    print("Failed to trigger button click: $error");
  }
}
