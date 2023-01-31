import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_erp/models/directions.dart';
import 'package:school_erp/shared/constants.dart';


class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository() : _dio = Dio();

  Future<Directions> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': google_api_key,
        },
      );
      // Check if response is successful
      if (response.statusCode == 200) {
        return Directions.fromMap(response.data);
      }
    } catch (e) {
      // print('king ji e');
    }

    return Directions(
      bounds: LatLngBounds(
        northeast: destination,
        southwest: origin,
      ),
      polylinePoints: PolylinePoints().decodePolyline(''),
      totalDistance: '',
      totalDuration: '',
    );
  }
}
