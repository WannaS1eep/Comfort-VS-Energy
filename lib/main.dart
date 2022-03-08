import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myflutter/login.dart';
import 'package:myflutter/tab_views/all_data_tab.dart';
import 'package:myflutter/tab_views/current_states_tab.dart';
import 'package:myflutter/tab_views/user_profile_tab.dart';
import './register.dart';
import 'element/participantInfo.dart';
import 'algo/cal_tc.dart';
import 'firebase_options.dart';


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
  myAlgorithm.start(30);
  // Timer.periodic(const Duration(seconds: 20), (Timer t){myAlgorithm.calculateATC("2");print("doing algorithm");});

}

class MainTabBar extends StatelessWidget {

  MainTabBar({Key? key, required this.userInfo}) : items = <ItemView>[
  ItemView(title: "User", icon: Icons.account_box, view: UserProfileTab(userInfo: userInfo)),
  ItemView(title: "Current State", icon: Icons.content_paste, view: CurrentStatesTab(userInfo: userInfo,)),
  const ItemView(title: "All data", icon: Icons.table_rows_rounded, view: AllInfoTab()),
  ], super(key: key);
  final List<ItemView> items;
  final ParticipantInfo userInfo;



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TabBar",
      home: DefaultTabController(
        length: items.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My App'),
            bottom: TabBar(
              tabs: items.map((ItemView item) {
                return Tab(text: item.title, icon: Icon(item.icon));
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: items.map((ItemView item) {
              return Padding(padding: const EdgeInsets.all(12.0),
              child: item.view);
            }).toList()
          )
        ),
      ),
    );
  }
}


class ItemView {
  const ItemView({required this.title, required this.icon, required this.view});

  final String title;
  final IconData icon;
  final Widget view;
}


