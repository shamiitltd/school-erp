import 'package:flutter/material.dart';

Image logoWidget(String imageName){
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 100,
    height: 100,
  );
}
Container SignInSignUpButton(BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)){
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))
      ),
      child:  Text(
        isLogin ? 'Log In' : 'Sign Up',
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),



    ),
  );
}