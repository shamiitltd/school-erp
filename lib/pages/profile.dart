import 'package:flutter/material.dart';

class ProfileActivity extends StatefulWidget {
  const ProfileActivity({Key? key}) : super(key: key);

  @override
  State<ProfileActivity> createState() => _ProfileActivityState();
}

class _ProfileActivityState extends State<ProfileActivity> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text("Profile Page",
          style: TextStyle(
            color: Colors.red[200],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
