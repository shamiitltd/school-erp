
import 'package:school_erp/domain/map/functions/RealTimeDb.dart';
import 'package:school_erp/shared/functions/Computational.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<double> getTotalDistanceTravelled() async {
  final prefs = await SharedPreferences.getInstance();
  double? distance = prefs.getDouble('totalDistance');
  return distance ?? 0;
}

double netRotationDirection(double givenAngle, double bearingMap){
  double netDirection = givenAngle - bearingMap;
  netDirection  = netDirection < - 180? (360+netDirection)%180 : netDirection;
  return netDirection;
}

Future<double> getZoomLevel() async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getDouble('zoom'))!;
}

Future<void> setTotalDistanceLoaded(double newDistance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalDistance', newDistance);
}

Future<void> setTotalDistanceTravelled(double newDistance) async {
  final prefs = await SharedPreferences.getInstance();
  double? oldDist = prefs.getDouble('totalDistance');
  if (oldDist != null) {
    newDistance += oldDist;
  }
  await prefs.setDouble('totalDistance', newDistance);
  MapFirebase().setDistance(newDistance);
}

bool compareLatLang(LatLng coordinate1, LatLng coordinate2, int precision) {
  return (setPrecision(coordinate1.longitude, precision) ==
      setPrecision(coordinate2.longitude, precision) &&
      setPrecision(coordinate1.latitude, precision) ==
          setPrecision(coordinate2.latitude, precision));
}