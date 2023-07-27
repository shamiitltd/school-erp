import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:school_erp/domain/map/config/constants.dart';


class MapFirebase{
  final user = FirebaseAuth.instance.currentUser;

  Future<void> setMyCoordinatesOptimized(
      String latitude, String longitude, double direction) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("routesAll/$myRoute/$myCategory/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "latitude": latitude,
      "longitude": longitude,
      "direction": direction,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
    if(myOldRoute.isNotEmpty){
      await removeMeFromRoute(myOldRoute);
    }
  }

  Future<void> setRouteOptimized( String route) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "route": route,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
    if(myOldRoute.isNotEmpty){
      await removeMeFromRoute(myOldRoute);
    }
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
    if(trackMe == false){
      await removeMeFromRoute(myRoute);
    }
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

  Future<void> removeMeFromRoute(String route) async {
    DatabaseReference ref =
    FirebaseDatabase.instance.ref().child("routesAll/$route/$myCategory/${user?.uid}");
    await ref.remove().then((_) {myOldRoute='';})
        .catchError((error) {});
  }

  Future<void> setMyLastCoordinates(
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

}

