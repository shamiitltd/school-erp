
//Dynamic variables
double distanceTravelled = 0;
double totalDistanceTravelled=0;

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
List<String> userPosts = ['Student', 'Driver', 'Teacher', 'Principle', 'Director',];
List<String> userRoute = ['R1', 'R2', 'R3', 'A1', 'C3',];
enum DrawerSections {
  dashboard,
  chat,
  trackbus,
  fee,
  settings,
  notifications,
  send_feedback,
  profile,
  dummy, logout
}
