import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_erp/config/Colors.dart';
import 'package:school_erp/domain/authentication/widgets/ResuableWidgets.dart';
import 'package:school_erp/shared/functions/popupSnakbar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              loginColor1,
              loginColor2,
              loginColor3,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  logoWidget("assets/shamiitlogo.png"),
                  TextFormField(
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: loginIconColor,
                      ),
                      labelText: 'Enter your email',
                      labelStyle:
                          TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.solid,
                              color: loginIconColor)),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter a valid email'
                            : null,
                    onFieldSubmitted: (_) {
                      _formKey.currentState!.validate();
                      _formKey.currentState!.save();
                    },
                  ),
                  const SizedBox(height: 10),
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
                          signIn();
                          // Submit form data here...
                        }
                      },
                      icon: const Icon(
                        Icons.email_outlined,
                        size: 32,
                        color: loginButtonTextColor,
                      ),
                      label: const Text(
                        'Reset Password',
                        style: TextStyle(
                            fontSize: 24, color: loginButtonTextColor),
                      )),
                  const SizedBox(height: 24),
                  GestureDetector(
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(color: loginIconColor, fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
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

  Future signIn() async {
    if (emailController.text.trim().isEmpty) {
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      PopupSnackBar.showSnackBar('Password Reset Email Sent');
      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      PopupSnackBar.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}
