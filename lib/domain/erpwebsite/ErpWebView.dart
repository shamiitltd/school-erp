import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewExample extends StatefulWidget {
  final String firebasePath;

  const WebViewExample({super.key, required this.firebasePath});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  InAppWebViewController? inAppWebViewController;
  PullToRefreshController? pullToRefreshController;
  final user = FirebaseAuth.instance.currentUser;
  final ReceivePort _port = ReceivePort();
  late String firebasePath;

  int count = 0;
  var loadingPercentage = 0;
  bool isInternet = true;
  String afterLoginUrl = ''; //https://iitjeemathsking.com/after-login
  String loginUrl = '';
  String errorMessage = '';
  bool isLoggedIn = false;
  bool _mounted = true;

  void loadErpInfo(String firebasePath) async {
    FirebaseDatabase.instance
        .ref()
        .child(firebasePath) //"erpInfo"
        .onValue
        .listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (key.trim() == 'loginApi') {
          loginUrl = '$value?email=${user?.email}&uid=${user?.uid}';
        } else if (key.trim() == 'afterLogin') {
          afterLoginUrl = value;
        }
      });
      if(inAppWebViewController != null) {
        inAppWebViewController?.loadUrl(
            urlRequest: URLRequest(url: Uri.parse(afterLoginUrl)));
      }
      if (_mounted) setState(() {});
    });
  }

  Future download(String url) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final baseDirectory = await getExternalStorageDirectory();
      final savedDir = '${baseDirectory!.path}/Download';
      if (!Directory(savedDir).existsSync()) {
        Directory(savedDir).createSync(recursive: true);
      }
      // final headers = {
      //   'email': user!.email??'',
      //   'uid': user!.uid??'',
      // };
      final headers = {
        'email': 'vinay@shamiit.com',
        'password': '123456',
      };
      await FlutterDownloader.enqueue(
          url: url,
          headers: headers,
          savedDir: savedDir,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true);
    }
  }

  @override
  void didUpdateWidget(WebViewExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.firebasePath != oldWidget.firebasePath) {
      firebasePath = widget.firebasePath;
      loadErpInfo(firebasePath);
      setState(() {});
    }
  }

  @override
  void initState() {
    firebasePath = widget.firebasePath;
    loadErpInfo(firebasePath);
    webViewAccess();
    pullToRefreshController = PullToRefreshController(
      onRefresh: () {
        inAppWebViewController!.reload();
      },
    );
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (status == DownloadTaskStatus.complete) {
        // print("Download Complete");
      }
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    setState(() {});
    _mounted = true;
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _mounted = false;
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
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
                        urlRequest: URLRequest(url: Uri.parse(afterLoginUrl)));
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
                      useOnDownloadStart: true),
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
              },
              onDownloadStartRequest: (controller, downloadStartRequest) async {
                String message = "File downloaded Complete";
                try {
                  await download(downloadStartRequest.url.toString());
                } catch (e) {
                  message = e.toString();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED);
              },
            ),
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
    try {
      await FlutterDownloader.initialize(
          debug:
              true, // optional: set to false to disable printing logs to console (default: true)
          ignoreSsl:
              true // option: set to false to disable working with http links (default: false)
          );
    } catch (e) {}
  }
}
