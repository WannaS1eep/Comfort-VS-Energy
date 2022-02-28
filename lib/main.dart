import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myflutter/login.dart';
import './register.dart';
import 'element/tab_views.dart';
import './cal_tc.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth auth = FirebaseAuth.instance;

  if(auth.currentUser == null){
    runApp(const MaterialApp(title: "Register",home: LoginPage()));
  }
  else{
    runApp(const MaterialApp(home: MainTabBar()));
  }

  // MyAlgorithm myAlgorithm = MyAlgorithm();
  // Timer.periodic(const Duration(seconds: 20), (Timer t){myAlgorithm.calculateATC("2");print("doing algorithm");});

}

class MainTabBar extends StatelessWidget {
  const MainTabBar({Key? key}) : super(key: key);

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

const List<ItemView> items = <ItemView>[
  ItemView(title: "User", icon: Icons.account_box, view: UserProfileTab()),
  ItemView(title: "Current State", icon: Icons.content_paste, view: CurrentValueTab(roomNumber: "2",)),
  ItemView(title: "All data", icon: Icons.table_rows_rounded, view: AllInfoTab()),

];
