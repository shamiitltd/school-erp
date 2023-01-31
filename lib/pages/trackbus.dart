import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:school_erp/models/directions.dart';
import 'package:school_erp/shared/constants.dart';
import 'package:school_erp/shared/directions_repository.dart';

class BusTrackingPage extends StatefulWidget {
  const BusTrackingPage({Key? key}) : super(key: key);

  @override
  State<BusTrackingPage> createState() => BusTrackingPageState();
}

class BusTrackingPageState extends State<BusTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.411, -122.072);
  static const LatLng destination = LatLng(37.4227, -122.084);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentlocationData;
  late Directions _info;
  bool infoUpdate = false;

  late GoogleMapController googleMapController;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async{
    Location location = Location();
    location.getLocation().then((value) {
      setState(() {
        currentlocationData = value;
        getPolyPoints();
      });
    });
    googleMapController = await _controller.future;
    location.onLocationChanged.listen((newlocation) async{
      setState(()  {
        currentlocationData = newlocation;
      });
      if(focusLiveLocation){
        googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
                CameraPosition(
                    zoom: zoomMap,
                    target: LatLng(currentlocationData!.latitude!, currentlocationData!.longitude!)
                )
            )
        );
      }

      final directions = await DirectionsRepository()
          .getDirections(origin: LatLng(currentlocationData!.latitude!, currentlocationData!.longitude!), destination: destination);
      setState(() {
        infoUpdate = true;
        _info = directions;
      });

    });
  }

  void getPolyPoints() async{
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude)
    );
    if(result.points.isNotEmpty){
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        // print(currentlocationData!);
      });
    }
    final directions = await DirectionsRepository()
        .getDirections(origin: LatLng(currentlocationData!.latitude!, currentlocationData!.longitude!), destination: destination);
    setState(() {
      infoUpdate = true;
      _info = directions;
    });
  }

  void setCustomMarkerIcon(){
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/person.png").then((value)
    {
      sourceIcon = value;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/person.png").then((value)
    {
      destinationIcon = value;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/bus.png").then((value)
    {
      currentLocationIcon = value;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    getCurrentLocation();
    setCustomMarkerIcon();
    // getPolyPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Bus",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(focusLiveLocation?'Following':'Not following', style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0
              ),
              ),
              SizedBox(height: 12.0,),
              CupertinoSwitch(
                value: focusLiveLocation,
                onChanged: (value) {
                  setState(() {
                    focusLiveLocation = value;
                  });
                },
              ),
            ],
          )
        ],
      ),
      body:currentlocationData == null
          ? const Center(child: Text("Loading..."),)
          :Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
                target: sourceLocation,
                zoom: zoomMap
            ),
            polylines: {
              Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  color: primaryColor,
                  width: 6
              )
            },
            markers: {
              Marker(
                icon: currentLocationIcon,
                markerId: MarkerId("currentLocation"),
                position: LatLng(currentlocationData!.latitude!, currentlocationData!.longitude!),
              ),Marker(
                icon: sourceIcon,
                markerId: MarkerId("source"),
                position: sourceLocation,
              ),Marker(
                infoWindow: InfoWindow(
                    title: 'Bus: 2309sjf',
                    snippet: 'Driver: Mohan',
                    onTap: (){
                      print("Pop up clicked");
                    }
                ),
                // onTap: _calculatedDistDuration,
                icon: destinationIcon,
                markerId: MarkerId("destination"),
                position: destination,
              ),
            },
            onMapCreated: (mapController){
              _controller.complete(mapController);
            },
          ),
          if (infoUpdate)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info.totalDistance}, ${_info.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
