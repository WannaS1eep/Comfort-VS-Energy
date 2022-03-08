import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';


class MyAlgorithm{
  Map<String, int> participantTC = {};
  Map participantELLastRound = {};
  Map participantEL = {};
  int currentSetting = 24;
  int atc = 0;
  String roomNumber;
  MyAlgorithm(this.roomNumber);



  // aggregated thermal comfort
  Future<int> calculateATC() async {
    participantTC = {};
    participantEL = {};
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection("users");
    QuerySnapshot snapshot = await collectionRef.get();

    double maxLoss = double.negativeInfinity;
    String maxLossParticipant = "";
    for(DocumentSnapshot data in snapshot.docs){
      if(data['location'] == roomNumber && data['pmv'] != -1){
        // -3 因为range是从0-6的
        participantTC[data['userName']] = data['pmv'].round() - 3 + currentSetting;
        participantEL[data['userName']] = participantELLastRound[data['userName']] ?? 0.0;
        if(participantEL[data['userName']] > maxLoss){
          maxLoss = participantEL[data['userName']];
          maxLossParticipant = data['userName'];
        }

        // reset the pvm
        CollectionReference usersTable =
        FirebaseFirestore.instance.collection("users");
        usersTable
            .doc(data.id)
            .update({
          'pmv': -1,
        });

      }
    }
    atc = participantTC[maxLossParticipant] ?? currentSetting;
    List settingList = [currentSetting+1, currentSetting-1,currentSetting+2,currentSetting-2,currentSetting+3,currentSetting-3];
    // use the bool value to get the first matched value in settingList
    bool flag= true;
    for (int element in settingList) {
      Map participantELNextRound = getAllNextRoundEL(element);
      // 新一轮的 最大的AEL减少
      if(maxLossParticipant != "" && participantELNextRound[maxLossParticipant] < participantEL[maxLossParticipant]){
        // 新一轮的 所有人总的AEL减少
        if(flag){
          atc = element;
          participantELLastRound = participantELNextRound;
          flag = false;
        }

        if(getGrossAbsAEL(participantELNextRound) < getGrossAbsAEL(participantEL)){
          atc = element;
          participantELLastRound = participantELNextRound;
          break;
        }
      }

    }

    currentSetting = atc;

    // update the current setting value
    CollectionReference currentValue = FirebaseFirestore.instance.collection('CurrentValue');
    currentValue.doc('currentTemp').update({roomNumber: atc.toString()});
    print(atc.toString() + '\n');



    return 1;
  }

  Map getAllNextRoundEL(int nextATC){
    Map allNextRoundEL = {};
    double averageEL = 0;
    participantTC.forEach((key, value) {
      averageEL += (nextATC-value).abs();
    });
    averageEL /= participantTC.length;

    participantEL.forEach((key, value) {
      int a = (nextATC - participantTC[key]!).abs();
      double b = a - averageEL;

      allNextRoundEL[key] = participantEL[key] + b;
    });

    return allNextRoundEL;
  }

  double getGrossAbsAEL(Map ael){
    double grossAbsAEL = 0.0;
    ael.forEach((key, value) {
      grossAbsAEL += value.abs();
    });
    return grossAbsAEL;
  }

  Future<void> start (int second) async {
    calculateATC();
    Timer.periodic(Duration(seconds: second), (Timer t){calculateATC();print("doing algorithm");});
  }

}


