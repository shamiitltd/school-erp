import 'package:flutter/material.dart';

class ChatActivity extends StatefulWidget {
  const ChatActivity({Key? key}) : super(key: key);

  @override
  State<ChatActivity> createState() => _ChatActivityState();
}

class _ChatActivityState extends State<ChatActivity> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text("Chat Page",
          style: TextStyle(
            color: Colors.red[200],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
