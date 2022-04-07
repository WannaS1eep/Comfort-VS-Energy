import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class MyAlgorithm {
  Map<String, int> participantTC = {};
  Map participantELSelected = {};
  Map participantEL = {};
  int currentSetting = 24;
  int atc = 0;
  String roomNumber;

  int round = 0;

  MyAlgorithm(this.roomNumber);

  // aggregated thermal comfort
  Future<void> calculateATC() async {
    participantTC = {};
    participantEL = {};
    participantELSelected = {};
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("users");
    QuerySnapshot snapshot = await collectionRef.get();

    double maxLoss = double.negativeInfinity;
    String maxLossParticipant = "";
    double minLoss = double.infinity;
    String minLossParticipant = "";
    for (DocumentSnapshot data in snapshot.docs) {
      if (data['location'] == roomNumber && data['voted']) {
        // -3 因为range是从0-6的

        // TODO: calculate the average value
        // double allVotes = 0;
        // data['votes'].forEach((value){
        //   allVotes += value;
        // });
        // allVotes /= data['votes'].length;

        // participantTC[data.id] = allVotes.round();

        participantTC[data.id] = data['votes'][round].round();
        if(data['votes'][round]>=currentSetting){
          participantTC[data.id] = data['votes'][round]-currentSetting>3? currentSetting+3 : data['votes'][round].round();
        }
        else{
          participantTC[data.id] = currentSetting-data['votes'][round]>3? currentSetting-3 : data['votes'][round].round();
        }


        // participantEL[data.id] = participantELLastRound[data.id] ?? 0.0;
        participantEL[data.id] = data['ael'];
        if (participantEL[data.id] > maxLoss) {
          maxLoss = participantEL[data.id].toDouble();
          maxLossParticipant = data.id;
        }
        if(participantEL[data.id] < minLoss){
          minLoss = participantEL[data.id].toDouble();
          minLossParticipant = data.id;
        }

        // reset the voted value
        // TODO
        // CollectionReference usersTable =
        //     FirebaseFirestore.instance.collection("users");
        // usersTable.doc(data.id).update({
        //   'voted': false,
        // });
      }
    }



    // if can't find Ps with max and min EL
    if(maxLossParticipant == "" || minLossParticipant == ""){
      return;
    }

    round ++;

    // They have the same value means there is only one p
    if(maxLossParticipant == minLossParticipant){
      atc = participantTC[maxLossParticipant]!;
      participantELSelected = getAllNextRoundEL(atc);
    }
    else{
      // 因为可能存在“EL最大减小，最小增大"不能满足的情况，所以先预设为这样
      atc = participantTC[maxLossParticipant] ?? currentSetting;
      participantELSelected = getAllNextRoundEL(atc);
      List settingList = [
        currentSetting,
        currentSetting + 1,
        currentSetting - 1,
        currentSetting + 2,
        currentSetting - 2,
        currentSetting + 3,
        currentSetting - 3,
      ];
      // use the bool value to get the first matched value in settingList
      bool flag = true;
      double maxMinAEL = double.negativeInfinity;
      for (int element in settingList) {

        // Next round AEL when the next setting is 'element'
        Map<String, double> participantELNextRound = getAllNextRoundEL(element);

        // 如果element可以使最大EL变小
        // If With the setting of 'element', the participant with max el will decrease
        if (participantELNextRound[maxLossParticipant]! <
            participantEL[maxLossParticipant]! ) {

          // on top of decreasing the max, increase the min.
          if(participantELNextRound[minLossParticipant]! > participantEL[minLossParticipant]!){
            atc = element;
            participantELSelected = participantELNextRound;
            maxMinAEL = participantELNextRound[minLossParticipant]!;
            break;
          }

          // if (flag) {
          //   atc = element;
          //   participantELSelected = participantELNextRound;
          //   flag = false;
          // }
          //
          // if (getGrossAbsAEL(participantELNextRound) <
          //     getGrossAbsAEL(participantEL)) {
          //   atc = element;
          //   participantELSelected = participantELNextRound;
          //   break;
          // }
        }
        // else{
        //   print("there");
        //   participantELSelected = getAllNextRoundEL(atc);
        // }
      }

      // atc 不能超过currentSetting 和participantTC的范围
      if(atc>participantTC[maxLossParticipant]! && atc> currentSetting){
        atc = participantTC[maxLossParticipant]!;
        // print("works");
      }
      if(atc<participantTC[maxLossParticipant]! && atc< currentSetting){
        atc = participantTC[maxLossParticipant]!;
        // print("works");
      }
    }



    currentSetting = atc;


    // update the current setting value
    CollectionReference currentValue =
        FirebaseFirestore.instance.collection('CurrentValue');
    currentValue.doc('currentTemp').update({roomNumber: atc});
    print(atc.toString() + '\n');

    participantELSelected.forEach((key, value) {
      CollectionReference currentValue =
          FirebaseFirestore.instance.collection('users');
      currentValue.doc(key).update({'ael': value});
    });
    print(participantTC);
    print(participantELSelected);

  }

  Map<String, double> getAllNextRoundEL(int nextATC) {
    Map<String, double> allNextRoundEL = {};
    double averageEL = 0;
    participantTC.forEach((key, value) {
      averageEL += (nextATC - value).abs();
    });
    averageEL /= participantTC.length;

    participantEL.forEach((key, value) {
      int a = (nextATC - participantTC[key]!).abs();
      double b = a - averageEL;

      allNextRoundEL[key] = participantEL[key] + b;
    });

    return allNextRoundEL;
  }

  double getGrossAbsAEL(Map ael) {
    double grossAbsAEL = 0.0;
    ael.forEach((key, value) {
      grossAbsAEL += value.abs();
    });
    return grossAbsAEL;
  }

  Future<void> start(int second) async {
    // Get the current temp setting
    Map<String, dynamic> data = {};
    await FirebaseFirestore.instance
        .collection("CurrentValue")
        .doc('currentTemp')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        data = documentSnapshot.data()! as Map<String, dynamic>;
      }
      if (data.isNotEmpty) {
        currentSetting = data[roomNumber];
      }
    });


    Timer.periodic(Duration(seconds: second), (Timer t) {
      calculateATC();
      // print("doing algorithm");
    });
  }
}
