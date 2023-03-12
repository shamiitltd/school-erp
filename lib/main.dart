import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:school_erp/config/Colors.dart';
import 'package:school_erp/domain/authentication/LoginActivity.dart';
import 'package:school_erp/shared/functions/popupSnakbar.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try{
    final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = false;
      mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
    }
  }catch(e){};
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Future<FirebaseApp> initializeApp = Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAp94KJo0DDjDEHr4rgrrbv0-Q-aZRp_zA",
          authDomain: "school-erp-1.firebaseapp.com",
          databaseURL: "https://school-erp-1-default-rtdb.firebaseio.com",
          projectId: "school-erp-1",
          storageBucket: "school-erp-1.appspot.com",
          messagingSenderId: "35032464117",
          appId: "1:35032464117:web:53fe0026965ee32e07a3bc",
          measurementId: "G-4Z2VBTH0BN"
      )
  );
  final navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      scaffoldMessengerKey: PopupSnackBar.messangerKey,
      navigatorKey: navigatorKey,
      title: 'School ERP by SHAMIIT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: themeColor,
        appBarTheme: const AppBarTheme(
          // backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home:FutureBuilder(
          future: initializeApp,
          builder: (context, snapshot) {
            if(snapshot.hasError){
            }
            if(snapshot.connectionState == ConnectionState.done){
              // return OrderTrackingPage();
              return const LoginActivity();
            }
            return const CircularProgressIndicator();
          }
      ),
    );

    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   initialRoute: '/',
    //   routes: {
    //     '/': (context) => const MyHomePage(title: 'School ERP by SHAMIIT'),
    //     '/home': (context) => Dashboard(),
    //     '/chat': (context) => ChatActivity(),
    //   },
    //   title: 'School ERP by SHAMIIT',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    // );
  }
}
