import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_erp/domain/Visitors/addVisitor.dart';

class ViewVisitors extends StatefulWidget {
  @override
  _ViewVisitorsState createState() => _ViewVisitorsState();
}

class _ViewVisitorsState extends State<ViewVisitors> {
  CollectionReference visitors =
  FirebaseFirestore.instance.collection('messages');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: visitors.orderBy('timestamp', descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }else{

            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;

                DateTime dateTime = data['timestamp'].toDate();
                String formattedDateTime = DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);

                return Card(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(data['imageUrl']??''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text('Name: ${data['name']}'),
                            const SizedBox(height: 5),
                            Text('Phone: ${data['phone']}'),
                            const SizedBox(height: 5),
                            Text('Email: ${data['email']}'),
                            const SizedBox(height: 5),
                            Text('Address: ${data['address']}'),
                            const SizedBox(height: 5),
                            Text('Reason: ${data['message']}'),
                            const SizedBox(height: 5),
                            Text('Timestamp: $formattedDateTime'),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // TODO: Add edit functionality
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVisitor()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
