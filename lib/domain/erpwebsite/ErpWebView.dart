import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  InAppWebViewController? inAppWebViewController;
  PullToRefreshController? pullToRefreshController;
  final user = FirebaseAuth.instance.currentUser;

  int count = 0;
  var loadingPercentage = 0;
  bool isInternet = true;
  String afterLoginUrl = ''; //https://iitjeemathsking.com/after-login
  String loginUrl = '';
  String errorMessage = '';
  bool isLoggedIn = false;

  void loadErpInfo() async {
    FirebaseDatabase.instance
        .ref()
        .child("erpInfo")
        .onValue
        .listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (key == 'afterLogin') {
          afterLoginUrl = value;
        } else if (key == 'loginApi') {
          loginUrl = '$value?email=${user?.email}&uid=${user?.uid}';
        }
      });
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    loadErpInfo();
    webViewAccess();
    pullToRefreshController = PullToRefreshController(
      onRefresh: () {
        inAppWebViewController!.reload();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await inAppWebViewController!.canGoBack()) {
          await inAppWebViewController!.goBack();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Stack(
        children: [
          if (afterLoginUrl.isEmpty || loginUrl.isEmpty)
            const Center(
                child: CircularProgressIndicator(
              color: Colors.blue,
            )),
          if (isInternet && afterLoginUrl.isNotEmpty && loginUrl.isNotEmpty)
            InAppWebView(
                onLoadStart: (controller, url) {
                  loadingPercentage = 0;
                  setState(() {});
                },
                onProgressChanged: (controller, progress) {
                  loadingPercentage = progress;
                  setState(() {});
                },
                onLoadStop: (controller, url) {
                  pullToRefreshController!.endRefreshing();
                  loadingPercentage = 100;
                  if (!isLoggedIn) {
                    isLoggedIn = true;
                    inAppWebViewController?.loadUrl(
                        urlRequest: URLRequest(url: Uri.parse(afterLoginUrl)));
                  }
                  setState(() {});
                },
                onLoadError: (controller, url, code, message) {
                  if (message.isNotEmpty) {
                    errorMessage = "No Internet/Server Error";
                    isInternet = false;
                    if (!isLoggedIn) {
                      isLoggedIn = true;
                      inAppWebViewController?.loadUrl(
                          urlRequest:
                              URLRequest(url: Uri.parse(afterLoginUrl)));
                    }
                    setState(() {});
                  }
                },
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) =>
                    inAppWebViewController = controller,
                initialUrlRequest: URLRequest(url: Uri.parse(loginUrl)),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  if (navigationAction.request.url?.host == "www.youtube.com") {
                    await launchUrl(navigationAction.request.url!);
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      allowFileAccessFromFileURLs: true,
                      allowUniversalAccessFromFileURLs: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      mediaPlaybackRequiresUserGesture: false,
                    ),
                    android: AndroidInAppWebViewOptions(
                        allowContentAccess: true,
                        allowFileAccess: true,
                        useHybridComposition: true),
                    ios: IOSInAppWebViewOptions(
                      allowsInlineMediaPlayback: true,
                    )),
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                }),
          if (!isInternet && afterLoginUrl.isNotEmpty && loginUrl.isNotEmpty)
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(errorMessage),
                const Text("Please check your connection"),
                TextButton(
                  onPressed: () {
                    isInternet = true;
                    inAppWebViewController!.reload();
                    setState(() {});
                  },
                  child: const Text('Click here to Reload'),
                ),
              ],
            )),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              minHeight: 5,
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }

  Future<void> webViewAccess() async {
    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

      var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController =
            AndroidServiceWorkerController.instance();

        await serviceWorkerController
            .setServiceWorkerClient(AndroidServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            return null;
          },
        ));
      }
    }
  }
}
