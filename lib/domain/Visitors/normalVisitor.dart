import 'package:flutter/material.dart';
import 'package:school_erp/config/Colors.dart';
import 'package:school_erp/domain/authentication/widgets/ResuableWidgets.dart';

class NormalVisitor extends StatefulWidget {
  const NormalVisitor({Key? key}) : super(key: key);

  @override
  State<NormalVisitor> createState() => _normalVisitorState();
}

class _normalVisitorState extends State<NormalVisitor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
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
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.001002, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  logoWidget("assets/shamiitlogo.png"),
                  TextFormField(
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

                  ),
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
}
