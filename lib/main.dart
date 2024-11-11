import 'dart:developer';

import 'package:appium_test/Service/automation_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TempScreen(),
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
              await triggerButtonClick(
                userId: "Nariox7",
                loginId: "Nariox708",
                password: "Abcd@1234",
                appPath: "C:\\Users\\Hassan.Saeed\\Desktop\\Default-Flutter-App\\build\\app\\outputs\\flutter-apk\\app-debug.apk",
                deviceName: "Hassan-Emu-Pro",
                driverPath: "C:\\Users\\Hassan.Saeed\\Documents\\Programs\\ZIPs\\chromedriver-win64\\chromedriver.exe",
                serverUrl: "http://192.168.30.235:8000",
              );
            }
            if (url.toString().contains("")) {}
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.iobnet.co.in/ibanking/corplogin.do'));
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

class TempScreen extends StatelessWidget {
  TempScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              elevation: 8.0,
              minimumSize: const Size(100.0, 50.0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ));
            },
            child: const Text('Start'),
          ),
        ),
      ),
    );
  }
}
