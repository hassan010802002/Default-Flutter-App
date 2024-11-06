import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'Service/automation_service.dart';

void main() {
  // FlutterDriver? driver;
  //
  // setUpAll(() async {
  //   driver = await FlutterDriver.connect(
  //     dartVmServiceUrl: "http://192.168.30.217:5000/W0WPGA3IHhg=/ws",
  //   );
  // });
  //
  // tearDownAll(() async {
  //   if (driver != null) {
  //     driver!.close();
  //   }
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPageLoaded = false;
  WebViewController? _webController;

  @override
  void initState() {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            log("WebView Successfully Loaded Url: $url", name: "WebView Status");
            setState(() {
              _isPageLoaded = true;
            });
            if (_isPageLoaded) {
              // await clickButton();
              await triggerButtonClick();
            }
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller: _webController!,
        ),
      ),
    );
  }
}
