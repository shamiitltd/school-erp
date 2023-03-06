import 'package:flutter/material.dart';
import 'package:school_erp/domain/Visitors/addVisitor.dart';

class ViewVisitors extends StatefulWidget {
  const ViewVisitors({Key? key}) : super(key: key);

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
