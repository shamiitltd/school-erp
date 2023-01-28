import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

class TrackBusActivity extends StatefulWidget {
  const TrackBusActivity({Key? key}) : super(key: key);

  @override
  State<TrackBusActivity> createState() => _TrackBusActivityState();
}

class _TrackBusActivityState extends State<TrackBusActivity> {
  // Position? _currentPosition;
  // double? distanceInMeter;
  //
  // Future _getTheDistance() async{
  //   _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   double oldlat = 33.35353;
  //   double oldlong = -234.352;
  //   var distanceInMtr = await Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, oldlat, oldlong);
  //   setState(() {
  //     distanceInMeter = distanceInMtr;
  //   });
  // }
  // @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getTheDistance();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text("Track Bus Page ",
          style: TextStyle(
            color: Colors.red[200],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
