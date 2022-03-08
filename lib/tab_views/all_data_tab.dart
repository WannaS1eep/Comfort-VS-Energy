import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// read data from Firebase
class AllInfoTab extends StatefulWidget {
  const AllInfoTab({Key? key}) : super(key: key);

  @override
  _AllInfoTabState createState() => _AllInfoTabState();
}

class _AllInfoTabState extends State<AllInfoTab> {
  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
            document.data()! as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['userName'].toString()),
                subtitle: Text(
                    "\nRoom ${data["location"]},\t\tNoise Tolerance: Lvl.${data['noiseLvl']}   \n\nPreferred Temperature: ${data['tempStart'].toString()},  ${data['tempEnd'].toString()} "),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}