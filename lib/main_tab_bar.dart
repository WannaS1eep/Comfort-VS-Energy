import 'package:flutter/material.dart';
import 'package:myflutter/tab_views/all_data_tab.dart';
import 'package:myflutter/tab_views/current_states_tab.dart';
import 'package:myflutter/tab_views/user_profile_tab.dart';

import 'element/participant_info.dart';

class MainTabBar extends StatelessWidget {
  MainTabBar({Key? key, required this.userInfo})
      : items = <ItemView>[
          ItemView(
              title: "User",
              icon: Icons.account_box,
              view: UserProfileTab(userInfo: userInfo)),
          ItemView(
              title: "Current State",
              icon: Icons.content_paste,
              view: CurrentStatesTab(
                userInfo: userInfo,
              )),
          const ItemView(
              title: "All data",
              icon: Icons.table_rows_rounded,
              view: AllInfoTab()),
        ],
        super(key: key);
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
              return Padding(
                  padding: const EdgeInsets.all(12.0), child: item.view);
            }).toList())),
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
