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
  int numberOfUrlIndex = 0;
  String statusText = '';
  int loadCount = 0;
  ValueNotifier<double> progressBarValue = ValueNotifier<double>(0.5);

  changeStatus({newStatus, required ValueNotifier<double> newProgressBarValue}) {
    setState(() {
      statusText = newStatus;
      progressBarValue = newProgressBarValue;
    });
  }

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
          onReceivedError: (controller, request, error) async {
            if ((await controller.getUrl()) == WebUri("https://www.iobnet.co.in/ibanking/corplogin.do") ||
                (await controller.getUrl()) == WebUri("https://www.iobnet.co.in/ibanking/corplogin.do?errmsg=Captcha+entered+is+Incorrect")) {
              controller.reload(); // Retry loading the page if there's no response
              log("WebView Error: ${error.description}", name: "WebView Error");
            }
            if ((await controller.getUrl()) == WebUri("https://www.iobnet.co.in/ibanking/loginsuccess.do")) {
              controller.reload(); // Retry loading the page if there's no response
              log("WebView Error: ${error.description}", name: "WebView Error");
            }
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isPageLoaded = false;
            });
          },
          onLoadStop: (controller, url) async {
            if (url.toString().contains("corplogin.do")) {
              log("WebView Successfully Loaded at Url: $url", name: "WebView Status");
              _extractCaptchaImage(webUrl: url);
            }
            if (url.toString().contains("loginsuccess.do")) {
              // isFirst = false;
              log("Testing Success Login", name: "successLogin");
              setState(() {});
              changeStatus(
                newStatus: "Now you are Logged In Successful",
                newProgressBarValue: ValueNotifier(1),
              );
              String jsClickDrawerIcon = '''
      var drawerIcon = document.querySelector('.navbar-toggler');  // Select the drawer icon using its class
      if (drawerIcon) {
        drawerIcon.click();  // Simulate a click on the drawer icon
      }

      // Wait a moment for the drawer to open before clicking the "Funds Transfer" option
      setTimeout(function() {
        var fundsTransferLink = document.querySelector('#main2 a.menuhref');  // Select the "Funds Transfer" link
        if (fundsTransferLink) {
          fundsTransferLink.click();  // Simulate a click on the "Funds Transfer" link
        }
      }, 1000);  // Delay for 1 second to ensure the drawer is fully open
    ''';

              await controller.evaluateJavascript(source: jsClickDrawerIcon);
            } else if (url.toString().contains("error-message")) {
              print("Login failed, error message found.");
              // _isSubmitting = false;
            } else if (url.toString().contains("html/index.html")) {
              await controller.evaluateJavascript(source: '''
                  document.querySelector('a.btn.btn-danger[onclick*="checkIEVersion11"]').click();
                ''');
            } else if (url.toString().contains("html/index1.html")) {
              // Click the "Corporate Login" button
              await controller.evaluateJavascript(source: '''
                  document.querySelector('a.btn.btn-primary.btn-block.mb-1[onclick*="checkIEVersion11"]').click();
                ''');
              setState(() {
                _isPageLoaded = false;
              });
            } else if (url.toString().contains("ibanking/logout.do")) {
              // Click the "Home" button
              await controller.evaluateJavascript(source: '''
              document.querySelector('input.action-btn.flt-l[value="Home"]').click();
            ''');

              setState(() {
                _isPageLoaded = false;
              });
            } else if (url.toString().contains("rendermenu.do?menuname=Funds!Transfer")) {
              String jsClickHamburger = '''
                var hamburgerIcon = document.querySelector('.navbar-toggler.flex-1.d-lg-none.d-md-none.in-hamb');
                if (hamburgerIcon) {
                  hamburgerIcon.click();  // Simulate a click on the hamburger menu
                }

                // Wait for 1 second, then click the 'Funds Transfer' menu
                setTimeout(function() {
                  var fundsTransferMenu = document.querySelector('a.nav-link.main-menu[href="#item1709901119"]');
                  if (fundsTransferMenu) {
                    fundsTransferMenu.click();  // Simulate a click on the 'Funds Transfer' menu
                  }
                }, 1000);  // Delay for 1 second

                // Wait another 1 second for the 'Funds Transfer' submenu to open, then click 'IOB Account'
                setTimeout(function() {
                  var iobAccountLink = document.querySelector('a.nav-link[href="./ibLeftMenu.do?handleId=2001_IMPSP2A"]');
                  // var iobAccountLink = document.querySelector('a.nav-link[href="./ibLeftMenu.do?handleId=2001_IOB"]');
                  if (iobAccountLink) {
                    iobAccountLink.click();  // Simulate a click on the 'IOB Account' link
                  }
                }, 2000);  // Delay for 2 seconds
              ''';

              await controller.evaluateJavascript(source: jsClickHamburger);
              setState(() {
                _isPageLoaded = false;
              });
            } else if (url.toString().contains("ibLeftMenu.do?handleId=2001_IMPSP2A")) {
              String transferAccounts = '''
              var transferData = {
                "transfare_to": [
                  "HOOP LABS|MAHB0001883|11|60481960306",
                  "OPERATIONAL DECISION|MAHB0001883|11|60481958740"
                ],
                "remark": "Salary",
                "amount": "400"
              };

              var index = 0; // to track which account to select in the loop
              function processTransfer() {
                if (index >= transferData.transfare_to.length) {
                  console.log("All transfers processed");
                  return;
                }

                var currentTransfer = transferData.transfare_to[index];

                // Select "Pay From" account
                var dropdownPayFrom = document.getElementById("ibIMPSFundsTransfer_debitAc");
                if (dropdownPayFrom) {
                  dropdownPayFrom.selectedIndex = 1;
                  dropdownPayFrom.dispatchEvent(new Event('change'));
                }

                // Select "Transfer Amount To"
                setTimeout(function() {
                  var dropdownTransferTo = document.getElementById("ibIMPSFundsTransfer_creditAc");
                  if (dropdownTransferTo) {

                    for (var i = 0; i < dropdownTransferTo.options.length; i++) {
                      if (dropdownTransferTo.options[i].text.includes(currentTransfer)) {
                        dropdownTransferTo.selectedIndex = i;
                        dropdownTransferTo.dispatchEvent(new Event('change'));
                        break;
                      }
                    }
                  }

                  // Set "Remarks"
                  setTimeout(function() {
                    var remarksField = document.getElementById("ibIMPSFundsTransfer_debitRemarks");
                    if (remarksField) {
                      for (var j = 0; j < remarksField.options.length; j++) {
                        if (remarksField.options[j].value === transferData.remark) {
                          remarksField.selectedIndex = j;
                          remarksField.dispatchEvent(new Event('change'));
                          break;
                        }
                      }
                    }

                    // Set "Amount"
                    setTimeout(function() {
                      var amountField = document.getElementById("ibIMPSFundsTransfer_amtRs");
                      if (amountField) {
                        amountField.value = transferData.amount;
                      }

                      // Click "Proceed"
                      setTimeout(function() {
                        var proceedButton = document.getElementById("ibIMPSFundsTransfer_subm");
                        if (proceedButton) {
                          proceedButton.click();
                        }

                        // Increment index and reload for the next account
                        index++;
                        setTimeout(processTransfer, 2000);  // Wait and process next transfer
                      }, 1000);  // Wait 1 second before clicking Proceed
                    }, 1000);  // Wait 1 second for Remarks to update
                  }, 1000);  // Wait 1 second for Transfer To to update
                }, 1000);  // Wait 1 second for Pay From to update
              }

              // Start processing
              processTransfer();
              ''';

              await controller.evaluateJavascript(source: transferAccounts);
              setState(() {
                _isPageLoaded = false;
              });
            }
            // else if (url.toString().contains("ibIMPSFundsTransfer.do")) {
            //   // _injectJavaScriptForBankSelection(controller);
            //   // (controller, url.toString());
            //   //
            //   // setState(() {
            //   //   _isLoading = false;
            //   // });
            //
            //   loadCount++;
            //   print("Load count: $loadCount");
            //
            //   if (loadCount == 1) {
            //     // First load - Inject JavaScript for bank selection, excluding the txnPasswd part
            //     String jsScriptFirstLoad = '''
            //         var selectedBankId = "${selectedBankNotifier.value?.number ?? ""}".trim();
            //
            //         function waitForElement(selector, callback) {
            //           const interval = setInterval(() => {
            //             const element = document.getElementById(selector);
            //             if (element) {
            //               clearInterval(interval);
            //               callback(element);
            //             }
            //           }, 100); // Check every 100 milliseconds
            //         }
            //
            //         function updateBankSelection(dropdownTransferTo) {
            //           console.log("Updating transfer with bank ID: " + selectedBankId);
            //
            //           var found = false;
            //           for (var i = 0; i < dropdownTransferTo.options.length; i++) {
            //             var optionText = dropdownTransferTo.options[i].text.trim();
            //             if (optionText.includes(selectedBankId)) {
            //               dropdownTransferTo.selectedIndex = i;
            //               dropdownTransferTo.dispatchEvent(new Event('change'));
            //               found = true;
            //               console.log("Selected account with ID: " + selectedBankId);
            //               break;
            //             }
            //           }
            //
            //           if (!found) {
            //             console.log("Account with ID not found in dropdown");
            //             alert("Account with ID " + selectedBankId + " not found");
            //             return;
            //           }
            //
            //           // Set "Remarks" to third option in the dropdown
            //           setTimeout(() => {
            //             var remarksField = document.getElementById("ibIMPSFundsTransfer_debitRemarks");
            //             if (remarksField && remarksField.options.length >= 3) {
            //               remarksField.selectedIndex = 2; // Select the third option
            //               remarksField.dispatchEvent(new Event('change'));
            //               console.log("Remarks set to the third option: " + remarksField.options[2].text);
            //             }
            //           }, 1000);
            //
            //           // Set "Amount" field
            //           setTimeout(() => {
            //             var amountField = document.getElementById("ibIMPSFundsTransfer_amtRs");
            //             if (amountField) {
            //               amountField.value = "${widget.bankAccount.freezeAmount}";
            //               amountField.dispatchEvent(new Event('change'));
            //               console.log("Amount set to: " + "${widget.bankAccount.freezeAmount}");
            //             }
            //           }, 2000);
            //
            //           // Click "Proceed" button to process the transfer
            //           setTimeout(() => {
            //             var proceedButton = document.getElementById("ibIMPSFundsTransfer_subm");
            //             if (proceedButton) {
            //               proceedButton.click();
            //               console.log("Clicked Proceed button");
            //             }
            //           }, 3000);
            //         }
            //
            //         waitForElement("ibIMPSFundsTransfer_creditAc", updateBankSelection);
            //       ''';
            //     await controller.evaluateJavascript(source: jsScriptFirstLoad);
            //     changeStatus(
            //       newStatus: "Now Your PIN Is inserted ",
            //       newProgressBarValue: ValueNotifier(6),
            //     );
            //   } else if (loadCount == 2) {
            //     // Second load - Set the PIN value in the text field and then click "Transfer Funds" button
            //     String jsScriptSecondLoad = '''
            //   (function() {
            //     var pinField = document.getElementById("ibIMPSFundsTransfer_txnPasswd");
            //     if (pinField) {
            //       pinField.value = "${widget.bankAccount.trxnPassword}";
            //       pinField.dispatchEvent(new Event('input'));
            //       console.log("PIN set to: ${widget.bankAccount.trxnPassword}");
            //
            //       // After setting the PIN, click the "Transfer Funds" button
            //       var transferButton = document.getElementById("ibIMPSFundsTransfer_subm");
            //       if (transferButton) {
            //         transferButton.click();
            //         console.log("Clicked Transfer Funds button");
            //       } else {
            //         console.log("Transfer Funds button not found");
            //       }
            //     } else {
            //       console.log("PIN field not found");
            //     }
            //   })();
            // ''';
            //     await controller.evaluateJavascript(source: jsScriptSecondLoad);
            //
            //     loadCount = 0;
            //
            //     changeStatus(
            //       newStatus: "Write Down The OTP And Enter It",
            //       newProgressBarValue: ValueNotifier(7),
            //     );
            //   }
            //
            //   setState(() {
            //     _isPageLoaded = false;
            //   });
            // }
          },
          onReceivedHttpError: (controller, request, response) async {
            log("HTTP Error [${response.statusCode}] on ${await controller.getUrl()}: $response", name: "HTTP Error");
          },
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            allowContentAccess: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            domStorageEnabled: true,
            databaseEnabled: true,
            allowFileAccess: true,
            userAgent:
                "Mozilla/5.0 (Linux; Android 10; Pixel 5 Build/RQ3A.210705.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.131 Mobile Safari/537.36",
            useHybridComposition: true, // Enables modern rendering
          ),
        ),
      ),
    );
  }

  void _extractCaptchaImage({required WebUri? webUrl}) async {
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
      await _captureAndExtractText(imageBytes!, webUrl: webUrl);
    } catch (e) {
      print("Error extracting image: $e");
    }
  }

  Future<void> _captureAndExtractText(Uint8List imageBytes, {required WebUri? webUrl}) async {
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
      if (_isPageLoaded &&
          (webUrl == WebUri("https://www.iobnet.co.in/ibanking/corplogin.do") ||
              webUrl == WebUri("https://www.iobnet.co.in/ibanking/corplogin.do?errmsg=Captcha+entered+is+Incorrect"))) {
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

  void func() {
    // }

    // else {
    // await _fillLoginFields(controller); // Call the new function
    //
    //
    // await controller.evaluateJavascript(source: """
    //         var inputField = document.getElementById('loginsubmit_captchaid');
    //         if (inputField) {
    //           inputField.addEventListener('input', function(event) {
    //             window.flutter_inappwebview.callHandler('onInputChanged', event.target.value);
    //           });
    //         }
    //
    //       """);
    // }

    // setState(() {
    //   _isLoading = false;
    // });
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
