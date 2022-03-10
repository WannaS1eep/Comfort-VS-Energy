import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantInfo {
  String email = "";
  String password = "";
  String userName = "";
  String location = "";
  String noiseLvl = "";
  int tempStart = 21;
  int tempEnd = 24;

  Future<void> getUserInfoByID(String? userID) async {

    await FirebaseFirestore.instance.collection("users").doc(userID).get()
    .then((DocumentSnapshot documentSnapshot){
      if(documentSnapshot.exists){
        Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;
        userName = data["userName"];
        location = data["location"];
        noiseLvl = data["noiseLvl"];
        tempStart = data["tempStart"];
        tempEnd = data["tempEnd"];
      }
    });

  }

}