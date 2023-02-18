import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlonglib;
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:school_erp/config/DynamicConstants.dart';
import 'package:school_erp/config/StaticConstants.dart';
import 'package:school_erp/domain/map/functions/Computational.dart';
import 'package:school_erp/domain/map/functions/DirectionsRepository.dart';
import 'package:school_erp/domain/map/functions/RealTimeDb.dart';
import 'package:school_erp/domain/map/models/Directions.dart';
import 'package:school_erp/domain/map/widgets/CustomFloatingButton.dart';
import 'package:school_erp/shared/functions/Computational.dart';
import 'package:school_erp/shared/functions/popupSnakbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class MapHomePage extends StatefulWidget {
  const MapHomePage({Key? key}) : super(key: key);

  @override
  State<MapHomePage> createState() => MapHomePageState();
}

class MapHomePageState extends State<MapHomePage> {
  BitmapDescriptor myLocationMaker = BitmapDescriptor.defaultMarker;
  late GoogleMapController googleMapController;
  final Completer<GoogleMapController> _controller = Completer();
  Location location = Location();
  final user = FirebaseAuth.instance.currentUser;
  late LatLng destination;
  late LatLng myLocation;
  late LatLng mapCameraLocation;
  LocationData? currentLocationData;
  LocationData? currentLocationDataOld;
  late StreamSubscription _firebaseSubscription;
  List<LatLng> polylineCoordinates = [];
  late Directions _info;
  bool infoUpdate = false;

  Set<Marker> markers = {};
  Set<Map<dynamic, dynamic>> allUserCompleteData = {};

  Map<dynamic, dynamic> currentUserdata = <dynamic, dynamic>{};
  Map<dynamic, dynamic> selectedUserdata = <dynamic, dynamic>{};
  String currentUid = '';
  String selectedUid = '';
  String _selectedRoute = '';
  bool _mounted = true;
  bool recordingStart = false;
  bool distanceLoaded = false;
  final Vector3 _orientation = Vector3.zero();

  void loadRouteInfo() async {
    List<String> routeList = [];
    final databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child("routes").onValue.listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        routeList.add(value);
      });
      if (_mounted) {
        setState(() {
          userRoute = routeList;
          _selectedRoute = userRoute[0];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    loadRouteInfo();
    getCoordinatesByRootId();
    getCurrentLocation();
    final user = this.user;
    if (user != null) {
      currentUid = user.uid;
    }
    setUp();
  }

  void setUp() async {
    zoomMap = await getZoomLevel();//from sharedPrefs
    if (_mounted) {
      setState(() {});
    }
  }


  Future<void> firstDistanceLoaded(double newDistance) async {
    if (!distanceLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('totalDistance', newDistance);
      distanceLoaded = true;
      if (_mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _firebaseSubscription.cancel();
    _mounted = false;
    super.dispose();
  }

  Future getCoordinatesByRootId() async {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('users');
    _firebaseSubscription = starCountRef.onValue.listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      allUserCompleteData.clear();
      data.forEach((key, value) {
        if (value['route'] == data[user?.uid]['route']) {
          if (key == currentUid) {
            currentUserdata = value;
          } else if (value['trackMe'] == true) {
            allUserCompleteData.add({key: value});
          }
        }
      });
      getLocationIcon();
      if (_mounted) {
        setState(() {});
      }
    });
  }

  Future<void> getLocationIcon() async {
    firstDistanceLoaded(currentUserdata['distance'] ?? 0);
    var defaultIcon = personIconAsset;
    if (currentUserdata['image'] != null &&
        currentUserdata['trackMe'] == true) {
      var url = Uri.parse(currentUserdata['image']);
      var request = await http.get(url);
      var dataBytes = request.bodyBytes;
      myLocationMaker =
          BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List());
    } else {
      String busIconDynamic = tiltMap > 30 ? busIconAsset : busTopIconAsset;
      String busOffIconDynamic =
          tiltMap > 30 ? busOffIconAsset : busTopOffIconAsset;
      if (currentUserdata['trackMe'] == true) {
        defaultIcon = currentUserdata['post'] == 'Driver'
            ? busIconDynamic
            : personIconAsset;
      } else {
        defaultIcon = currentUserdata['post'] == 'Driver'
            ? busOffIconDynamic
            : personOffIconAsset;
      }
      await BitmapDescriptor.fromAssetImage(
              ImageConfiguration.empty, defaultIcon)
          .then((value) {
        myLocationMaker = value;
      });
    }
  }

  void getCurrentLocation() async {
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 10, distanceFilter: 0);
    location.getLocation().then((value) {
      currentLocationData = value;
      myLocation = LatLng(
          setPrecision(currentLocationData!.latitude!, 3),
          setPrecision(currentLocationData!.longitude!, 3));
      mapCameraLocation = myLocation;
      if (_mounted) {
        setState(() {});
      }
    });

    googleMapController = await _controller.future;
    location.onLocationChanged.listen((newlocation) async {
      currentLocationData = newlocation;
      MapFirebase().setMyCoordinates(currentLocationData!.latitude!.toString(),
          currentLocationData!.longitude!.toString(), bearingMap);
      myLocation = LatLng(
          setPrecision(currentLocationData!.latitude!, 3),
          setPrecision(currentLocationData!.longitude!, 3));
      updateCoordinates();
      if (focusMe || focusDest) {
        if (focusMe) {
          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  bearing: bearingMap,
                  tilt: tiltMap,
                  zoom: zoomMap,
                  target: LatLng(currentLocationData!.latitude!,
                      currentLocationData!.longitude!))));
        } else if (selectedUid.isNotEmpty) {
          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  bearing: bearingMap,
                  tilt: tiltMap,
                  zoom: zoomMap,
                  target: destination)));
        }
      }
      if (selectedUid.isNotEmpty) {
        final directions = await DirectionsRepository().getDirections(
            origin: LatLng(currentLocationData!.latitude!,
                currentLocationData!.longitude!),
            destination: destination);
        infoUpdate = true;
        _info = directions;
      }
      updateDistanceTravelled();
      isRefresh = true;
      if (_mounted) {
        setState(() {});
      }
    });
    location.enableBackgroundMode(enable: true);

    FlutterCompass.events?.listen((event) {
      if (_mounted) {
        setState(() {
          bearingMap = event.heading!;
        });
      }
    });
    motionSensors.isOrientationAvailable().then((available) {
      if (available) {
        motionSensors.orientation.listen((OrientationEvent event) {
          if (_mounted) {
            setState(() {
              _orientation.setValues(event.yaw, event.pitch, event.roll);
              tiltMap = degrees(_orientation.y);
            });
          }
        });
      }
    });
  }

  Future<void> updateDistanceTravelled() async {
    currentLocationDataOld ??= currentLocationData;
    var distance = const latlonglib.Distance();
    final meter = distance(
        latlonglib.LatLng(currentLocationDataOld!.latitude!,
            currentLocationDataOld!.longitude!),
        latlonglib.LatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!));
    if (recordingStart) {
      distanceTravelled += meter / 1000;
      await setTotalDistanceTravelled(meter / 1000);
    }
    currentLocationDataOld = currentLocationData;
    if (_mounted) {
      setState(() {});
    }
  }

  void getPolyPoints() async {
    if (selectedUid.isEmpty) {
      return;
    }
    PolylinePoints polylinePoints = PolylinePoints();
    polylineCoordinates.clear();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!),
        PointLatLng(destination.latitude, destination.longitude));
    if (result.points.isNotEmpty) {
      polylineCoordinates = [];
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    final directions = await DirectionsRepository().getDirections(
        origin: LatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!),
        destination: destination);
    infoUpdate = true;
    _info = directions;
    if (_mounted) {
      setState(() {});
    }
  }

  void updateCoordinates() async {
    if (selectedUid.isNotEmpty) {
      var val = allUserCompleteData
          .firstWhere((element) => element.containsKey(selectedUid));
      selectedUserdata = val[selectedUid];
      destination = LatLng(double.parse(selectedUserdata['latitude']),
          double.parse(selectedUserdata['longitude']));
      getPolyPoints();
    }

    markers.add(
      Marker(
        rotation: bearingMap,
        infoWindow: InfoWindow(
            title: '${currentUserdata['post']}: ${user?.displayName}',
            snippet: 'Phone: ${currentUserdata['phone']}',
            onTap: () {}),
        icon: myLocationMaker,
        markerId: MarkerId(user?.email as String),
        position: LatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!),
      ),
    );
    for (var element in allUserCompleteData) {
      element.forEach((key, value) async {
        BitmapDescriptor locationMaker = BitmapDescriptor.defaultMarker;
        if (value['image'] != null) {
          var url = Uri.parse(value['image']);
          var request = await http.get(url);
          var dataBytes = request.bodyBytes;
          locationMaker =
              BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List());
        } else {
          String busIconDynamic =
              tiltMap > tiltMapThreshold ? busIconAsset : busTopIconAsset;
          await BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
                  value['post'] == 'Driver' ? busIconDynamic : personIconAsset)
              .then((value) => locationMaker = value);
        }

        double netDirection =
            netRotationDirection(value['direction'] ?? 0, bearingMap);
        markers.add(
          Marker(
            rotation: netDirection,
            onTap: () {
              selectedUid = key;
              selectedUserdata = value;
              destination = LatLng(double.parse(value['latitude']),
                  double.parse(value['longitude']));
              getPolyPoints();
            },
            infoWindow: InfoWindow(
                title: '${value['post']}: ${value['name']}',
                snippet: 'Call: ${value['phone']}',
                onTap: () {
                  PopupSnackBar().makePhoneCall(value['phone']);
                }),
            icon: locationMaker,
            markerId: MarkerId(key),
            position: LatLng(double.parse(value['latitude']),
                double.parse(value['longitude'])),
          ),
        );
      });
    }
    if (_mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid.isNotEmpty && currentUserdata['trackMe'] != null) {
      setState(() {
        _selectedRoute = currentUserdata['route'];
        iconVisible = currentUserdata['trackMe'];
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              flex: 1,
              child: Text(
                'R:',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
            ),
            Expanded(
              flex: 2,
              child: _selectedRoute.isNotEmpty
                  ? ((currentUserdata['routeAccess'] == true)
                      ? DropdownButton(
                          value: _selectedRoute,
                          items: userRoute.map((route) {
                            return DropdownMenuItem(
                              value: route,
                              child: Text(route),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            _selectedRoute = value ?? '';
                            await MapFirebase().setRoute(_selectedRoute);
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => const MapHomePage(),
                            ));
                            setState(() {});
                          },
                        )
                      : Text(
                          currentUserdata['route'] ?? 'Loading..',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20.0),
                        ))
                  : const Text('Loading..'),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${distanceTravelled.toStringAsFixed(2)}Km',
                style: const TextStyle(color: Colors.black, fontSize: 20.0),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: LiteRollingSwitch(
                  width: 90,
                  //initial value
                  onTap: () => {},
                  onDoubleTap: () => {},
                  onSwipe: () => {},
                  value: recordingStart,
                  textOn: 'End',
                  textOff: 'Start',
                  colorOn: Colors.greenAccent[700] as Color,
                  colorOff: Colors.redAccent[700] as Color,
                  iconOn: Icons.done,
                  iconOff: Icons.remove_circle_outline,
                  textSize: 16.0,
                  onChanged: (bool state) {
                    setState(() {
                      recordingStart = state;
                      // focusLiveLocation = value;
                    });
                  },
                ),
              ),
            ],
          )
        ],
      ),
      body: currentLocationData == null
          ? Center(
              child: TextButton(
                onPressed: () {
                  getCurrentLocation();
                },
                child: const Text('Click here to Reload'),
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  onCameraMove: (object) => {
                    setState(() {
                      mapCameraLocation = LatLng(
                          object.target.latitude, object.target.longitude);
                      focusMe = compareLatLang(
                          myLocation, mapCameraLocation, zoomPrecision);
                      if (selectedUid.isNotEmpty) {
                        focusDest = compareLatLang(
                            destination, mapCameraLocation, zoomPrecision);
                      }
                    })
                  },
                  mapType: MapType.hybrid,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  mapToolbarEnabled: true,
                  compassEnabled: true,
                  buildingsEnabled: true,
                  myLocationEnabled: true,
                  trafficEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                      bearing: bearingMap,
                      tilt: tiltMap,
                      target: LatLng(currentLocationData!.latitude!,
                          currentLocationData!.longitude!),
                      zoom: zoomMap),
                  polylines: {
                    Polyline(
                        polylineId: const PolylineId("route"),
                        points: polylineCoordinates,
                        color: primaryColor,
                        width: 6)
                  },
                  markers: markers,
                  onMapCreated: (mapController) {
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
      floatingActionButton: CustomFloatingButton( selectedUid: selectedUid),
    );
  }
}
