import 'package:flutter/material.dart';

const String google_api_key = 'AIzaSyA1g6mpa9tyUByIKIS0eiIW04G8OmOOGp4';
const Color primaryColor = Color(0xF44336FF);
const double defaultPadding = 16.0;
int bnBarColor = 200;
int deepColor = 800;
int navlen = 3;
bool focusLiveLocation = true;
const double zoomMap = 15.5; //when you increase the value it will zoom the map

enum DrawerSections {
  dashboard,
  chat,
  trackbus,
  fee,
  settings,
  notifications,
  send_feedback,
  profile,
  dummy
}