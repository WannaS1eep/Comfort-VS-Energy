import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';


class MyAlgorithm{
  Map<String, int> participantTC = {};
  Map participantEL = {};
  int currentSetting = 24;
  int atc = 0;
  double averageEL = 0.0;

  // aggregated thermal comfort
  Future<int> calculateATC(String roomNumber) async {
    averageEL = 0.0;
    participantTC = {};
    Map participantELCopy = {};
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection("users");
    QuerySnapshot snapshot = await collectionRef.get();

    double maxLoss = 0.0;
    for(DocumentSnapshot data in snapshot.docs){
      if(data['location'] == roomNumber){
        participantTC[data['userName']] = (data['tempStart'] + data['tempEnd'])~/2;
        participantELCopy[data['userName']] = participantEL[data['userName']] ?? 0.0;

        if(participantELCopy[data['userName']] > maxLoss){
          maxLoss = participantELCopy[data['userName']];
          atc = (data['tempStart'] + data['tempEnd'])~/2;
        }else if(participantELCopy[data['userName']] == maxLoss){
          // if the ELs are the same, choose the one which is close to the currentSetting
          int a = ((participantTC[data['userName']] ?? 0) - currentSetting).abs();
          int b = (atc - currentSetting).abs();
          atc = a<b? (data['tempStart'] + data['tempEnd'])~/2 : atc;
        }
      }
    }

    currentSetting = atc;

    participantTC.forEach((key, value) {
      averageEL += (atc-value).abs();
    });
    averageEL /= participantTC.length;

    participantELCopy.forEach((key, value) {
      int a = (atc - participantTC[key]!).abs();
      double b = a - averageEL;

      participantELCopy[key] += b;
    });
    participantEL = participantELCopy;

    CollectionReference currentValue = FirebaseFirestore.instance.collection('CurrentValue');
    currentValue.doc('currentTemp').update({roomNumber: atc.toString()});
    print(atc.toString() + '\n');
    participantEL.forEach((key, value) {print('\t' + key + '\t' + value.toString());});

    return 1;
  }


}


