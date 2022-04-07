
import 'package:cloud_firestore/cloud_firestore.dart';

class AddP{

  CollectionReference collectionRef =
    FirebaseFirestore.instance.collection("users");

  void add(){
    collectionRef.doc("room7_p3").set({
      'location': "7",
      'ael': 0,
      'votes': [
        24,
        24,
        24,
        24,
        24,
        24,
        24,
        24,

      ],
      'voted': true,
    });
  }

  Future<void> resetAEL(String roomNumber) async {

    QuerySnapshot snapshot = await collectionRef.get();
    for (DocumentSnapshot data in snapshot.docs) {
      if (data['location'] == roomNumber) {
        collectionRef.doc(data.id).update({"ael":0});
      }
    }
  }
}

