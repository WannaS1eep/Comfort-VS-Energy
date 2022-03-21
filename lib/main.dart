import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myflutter/login.dart';
import 'element/participant_info.dart';
import 'algo/cal_tc.dart';
import 'sources/firebase_options.dart';
import 'main_tab_bar.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth auth = FirebaseAuth.instance;

  if(auth.currentUser == null){
    runApp(const MaterialApp(home: LoginPage()));
  }
  else{
    ParticipantInfo userInfo = ParticipantInfo();
    await userInfo.getUserInfoByID(auth.currentUser?.uid);
    // await FirebaseFirestore.instance.collection("users").doc(auth.currentUser?.uid).get()
    //     .then((DocumentSnapshot documentSnapshot){
    //   if(documentSnapshot.exists){
    //     Map<String, dynamic> data =
    //     documentSnapshot.data()! as Map<String, dynamic>;
    //     userInfo.userName = data["userName"];
    //     userInfo.location = data["location"];
    //     userInfo.noiseLvl = data["noiseLvl"];
    //     userInfo.tempStart = data["tempStart"];
    //     userInfo.tempEnd = data["tempEnd"];
    //   }
    // });
    runApp(MainTabBar(userInfo: userInfo));
    // TODO: else return error page
  }

  MyAlgorithm myAlgorithm = MyAlgorithm("1");
  myAlgorithm.start(2);
  // Timer.periodic(const Duration(seconds: 20), (Timer t){myAlgorithm.calculateATC("2");print("doing algorithm");});

}




