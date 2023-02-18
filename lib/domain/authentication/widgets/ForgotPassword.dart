import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        title: const Text('Form'),
        backgroundColor: Colors.orange,
      ),
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
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration:const InputDecoration(
                    labelText: 'Enter your email'
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) => email != null && !EmailValidator.validate(email)? 'Enter a valid email':null,
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
                  icon: const Icon(Icons.email_outlined, size: 32,),
                  label: const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 24),
                  )
              ),
              const SizedBox(height: 24),
              GestureDetector(
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 20
                  ),
                ),
                onTap: (){
                  Navigator.of(context).pop();
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async{
    if(emailController.text.trim().isEmpty){
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context)=> const Center(child: CircularProgressIndicator())
    );
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
      );
      PopupSnackBar.showSnackBar('Password Reset Email Sent');
      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch(e){
      PopupSnackBar.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }

}

