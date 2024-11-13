import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:appium_test/Service/automation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img; // Add this import
import 'package:path_provider/path_provider.dart';

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
  InAppWebViewController? _controller;
  Uint8List? _captchaImage;
  String _extractedText = '';
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final GlobalKey _widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          key: _widgetKey,
          initialUrlRequest: URLRequest(
            url: WebUri.uri(Uri.parse("https://www.iobnet.co.in/ibanking/corplogin.do")),
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isPageLoaded = false;
            });
          },
          onLoadStop: (controller, url) async {
            log("WebView Successfully Loaded at Url: $url", name: "WebView Status");
            _extractCaptchaImage();
          },
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
          ),
        ),
      ),
    );
  }

  void _extractCaptchaImage() async {
    try {
      // Execute JavaScript to get the base64 content of the image
      var base64Image = await _controller?.evaluateJavascript(source: 'document.getElementById("captchaimg").src;');

      // Remove the data URI scheme prefix
      final base64String = base64Image?.split(',')[1];

      if (base64Image == null || !base64Image.contains('data:image')) {
        setState(() {
          _extractedText = 'Captcha image not found';
        });
        return;
      }

      base64Image = base64Image?.replaceAll('"', ''); // Clean the result from quotes

      // Decode base64 to bytes
      Uint8List imageBytes = base64Decode(base64String);

      // Now process the image and extract text
      await _captureAndExtractText(imageBytes!);
    } catch (e) {
      print("Error extracting image: $e");
    }
  }

  Future<void> _captureAndExtractText(Uint8List imageBytes) async {
    setState(() {
      _extractedText = 'Processing...'; // Update UI to show processing state
    });

    try {
      // Convert Uint8List to an ui.Image to check its dimensions
      ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      ui.FrameInfo frame = await codec.getNextFrame();
      ui.Image image = frame.image;

      // Resize if the image is too small
      if (image.width < 32 || image.height < 32) {
        double scaleFactor = 8;
        ui.PictureRecorder recorder = ui.PictureRecorder();
        Canvas canvas = Canvas(recorder);

        canvas.scale(scaleFactor);
        Paint paint = Paint();
        canvas.drawImage(image, Offset.zero, paint);

        ui.Image resizedImage = await recorder.endRecording().toImage((image.width * scaleFactor).toInt(), (image.height * scaleFactor).toInt());

        ByteData? resizedByteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
        if (resizedByteData == null) throw Exception("Failed to convert image to byte data");
        imageBytes = resizedByteData.buffer.asUint8List();
      }

      // Decode the image using `image` package for manipulation
      img.Image? captchaImage = img.decodeImage(imageBytes);
      if (captchaImage == null) {
        throw Exception("Failed to decode captcha image.");
      }
      img.Image contrastEnhanced = img.adjustColor(captchaImage, contrast: 100);
      img.Image sharpenedImage = img.gaussianBlur(contrastEnhanced, radius: -80); // Apply a slight blur for sharpness

      // Scale up the image with high quality to reduce pixelation
      img.Image resizedImage = img.copyResize(
        sharpenedImage,
        width: (sharpenedImage.width).toInt(),
        height: (sharpenedImage.height).toInt(),
        interpolation: img.Interpolation.cubic, // Use cubic interpolation for smoother scaling
        maintainAspect: true,
      );

      // Convert the processed image back to bytes for ML Kit
      Uint8List processedImageBytes = Uint8List.fromList(img.encodePng(sharpenedImage));

      // Save the image to a temporary file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/captcha_image.png');
      await file.writeAsBytes(processedImageBytes);

      // Load the saved image as InputImage
      final inputImage = InputImage.fromFile(file);

      // Perform text recognition
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Clean up the recognized text (if any)
      String cleanedText = recognizedText.text.replaceAll(RegExp(r'\s+'), '').trim();
      String myCaptchaText = removeSpecialCharacters(cleanedText);

      setState(() {
        _extractedText = myCaptchaText; // Update UI with the extracted text
        _captchaImage = processedImageBytes; // Display the enhanced image
        _isPageLoaded = true;
      });
      print("Captured Text: $_extractedText");
      log("Loading Status is : $_isPageLoaded", name: "Loading Status");
      if (_isPageLoaded) {
        await triggerButtonClick(
          userId: "Nariox7",
          loginId: "Nariox708",
          password: "Abcd@1234",
          appPath: "C:\\Users\\Hassan\\Desktop\\DefaultApp\\Default_Flutter_App\\build\\app\\outputs\\flutter-apk\\app-debug.apk",
          deviceName: "Hassan_Pro",
          driverPath: "C:\\Users\\Hassan\\Downloads\\chromedriver-win64\\chromedriver.exe",
          serverUrl: "http://192.168.1.2:8000",
          captchaText: _extractedText,
        );
      }
    } catch (e) {
      print("Error extracting text: $e");
      setState(() {
        _extractedText = 'Error recognizing text'; // Handle error
      });
    }
  }

  String removeSpecialCharacters(String text) {
    // Define allowed characters (letters, digits, and space)
    const allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    // Use a StringBuffer to build the resulting string efficiently
    StringBuffer result = StringBuffer();

    // Iterate through each character in the input string
    for (int i = 0; i < text.length; i++) {
      // Check if the character is in the allowed characters set
      if (allowedChars.contains(text[i])) {
        result.write(text[i]);
      }
    }

    // Return the modified string
    return result.toString();
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
