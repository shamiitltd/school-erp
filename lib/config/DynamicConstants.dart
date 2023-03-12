
//Dynamic variables
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

int selectedIndex = 0;
int sepFlag = 0; //serperate both drawer and bottom nav

double distanceTravelled = 0;
double totalDistanceTravelled=0;
// late LatLng myLocation;
// late LatLng mapCameraLocation;
// LocationData? currentLocationData;
// LocationData? currentLocationDataOld;
bool recordingStart = false;
bool distanceLoaded = false;
bool isLocationBackground = true;


bool focusMe = true;
bool focusDest = false;
int zoomPrecision = 3;
bool floatingMini = true;

double zoomMap = 15.5; //when you increase the value it will zoom the map
bool iconVisible = true;
int delayRecording = 10;//in seconds
int speed = 0;

double bearingMap = 0;
double tiltMap = 56.440717697143555;
double tiltMapThreshold = 30;
bool isRefresh = true;
bool isSettingOpen = false;

String busIconUrl = 'https://learn.geekspool.com/wp-content/uploads/mapicons/bus.png';
String personIconUrl = 'https://learn.geekspool.com/wp-content/uploads/mapicons/person.png';
List<String> userPosts = [];
List<String> userRoute = [];
enum DrawerSections {
  dashboard,
  chat,
  trackbus,
  fee,
  settings,
  notifications,
  visitors,
  send_feedback,
  profile,
  dummy, logout
}
