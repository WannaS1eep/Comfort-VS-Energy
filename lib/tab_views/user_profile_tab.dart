import 'package:flutter/material.dart';
import 'package:myflutter/login.dart';
import '../element/participant_info.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserProfileTab extends StatefulWidget {
  const UserProfileTab({Key? key, required this.userInfo}) : super(key: key);

  final ParticipantInfo userInfo;

  @override
  State<UserProfileTab> createState() => _UserProfileTabState();
}

class _UserProfileTabState extends State<UserProfileTab> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 16),
                child: TextFormField(
                  // initialValue: widget.userInfo.userName,
                  enabled: false,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: widget.userInfo.userName,
                      prefixIcon: const Icon(Icons.person)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }

                    return null;
                  },

                ),
              ),


              ElevatedButton(onPressed: (){
                FirebaseAuth.instance.signOut();
                runApp(const LoginPage());
              }, child: const Text("Sign Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}