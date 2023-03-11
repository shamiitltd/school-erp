import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_erp/domain/Visitors/addVisitor.dart';

class ViewVisitors extends StatefulWidget {
   ViewVisitors({Key? key}) : super(key: key);

  CollectionReference reference =
  FirebaseFirestore.instance.collection('messages');

 late Stream<QuerySnapshot> _stream;

  @override
  State<ViewVisitors> createState() => _ViewVisitorsState();

}

class _ViewVisitorsState extends State<ViewVisitors> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextFormField(),
          TextFormField(),
          TextFormField(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddVisitor()),
          );

        },
        child: Icon(Icons.add),
      ),
    );
  }
}
