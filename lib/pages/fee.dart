import 'package:flutter/material.dart';

class FeeActivity extends StatefulWidget {
  const FeeActivity({Key? key}) : super(key: key);

  @override
  State<FeeActivity> createState() => _FeeActivityState();
}

class _FeeActivityState extends State<FeeActivity> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text("Fee Page",
          style: TextStyle(
            color: Colors.red[200],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
