
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthFirebase{
  final user = FirebaseAuth.instance.currentUser;

  Future<dynamic> registerUserForGoogleMap(String post, String phoneNumber, String email, String displayName,
      String route, bool routeAccess, bool trackMe) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "post": post, //Student, Teacher, Principle
      "phone": phoneNumber,
      "email": email,
      "name": displayName,
      "distance": 0,
      "route": route,
      "routeAccess": routeAccess,
      "trackMe": trackMe, //'default'
    };
    return await databaseReference
        .update(updateValues);
  }
}