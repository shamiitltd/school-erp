import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:school_erp/config/Colors.dart';
import 'package:school_erp/config/Country.dart';
import 'package:school_erp/config/DynamicConstants.dart';
import 'package:school_erp/config/StaticConstants.dart';
import 'package:school_erp/domain/authentication/functions/RealTimeDb.dart';
import 'package:school_erp/domain/authentication/widgets/LoginWidget.dart';
import 'package:school_erp/domain/authentication/widgets/ResuableWidgets.dart';
import 'package:school_erp/domain/map/functions/RealTimeDb.dart';
import 'package:school_erp/shared/functions/popupSnakbar.dart';


class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key}) : super(key: key);

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  String _selectedCountryCode = '';
  String _selectedCountryName = '';
  String _selectedYourPost = '';
  String _selectedYourRoute = '';
  List<String> uniquelist = [];
  Map<String, String> _countries = {};
  void addDropDownMenu() async {
    List<String> postList = [];
    List<String> routeList = [];
    final databaseReference = FirebaseDatabase.instance.ref();

    for (var i = 0; i < countryNames.length; i++) {
      _countries[countryNames[i]] = '+${countryAreaCodes[i]}';
    }

    await databaseReference
        .child("routes")
        .onValue
        .listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
      event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        routeList.add(value);
      });
      setState(() {
        userRoute = routeList;
        _selectedYourRoute = userRoute[0];
      });
    });
    await databaseReference
        .child("posts")
        .onValue
        .listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
      event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        postList.add(value);
      });
      setState(() {
        userPosts = postList;
        _selectedYourPost = userPosts[0];
      });
    });
    var seen = Set<String>();
    uniquelist = countryNames.where((country) => seen.add(country)).toList();
    _selectedCountryName = uniquelist[0];
    _selectedCountryCode = _countries[_selectedCountryName]!;
  }

  @override
  void initState() {
    super.initState();
    addDropDownMenu();
  }

  @override
  void dispose() {
    displayNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  bool isValidPhoneNumber(String? value) =>
      RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)')
          .hasMatch(value ?? '');

  Future checkEmailVerified() async {
    var user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      user.reload();
      setState(() {
        isEmailVerified = user.emailVerified;
      });
    }
    return isEmailVerified;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: loginColor1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: loginButtonTextColor,
            shadows: [
              Shadow(color: loginIconColor,blurRadius: 100)
            ],
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  loginColor1, loginColor2, loginColor3,
                ],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              )
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.fromLTRB(16, MediaQuery.of(context).size.height*0.01102, 16, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  logoWidget("assets/shamiitlogo.png"),
                  TextFormField(
                    controller: displayNameController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon:const Icon(Icons.person_outline,color: loginIconColor,),
                      labelText: 'Enter your Name',
                      labelStyle: TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(width: 0,style: BorderStyle.solid,color: loginIconColor)),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.length < 2
                        ? 'Please enter a valid name'
                        : null,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      _formKey.currentState!.save();
                    },
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text('Select Post:'),
                        flex: 2,
                      ),
                      Expanded(
                        flex: 3,
                        child: (_selectedYourPost.isNotEmpty)
                            ? DropdownButton(
                          value: _selectedYourPost,
                          items: userPosts.map((country) {
                            return DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYourPost = value!;
                            });
                          },
                        )
                            : Text('Loading...'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text('Select Route:'),
                        flex: 2,
                      ),
                      Expanded(
                        flex: 3,
                        child: (_selectedYourRoute.isNotEmpty)
                            ? DropdownButton(
                          value: _selectedYourRoute,
                          items: userRoute.map((country) {
                            return DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYourRoute = value!;
                            });
                          },
                        )
                            : Text('Loading...'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text('Select country:'),
                        flex: 2,
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButton(
                          value: _selectedCountryName,
                          items: uniquelist.map((country) {
                            return DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCountryCode = _countries[value]!;
                              _selectedCountryName = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: phoneController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon:const Icon(Icons.call,color: loginIconColor,),
                      labelText: 'Enter Phone number',
                      labelStyle: TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(width: 0,style: BorderStyle.solid,color: loginIconColor)),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => !isValidPhoneNumber(value)
                        ? "Enter Correct phone number"
                        : null,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      _formKey.currentState!.save();
                    },
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon:const Icon(Icons.mail_outline_rounded,color: loginIconColor,),
                      labelText: 'Enter your email',
                      labelStyle: TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(width: 0,style: BorderStyle.solid,color: loginIconColor)),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Enter a valid email'
                        : null,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      _formKey.currentState!.save();
                    },
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: passwordController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon:const Icon(Icons.lock_outlined,color: loginIconColor,),
                      labelText: 'Enter your Password',
                      labelStyle: TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(width: 0,style: BorderStyle.solid,color: loginIconColor)),
                    ),
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.length < 6
                        ? 'Enter min 6 characters'
                        : null,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                      _formKey.currentState!.save();
                    },
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: confirmPassController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon:const Icon(Icons.lock_outlined,color: loginIconColor,),
                      labelText: 'Enter your email',
                      labelStyle: TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(width: 0,style: BorderStyle.solid,color: loginIconColor)),
                    ),
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.length < 6
                        ? 'Enter min 6 characters'
                        : null,
                    onFieldSubmitted: (_) {
                      _formKey.currentState!.validate();
                      _formKey.currentState!.save();
                    },
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor: loginButtonColor,

                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          registerNewUser(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              confirmPassController.text.trim(),
                              displayNameController.text.trim(),
                              _selectedYourPost,
                              _selectedYourRoute,
                              _selectedCountryCode + phoneController.text.trim());
                          // Submit form data here...
                        }
                      },
                      icon: const Icon(
                        Icons.lock_open,
                        size: 32,
                        color: loginButtonTextColor,
                      ),
                      label: const Text(
                        'Register',
                        style: TextStyle(fontSize: 24,color: loginButtonTextColor,),
                      )),
                  const SizedBox(height: 24),
                  GestureDetector(
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginWidget(),
                        ),
                      )
                          .then((_) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future registerNewUser(
      String email,
      String password,
      String confirmPassword,
      String displayName,
      selectedYourPost,
      selectedYourRoute,
      phoneNumber) async {
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        displayName.isEmpty) {
      PopupSnackBar.showSnackBar('Please enter all required field');
      return;
    }
    if (password != confirmPassword) {
      PopupSnackBar.showSnackBar('Password and Confirm Password should be same');
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      await user?.updateDisplayName(displayName);
      bool routeAccess =
          selectedYourPost == 'Driver' || selectedYourPost == 'Director';
      await AuthFirebase()
          .registerUserForGoogleMap(selectedYourPost, phoneNumber, email,
          displayName, selectedYourRoute, routeAccess, true)
          .then((_) {
        Navigator.of(context).pop();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }).catchError((error) {
        PopupSnackBar.showSnackBar(error);
        Navigator.of(context).pop();
      });
    } on FirebaseAuthException catch (e) {
      PopupSnackBar.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}
