
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_erp/domain/map/functions/Computational.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    // Get route information
    final data = Map<String, dynamic>.from(map['routes'][0]);

    // Bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    // Distance & Duration
    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    return Directions(
      bounds: bounds,
      polylinePoints:
      PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration,
    );
  }


  factory Directions.fromOsmMap(Map<String, dynamic> map) {
    List<PointLatLng> polylinePointLatLang = [];
    final result = Map<String, dynamic>.from(map['routes'][0]);
    final polylinePoints = result['geometry']['coordinates'];

    for (var point in polylinePoints) {
      polylinePointLatLang.add(PointLatLng(point[1], point[0]));
    }
    final northeast = map['waypoints'][0]['location'];
    final southwest = map['waypoints'][1]['location'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast[1], northeast[0]),
      southwest: LatLng(southwest[1], southwest[0]),
    );

    // Distance & Duration
    final durationVal = result['duration'];
    final distanceVal = result['distance'];
    String distance = formatDistance(distanceVal);
    String duration = formatDuration(durationVal.toInt());

    return Directions(
      bounds: bounds,
      polylinePoints:polylinePointLatLang,
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}