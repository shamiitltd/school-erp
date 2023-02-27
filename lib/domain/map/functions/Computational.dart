
import 'dart:math';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:school_erp/config/DynamicConstants.dart';
import 'package:school_erp/config/StaticConstants.dart';
import 'package:school_erp/domain/map/functions/RealTimeDb.dart';
import 'package:school_erp/shared/functions/Computational.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlonglib;


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
  return (prefs.getDouble('zoom')??15);
}

Future<void> setTotalDistanceLoaded(double newDistance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalDistance', newDistance);
}

Future<void> setTotalDistanceTravelled(var firbaseClass, double newDistance) async {
  final prefs = await SharedPreferences.getInstance();
  double? oldDist = prefs.getDouble('totalDistance');
  if (oldDist != null) {
    newDistance += oldDist;
  }
  await prefs.setDouble('totalDistance', newDistance);
  firbaseClass.setDistance(newDistance);
}

bool compareLatLang(LatLng coordinate1, LatLng coordinate2, int precision) {
  return (setPrecision(coordinate1.longitude, precision) ==
      setPrecision(coordinate2.longitude, precision) &&
      setPrecision(coordinate1.latitude, precision) ==
          setPrecision(coordinate2.latitude, precision));
}

Future<bool> locationPermission() async {
  Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return false;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return false;
    }
  }
  await location.enableBackgroundMode(enable: isLocationBackground);
  return true;
}


void getCurrentLocation() async {
  if(!await locationPermission()) return;
  Location location = Location();
  location.changeSettings(
      accuracy: LocationAccuracy.high, interval: 10, distanceFilter: 0);
  location.getLocation().then((newLocation) {
    MapFirebase().setMyCoordinates(newLocation.latitude!.toString(),
        newLocation.longitude!.toString(), bearingMap);
  });

  location.onLocationChanged.listen((newLocation) async {
    // speed = ((newLocation.speed??0)*speedBias).toInt();
    MapFirebase().setMyCoordinates(newLocation.latitude!.toString(),
        newLocation.longitude!.toString(), bearingMap);
  });
}

String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  final minutes = duration.inMinutes;
  final hours = duration.inHours;

  if (hours > 0) {
    return '${hours}h ${minutes % 60}m';
  } else {
    return '${minutes}m';
  }
}
String formatDistance(double meters) {
  if (meters < 1000) {
    return '${meters.round()}m';
  } else {
    final km = meters / 1000;
    return '${km.toStringAsFixed(1)}km';
  }
}

List<latlonglib.LatLng> convertPointLatLngToLatLng(List<PointLatLng> pointLatLng){
  List<latlonglib.LatLng> result = [];
  pointLatLng.forEach((element) {
    result.add(latlonglib.LatLng(element.latitude, element.longitude));
  });
  return result;
}

double degreeToRadians(double degrees) {
  return degrees * pi / 180;
}

double normalizeAngle(double degrees) {
  if (degrees < 0) {
    degrees += 360.0;
  }
  return degrees % 360.0;
}

LatLng convertLatLangToGLatLang(latlonglib.LatLng latLng){
  return LatLng(latLng.latitude, latLng.longitude);
}

latlonglib.LatLng convertGLatLangToLatLang(LatLng latLng){
  return latlonglib.LatLng(latLng.latitude, latLng.longitude);
}
double netDirectionMyMap(double angle){
  return -angle;
}

// Future<LocationData?> updateDistanceTravelled(LocationData? currentLocationData) async {
//   currentLocationDataOld ??= currentLocationData;
//   var distance = const latlonglib.Distance();
//   final meter = distance(
//       latlonglib.LatLng(currentLocationDataOld!.latitude!,
//           currentLocationDataOld!.longitude!),
//       latlonglib.LatLng(
//           currentLocationData!.latitude!, currentLocationData.longitude!));
//   if (recordingStart) {
//     distanceTravelled += meter / 1000;
//     await setTotalDistanceTravelled(meter / 1000);
//   }
//   currentLocationDataOld = currentLocationData;
//   return currentLocationData;//now this will became old data.
// }

