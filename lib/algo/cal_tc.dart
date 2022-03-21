import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAlgorithm {
  Map<String, int> participantTC = {};
  Map participantELSelected = {};
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
    double minLoss = double.infinity;
    String minLossParticipant = "";
    for (DocumentSnapshot data in snapshot.docs) {
      if (data['location'] == roomNumber && data['voted']) {
        // -3 因为range是从0-6的
        double allVotes = 0;
        data['votes'].forEach((value){
          allVotes += value;
        });
        allVotes /= data['votes'].length;
        participantTC[data.id] = allVotes.round();
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
    atc = participantTC[maxLossParticipant] ?? currentSetting;
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

      Map<String, double> participantELNextRound = getAllNextRoundEL(element);
      // 新一轮的 最大的AEL减少
      if (maxLossParticipant != "" &&
          participantELNextRound[maxLossParticipant]! <
              participantEL[maxLossParticipant]! ) {
        // 新一轮的 所有人总的AEL的绝对值减少

        if(participantELNextRound[minLossParticipant]! >maxMinAEL){
          atc = element;
          participantELSelected = participantELNextRound;
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

    if(atc>participantTC[maxLossParticipant]! && atc> currentSetting){
      atc = participantTC[maxLossParticipant]!;
      print("works");
    }
    if(atc<participantTC[maxLossParticipant]! && atc< currentSetting){
      atc = participantTC[maxLossParticipant]!;
      print("works");
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
    print(participantELSelected);
    return 1;
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
    // Get and set current temp setting
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


    calculateATC();
    Timer.periodic(Duration(seconds: second), (Timer t) {
      calculateATC();
      // print("doing algorithm");
    });
  }
}
