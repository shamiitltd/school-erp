import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_erp/config/Colors.dart';
import 'package:school_erp/config/DynamicConstants.dart';
import 'package:school_erp/domain/erpwebsite/ErpWebView.dart';
import 'package:school_erp/domain/map/MapHome.dart';
import 'package:school_erp/domain/map/RecordRoute.dart';
import 'package:school_erp/pages/chat.dart';
import 'package:school_erp/pages/fee.dart';
import 'package:school_erp/pages/profile.dart';
import 'package:school_erp/res/assets_res.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  var currentPage = DrawerSections.dashboard;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int count =0;
  double navTopPadding = 60;

  @override
  Future<void> initState() async {
    super.initState();
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        sepFlag = 0;
        selectedIndex = index;
        // navTopPadding=20;
        if (index == 0) {
          currentPage = DrawerSections.dashboard;
          navTopPadding =60;
        } else if (index == 1) {
          currentPage = DrawerSections.chat;
        } else if (index == 2) {
          currentPage = DrawerSections.profile;
        } else if (index == 3) {
          currentPage = DrawerSections.trackbus;
          // Navigator.of(context).push(MaterialPageRoute(
          //   builder: (context) => const MapHomePage(),
          // ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // getCurrentLocation();
    var container;
    if (currentPage == DrawerSections.dashboard) {
      container = WebViewExample();
    } else if (currentPage == DrawerSections.chat) {
      container = ChatActivity();
    }  else if (currentPage == DrawerSections.fee) {
      container = FeeActivity();
    }  else if (currentPage == DrawerSections.trackbus) {
      container = MapHomePage();
    } else if (currentPage == DrawerSections.settings) {
      container = ProfileActivity();
    } else if (currentPage == DrawerSections.notifications) {
      container = FeeActivity();
    } else if (currentPage == DrawerSections.send_feedback) {
      container = WebViewExample();
    } else if (currentPage == DrawerSections.profile) {
      container = ProfileActivity();
    } else if (currentPage == DrawerSections.logout) {
      FirebaseAuth.instance.signOut();
    }else{
      container = const Text('Empty');
    }

    return WillPopScope(
      onWillPop: () async{
        return Future.value(true);
        // setState(() {
        //   count++;
        // });
        // print('Home Page');
        // print(count);
        // if(count > 2){
        //   return Future.value(true);
        // }else{
        //   return Future.value(false);
        // }
      },
      child: Scaffold(
          key: _scaffoldKey,
          endDrawer: Drawer(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[MyHeaderDrawer(), MyDrawerList()],
              ),
            ),
          ),
          endDrawerEnableOpenDragGesture: true,
          body: SafeArea(child: container),
          floatingActionButton: favoriteButton(navTopPadding),
          floatingActionButtonLocation: FloatingActionButtonLocation
              .endTop,
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,

          bottomNavigationBar:
          BottomNavBar() // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
  Widget favoriteButton(double navTopPadding) {
    return Padding(
      padding: EdgeInsets.only(top: navTopPadding),
      child: FloatingActionButton(
        mini: true,
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5)),
        onPressed: () async {
          _scaffoldKey.currentState?.openEndDrawer();
        },
        child: const Icon(Icons.menu),
      ),
    );
  }
  Widget MyDrawerList() {
    return Container(
      child: Column(
        // shows the list of menu drawer
        children: [
          menuItem(1, "Dashboard", Icons.dashboard_outlined,
              currentPage == DrawerSections.dashboard ? true : false),
          menuItem(2, "Chat", Icons.people_alt_outlined,
              currentPage == DrawerSections.chat ? true : false),
          menuItem(3, "Fee", Icons.currency_rupee,
              currentPage == DrawerSections.fee ? true : false),
          menuItem(4, "Track Bus GMAP", Icons.bus_alert,
              currentPage == DrawerSections.trackbus ? true : false),
          Divider(),
          menuItem(5, "Settings", Icons.settings_outlined,
              currentPage == DrawerSections.settings ? true : false),
          menuItem(6, "Track Bus OSM", Icons.bus_alert_outlined,
              currentPage == DrawerSections.notifications ? true : false),
          Divider(),
          menuItem(7, "Send feedback", Icons.feedback_outlined,
              currentPage == DrawerSections.send_feedback ? true : false),
          Divider(),
          menuItem(8, "Logout", Icons.logout,
              currentPage == DrawerSections.logout ? true : false),
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    return Material(
      color: selected ? Colors.grey[bnBarColor] : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (mounted) {
            setState(() {
              if (id > navlen) {
                selectedIndex = 0;
                sepFlag = 1;
              } else {
                selectedIndex = id - 1;
                sepFlag = 0;
              }
              if (id == 1) {
                currentPage = DrawerSections.dashboard;
              } else if (id == 2) {
                currentPage = DrawerSections.chat;
              } else if (id == 3) {
                currentPage = DrawerSections.fee;
              } else if (id == 4) {
                currentPage = DrawerSections.trackbus;
                // Navigator.of(context).push(MaterialPageRoute(
                //   builder: (context) => const MapHomePage(),
                // ));
              } else if (id == 5) {
                currentPage = DrawerSections.settings;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const WebViewExample(),
                ));
              } else if (id == 6) {
                currentPage = DrawerSections.notifications;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MapRecordPageOSM(),
                ));
              } else if (id == 7) {
                currentPage = DrawerSections.send_feedback;
              } else if (id == 8) {
                currentPage = DrawerSections.logout;
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget BottomNavBar() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'Home',
          backgroundColor: Colors.indigo[bnBarColor],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat),
          label: 'Chat',
          backgroundColor: Colors.brown[bnBarColor],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline_outlined),
          label: 'Profile',
          backgroundColor: Colors.green[bnBarColor],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bus_alert),
          label: 'Track Bus',
          backgroundColor: Colors.purple[bnBarColor],
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor:
      sepFlag == 0 ? Colors.deepOrange[deepColor] : Colors.white,
      onTap: _onItemTapped,
    );
  }

  Widget MyHeaderDrawer() {
    return Material(
      color: Colors.green[700],
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (mounted) {
            setState(() {
              sepFlag = 0;
              selectedIndex = 2;
              currentPage = DrawerSections.profile;
            });
          }
        },
        child: Container(
          width: double.infinity,
          height: 200,
          padding: EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(AssetsRes.SHAMIITLOGO),
                  ),
                ),
              ),
              Text(
                '${user?.displayName}',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                "${user?.email}",
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
