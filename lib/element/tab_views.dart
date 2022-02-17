import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import './participantInfo.dart';

ParticipantInfo currentUserInfo = ParticipantInfo();
RangeValues temperatureRangeValues = const RangeValues(21, 24);

class RegisterTab extends StatefulWidget {
  const RegisterTab({Key? key}) : super(key: key);

  @override
  State<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  final _formKey = GlobalKey<FormState>();

  // map of rooms, facilitate expansion
  Map<String, String> rooms = {"Room1": "1", "Room2": "2", "Room3": "3"};
  String _selectedLocation = "0";
  String _selectedNoiseLvl = "0";

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
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[
              // TextFormField(
              //   decoration: const InputDecoration(
              //       labelText: "Email",
              //       hintText: "You will use your email to login",
              //       prefixIcon: Icon(Icons.email)),
              //   validator: (value) {
              //     if (value == null ||
              //         value.isEmpty ||
              //         EmailValidator.validate(value) == null) {
              //       return 'A valid email is required';
              //     }
              //     currentUserInfo.email = value;
              //     return null;
              //   },
              // ),
              // TextFormField(
              //   decoration: const InputDecoration(
              //     labelText: "Password",
              //     hintText: "Enter Your Password",
              //     prefixIcon: Icon(Icons.password),
              //     enabledBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(color: Colors.black12),
              //     ),
              //     focusedBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(color: Colors.blue),
              //     ),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.length < 6) {
              //       return 'A valid email with length >= 6 is required';
              //     }
              //     currentUserInfo.password = value;
              //     return null;
              //   },
              //   obscureText: true,
              // ),
              // TextFormField(
              //   decoration: const InputDecoration(
              //       labelText: "Confirm your Password",
              //       hintText: "Enter Your Password Again",
              //       prefixIcon: Icon(null)),
              //   validator: (value) {
              //     if (value == null ||
              //         value.isEmpty ||
              //         value != currentUserInfo.password) {
              //       return "The passwords doesn't match";
              //     }
              //     return null;
              //   },
              //   obscureText: true,
              // ),
              TextFormField(
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "User Name",
                    prefixIcon: Icon(Icons.person)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  currentUserInfo.userName = value;
                  return null;
                },
              ),

              const Divider(
                height: 20.0,
                indent: 10.0,
                endIndent: 10.0,
                color: Colors.black54,
              ),

              // Set Room
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.black45,
                      size: 26,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 50, 0),
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          hint: const Text("Set your room"),
                          value: _selectedLocation,
                          items: [
                            const DropdownMenuItem(
                              child: Text(
                                "Choose your room",
                                style: TextStyle(color: Colors.black26),
                              ),
                              value: "0",
                              enabled: false,
                            ),
                            ...rooms.entries
                                .map((entry) => DropdownMenuItem(
                                      child: Text(
                                        entry.key,
                                        textAlign: TextAlign.center,
                                      ),
                                      value: entry.value,
                                    ))
                                .toList()
                          ],
                          onChanged: (value) {
                            currentUserInfo.location = value.toString();
                            setState(() {
                              _selectedLocation = value.toString();
                            });
                          },
                          validator: (value) {
                            if (value == "0") {
                              return "Please choose your room";
                            }
                            return null;
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const Divider(
                height: 20.0,
                indent: 10.0,
                endIndent: 10.0,
                color: Colors.black54,
              ),

              // Noise
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.volume_off,
                      color: Colors.black45,
                      size: 26,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 40, 0),
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          hint: const Text("Prefer a quiet surrounding?"),
                          value: _selectedNoiseLvl,
                          items: const [
                            DropdownMenuItem(
                              child: Text(
                                "Prefer a quiet surrounding?",
                                style: TextStyle(color: Colors.black26),
                              ),
                              value: "0",
                              enabled: false,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                "LVL1. I don't really care.",
                              ),
                              value: "1",
                            ),
                            DropdownMenuItem(
                              child: Text(
                                "LVL2. Just don't be too noisy.",
                              ),
                              value: "2",
                            ),
                            DropdownMenuItem(
                              child: Text(
                                "LVL3. I can't stand noise at all!",
                              ),
                              value: "3",
                            ),
                          ],
                          onChanged: (value) {
                            currentUserInfo.noiseLvl = value.toString();
                            setState(() {
                              _selectedNoiseLvl = value.toString();
                            });
                          },
                          validator: (value) {
                            if (value == "0") {
                              return "Please choose noise tolerance";
                            }
                            return null;
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(10.0, 5, 10.0, 5),
                child: Divider(
                  height: 20.0,
                  color: Colors.black54,
                ),
              ),

              // Temperature
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.device_thermostat,
                      color: Colors.black45,
                      size: 26,
                    ),
                    SizedBox(
                      width: 200,
                      child: RangeSlider(
                        values: temperatureRangeValues,
                        onChanged: (RangeValues values) {
                          setState(() {
                            temperatureRangeValues = values;
                            currentUserInfo.tempStart = values.start.round();
                            currentUserInfo.tempEnd = values.end.round();
                          });
                        },
                        min: 19,
                        max: 26,
                        divisions: 7,
                        labels: RangeLabels(
                          temperatureRangeValues.start.round().toString(),
                          temperatureRangeValues.end.round().toString(),
                        ),
                      ),
                    ),
                    Text(
                        "${currentUserInfo.tempStart} -- ${currentUserInfo.tempEnd}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0,
                            color: Colors.black45)),
                  ],
                ),
              ),

              const Divider(
                height: 20.0,
                indent: 20.0,
                endIndent: 20.0,
                color: Colors.black54,
              ),

              ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // Listener, after logging in, upload the user's information
                    // FirebaseAuth.instance
                    //     .authStateChanges()
                    //     .listen((User? user) {
                    //   if (user != null) {
                    //     // if the user is the one just registered
                    //     if (user.email == currentUserInfo.email) {
                    //       CollectionReference usersTable =
                    //           FirebaseFirestore.instance.collection("users");
                    //       usersTable
                    //           .doc(user.uid)
                    //           .set({
                    //             'userName': currentUserInfo.userName,
                    //             'location': currentUserInfo.location,
                    //             'tempStart': currentUserInfo.tempStart,
                    //             'tempEnd': currentUserInfo.tempEnd,
                    //           })
                    //           .then((value) => print("User Created"))
                    //           .catchError((error) =>
                    //               ScaffoldMessenger.of(context).showSnackBar(
                    //                 const SnackBar(
                    //                     content: Text(
                    //                         'The email is already been used')),
                    //               ));
                    //     }
                    //   }
                    // });

                    // Register.
                    // try {
                    //   await FirebaseAuth.instance
                    //       .createUserWithEmailAndPassword(
                    //           email: currentUserInfo.email,
                    //           password: currentUserInfo.password)
                    //       .then((value) =>
                    //           // Log in after registering
                    //           FirebaseAuth.instance.signInWithEmailAndPassword(
                    //               email: currentUserInfo.email,
                    //               password: currentUserInfo.password));
                    // } on FirebaseAuthException catch (e) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //         content: Text('The email is already been used')),
                    //   );
                    // }

                    CollectionReference usersTable =
                        FirebaseFirestore.instance.collection("users");
                    usersTable
                        .doc(currentUserInfo.userName.trim())
                        .set({
                          'userName': currentUserInfo.userName,
                          'location': currentUserInfo.location,
                          'noiseLvl': currentUserInfo.noiseLvl,
                          'tempStart': currentUserInfo.tempStart,
                          'tempEnd': currentUserInfo.tempEnd,
                        })
                        .then((value) => print("User Created"))
                        .catchError((error) =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('The email is already been used')),
                            ));
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// read data from Firebase
class AllInfoTab extends StatefulWidget {
  const AllInfoTab({Key? key}) : super(key: key);

  @override
  _AllInfoTabState createState() => _AllInfoTabState();
}

class _AllInfoTabState extends State<AllInfoTab> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['userName'].toString()),
                subtitle: Text(
                    "\nRoom ${data["location"]},\t\tNoise Tolerance: Lvl.${data['noiseLvl']}   \n\nPreferred Temperature: ${data['tempStart'].toString()},  ${data['tempEnd'].toString()} "),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class CurrentValueTab extends StatefulWidget {
  const CurrentValueTab({Key? key, required this.roomNumber}) : super(key: key);

  final String roomNumber;

  @override
  _CurrentValueTabState createState() => _CurrentValueTabState();
}

class _CurrentValueTabState extends State<CurrentValueTab> {
  final Stream<DocumentSnapshot> _usersStream = FirebaseFirestore.instance
      .collection('CurrentValue')
      .doc("currentTemp")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _usersStream,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: Text(
                  "Room ${widget.roomNumber}",
                  style: const TextStyle(
                      fontSize: 24.0,
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 20, 10, 0),
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text("Current\n Temperature\n Setting:",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              "${snapshot.data?.get(widget.roomNumber)}℃",
                              style: const TextStyle(
                                  fontSize: 50.0,
                                  color: Colors.black38,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                                width: 110,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Row(
                                    children: const [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Icon(Icons.arrow_drop_up),
                                      ),
                                      SizedBox(width: 3),
                                      Text("Warmer"),
                                    ],
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          Colors.orangeAccent)),
                                )),
                            const SizedBox(height: 10),
                            SizedBox(
                                width: 110,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Row(
                                    children: const [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Icon(Icons.arrow_drop_down),
                                      ),
                                      SizedBox(width: 6),
                                      Text("Cooler"),
                                    ],
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          Colors.lightBlueAccent)),
                                )),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("My thermal comfort: 20℃ - 23℃",
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold))
                  ],
                ),
              )),
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
            //   child: Card(
            //       child: Padding(
            //         padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            //         child: Row(
            //     children: const [Text("My thermal comfort: 20℃ - 23℃",
            //         style: TextStyle(
            //         fontSize: 20.0,
            //         color: Colors.black54,
            //         fontWeight: FontWeight.bold))],
            //   ),
            //       )),
            // ),
          ],
        );
      },
    );
  }
}

// class ParticipantInfo {
//   String email = "";
//   String password = "";
//   String userName = "";
//   String location = "";
//   String noiseLvl = "";
//   int tempStart = 21;
//   int tempEnd = 24;
// }
