import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  InAppWebViewController? inAppWebViewController;
  PullToRefreshController? pullToRefreshController;

  int count = 0;
  var loadingPercentage = 0;
  bool isInternet = true;
  String initialUrl = 'https://iitjeemathsking.com';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
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
          if (isInternet)
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
                setState(() {});
              },
              onLoadError: (controller, url, code, message) {
                if (message.isNotEmpty) {
                  errorMessage = "No Internet/Server Error";
                  isInternet = false;
                  setState(() {});
                }
              },
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) =>
                  inAppWebViewController = controller,
              initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
            ),
          if (!isInternet)
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
