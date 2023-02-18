import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class MapFirebase{
  final user = FirebaseAuth.instance.currentUser;

  Future<void> setMyCoordinates(
      String latitude, String longitude, double direction) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "latitude": latitude,
      "longitude": longitude,
      "direction": direction,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }

  Future<void> setRoute( String route) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "route": route,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }


  Future<void> setTraceMe(bool trackMe) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "trackMe": trackMe,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }

  Future<void> setDistance(double distance) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "distance": distance,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }


}

