import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_erp/domain/authentication/widgets/ForgotPassword.dart';
import 'package:school_erp/domain/authentication/widgets/RegisterUser.dart';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                decoration:const InputDecoration(
                    labelText: 'Enter your email'
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) => email != null && !EmailValidator.validate(email)? 'Enter a valid email':null,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Enter your Password'
                ),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6? 'Enter min 6 characters':null,
                onFieldSubmitted: (_) {
                  _formKey.currentState!.validate();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      signIn();
                      // Submit form data here...
                    }
                  },
                  icon: const Icon(Icons.lock_open, size: 32,),
                  label: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 24),
                  )
              ),
              const SizedBox(height: 24),
              GestureDetector(
                child: Text(
                  'Register New User',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.secondary,
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
              const SizedBox(height: 24),
              GestureDetector(
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.secondary,
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
