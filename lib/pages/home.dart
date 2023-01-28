import 'package:flutter/material.dart';
import 'package:school_erp/pages/dashboard.dart';
import 'package:school_erp/pages/chat.dart';
import 'package:school_erp/pages/fee.dart';
import 'package:school_erp/pages/profile.dart';
import 'package:school_erp/pages/trackbus.dart';
import 'package:school_erp/static/constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  var currentPage = DrawerSections.dashboard;
  int sepflag = 0;//serperate both drawer and bottom nav

  void _onItemTapped(int index) {
    setState(() {
      sepflag = 0;
      _selectedIndex = index;
      if (index == 0) {
        currentPage = DrawerSections.dashboard;
      } else if (index == 1) {
        currentPage = DrawerSections.chat;
      } else if (index == 2) {
        currentPage = DrawerSections.trackbus;
      }else if (index == 3) {
        currentPage = DrawerSections.profile;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var container;
    if (currentPage == DrawerSections.dashboard ) {
      container = Dashboard();
    } else if (currentPage == DrawerSections.chat ) {
      container = ChatActivity();
    } else if (currentPage == DrawerSections.trackbus ) {
      container = TrackBusActivity();
    } else if (currentPage == DrawerSections.fee) {
      container = FeeActivity();
    } else if (currentPage == DrawerSections.settings) {
      container = ProfileActivity();
    } else if (currentPage == DrawerSections.notifications) {
      container = FeeActivity();
    }else if (currentPage == DrawerSections.send_feedback) {
      container = FeeActivity();
    }else if (currentPage == DrawerSections.profile) {
      container = ProfileActivity();
    }

    return Scaffold(
      appBar: AppBar(
        // leading: Icon(Icons.menu),
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            MyHeaderDrawer(),
            MyDrawerList()
          ],
        ),
        ),
      ),
      body: container,
      bottomNavigationBar: BottomNavBar() // This trailing comma makes auto-formatting nicer for build methods.
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
          menuItem(3, "Track Bus", Icons.bus_alert,
              currentPage == DrawerSections.trackbus ? true : false),
          menuItem(4, "Fee", Icons.currency_rupee,
              currentPage == DrawerSections.fee ? true : false),
          Divider(),
          menuItem(5, "Settings", Icons.settings_outlined,
              currentPage == DrawerSections.settings ? true : false),
          menuItem(6, "Notifications", Icons.notifications_outlined,
              currentPage == DrawerSections.notifications ? true : false),
          Divider(),
          menuItem(7, "Send feedback", Icons.feedback_outlined,
              currentPage == DrawerSections.send_feedback ? true : false),
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
          setState(() {
            if(id > navlen){
              _selectedIndex=0;
              sepflag = 1;
            } else{
              _selectedIndex = id-1;
              sepflag = 0;
            }
            if (id == 1) {
              currentPage = DrawerSections.dashboard;
            } else if (id == 2) {
              currentPage = DrawerSections.chat;
            } else if (id == 3) {
              currentPage = DrawerSections.trackbus;
            } else if (id == 4) {
              currentPage = DrawerSections.fee;
            } else if (id == 5) {
              currentPage = DrawerSections.settings;
            } else if (id == 6) {
              currentPage = DrawerSections.notifications;
            } else if (id == 7) {
              currentPage = DrawerSections.send_feedback;
            }
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
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
                  style: TextStyle(
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

  Widget BottomNavBar(){
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon:const Icon(Icons.home),
          label: 'Home',
          backgroundColor: Colors.indigo[bnBarColor],
        ),
        BottomNavigationBarItem(
          icon:const Icon(Icons.chat),
          label: 'Chat',
          backgroundColor: Colors.brown[bnBarColor],
        ),
        BottomNavigationBarItem(
          icon:const Icon(Icons.bus_alert),
          label: 'Track Bus',
          backgroundColor: Colors.green[bnBarColor],
        ),
        BottomNavigationBarItem(
          icon:const Icon(Icons.person_outline_outlined),
          label: 'Profile',
          backgroundColor: Colors.purple[bnBarColor],
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: sepflag ==0? Colors.deepOrange[deepColor]:Colors.white,
      onTap: _onItemTapped,
    );
  }
  Widget MyHeaderDrawer(){
    return Material(
      color: Colors.green[700],
      child: InkWell(
        onTap: (){
          Navigator.pop(context);
          setState(() {
            sepflag = 0;
            _selectedIndex = 3;
            currentPage = DrawerSections.profile;
          });
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/shamiitlogo.jpg'),
                  ),
                ),
              ),
              Text(
                "SHAMIIT LIMITED",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                "info@shamiit.com",
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
