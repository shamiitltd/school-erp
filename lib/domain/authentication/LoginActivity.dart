import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_erp/config/StaticConstants.dart';
import 'package:school_erp/domain/authentication/widgets/LoginWidget.dart';
import 'package:school_erp/pages/HomePage.dart';
import 'package:school_erp/pages/home.dart';

class LoginActivity extends StatefulWidget {
  const LoginActivity({Key? key}) : super(key: key);

  @override
  State<LoginActivity> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  @override
  void initState() {
    super.initState();
    checkEmailVerified();
  }


  Future checkEmailVerified() async{
    var user = await FirebaseAuth.instance.currentUser;
    if(user != null) {
      user.reload();
      setState(() {
        isEmailVerified = user.emailVerified;
      });
    }
    // Timer.periodic(const Duration(seconds: 1), (Timer t) => setState((){}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
                child: CircularProgressIndicator()
            );
          }else if(snapshot.hasError){
            return const Center(child: Text('Something went Wrong!'));
          }
          else if(snapshot.hasData){
            return const HomePage(title: 'School ERP by SHAMIIT');
          }else{
            return const LoginWidget();
          }
        },
      ),
    );
  }
}



