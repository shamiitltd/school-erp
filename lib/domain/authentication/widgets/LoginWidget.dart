import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_erp/config/Colors.dart';
import 'package:school_erp/domain/authentication/widgets/ForgotPassword.dart';
import 'package:school_erp/domain/authentication/widgets/RegisterUser.dart';
import 'package:school_erp/domain/authentication/widgets/ResuableWidgets.dart';
import 'package:school_erp/shared/functions/popupSnakbar.dart';


class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          width: MediaQuery.of(context).size.width,
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
              padding:  EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height*0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  logoWidget("assets/shamiitlogo.png"),
                  TextFormField(
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginIconColor,
                    style: TextStyle(color: loginIconColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon:const Icon(Icons.person_outline,color: loginIconColor,),
                        labelText: 'Enter your email',
                      labelStyle: TextStyle(color: loginIconColor.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: loginIconColor.withOpacity(0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(width: 0,style: BorderStyle.none)),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) => email != null && !EmailValidator.validate(email)? 'Enter a valid email':null,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      _formKey.currentState!.save();
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginIconColor,
                    style: TextStyle(color: loginIconColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon:const Icon(Icons.lock,color: loginIconColor,),
                        labelText: 'Enter your Password',
                      labelStyle: TextStyle(color: loginIconColor.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: loginIconColor.withOpacity(0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(width: 0,style: BorderStyle.none)),
                    ),
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.length < 6? 'Enter min 6 characters':null,
                    onFieldSubmitted: (_) {
                      _formKey.currentState!.validate();
                      _formKey.currentState!.save();
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(

                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: loginIconColor,
                              fontSize: 20
                          ),
                        ),
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context)=> const ForgotPassword(),
                          ));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: loginButtonColor,
                              
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          signIn();
                          // Submit form data here...
                        }
                      },
                      icon: const Icon(Icons.lock_open, size: 32,color: loginColor1,),
                      label: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 24,color: loginColor1),
                      )
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    child: const Text(
                      'Register ? New User',
                      style: TextStyle(
                          color: loginIconColor,
                          fontSize: 20
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context)=> const RegisterUser(),
                        // builder: (context)=> const ForgotPassword(),
                      ));
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

  Future signIn() async{
    if(emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty){
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
         return const Center(child: CircularProgressIndicator());
        }
    );
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      ).then((_) {
        Navigator.of(context).pop();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }).catchError((error) {
        // print(error);
        PopupSnackBar.showSnackBar(error.toString());
        Navigator.of(context).pop();
      });
    } on FirebaseAuthException catch(e){
      PopupSnackBar.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }

}
