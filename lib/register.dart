import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myflutter/element/rounded_button.dart';
import 'package:myflutter/element/rounded_container.dart';
import 'package:myflutter/login.dart';
import './element/participant_info.dart';
import 'main_tab_bar.dart';

ParticipantInfo currentUserInfo = ParticipantInfo();
RangeValues temperatureRangeValues = const RangeValues(21, 24);

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _validateMode = AutovalidateMode.disabled;

  // map of rooms, facilitate expansion
  Map<String, String> rooms = {"Room1": "1", "Room2": "2", "Room3": "3"};
  String _selectedLocation = "0";
  String _selectedNoiseLvl = "0";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Register",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: _validateMode,
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20,),
              RoundedContainer(
                child: TextFormField(
                  decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "You will use your email to login",
                      prefixIcon: Icon(Icons.email),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !EmailValidator.validate(value, true)) {
                      return 'A valid email is required';
                    }
                    currentUserInfo.email = value;
                    return null;
                  },
                ),
              ),
              RoundedContainer(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Password",
                        hintText: "Enter Your Password",
                        prefixIcon: Icon(Icons.password),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A valid email with length >= 6 is required';
                        }
                        currentUserInfo.password = value;
                        return null;
                      },
                      obscureText: true,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Confirm your Password",
                        hintText: "Enter Your Password Again",
                        prefixIcon: Icon(null),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value != currentUserInfo.password) {
                          return "The passwords doesn't match";
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                  ],
                ),
              ),

              RoundedContainer(
                child: TextFormField(
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
              ),

              // Set Room
              RoundedContainer(
                paddingVertical: 5,
                child: Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Icon(
                      Icons.location_on,
                      color: Colors.black45,
                      size: 26,
                    ),
                    const SizedBox(width: 15,),
                    Expanded(
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
                    )
                  ],
                ),
              ),

              // Noise
              RoundedContainer(
                paddingVertical: 5,
                child: Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Icon(
                      Icons.volume_off,
                      color: Colors.black45,
                      size: 26,
                    ),
                    const SizedBox(width: 15,),
                    Expanded(
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
                    )
                  ],
                ),
              ),


              // Temperature
              RoundedContainer(
                paddingVertical: 5,
                child: Row(
                  children: [
                    const SizedBox(width: 10,),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 200,
                    child: RoundedButton(
                      text: 'Submit',
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // Listener, after logging in, upload the user's information
                          FirebaseAuth.instance
                              .authStateChanges()
                              .listen((User? user) {
                            if (user != null) {
                              // if the user is the one just registered
                              if (user.email == currentUserInfo.email) {
                                CollectionReference usersTable =
                                    FirebaseFirestore.instance.collection("users");
                                usersTable
                                    .doc(user.uid)
                                    .set({
                                      'userName': currentUserInfo.userName,
                                      'location': currentUserInfo.location,
                                      'noiseLvl': currentUserInfo.noiseLvl,
                                      'tempStart': currentUserInfo.tempStart,
                                      'tempEnd': currentUserInfo.tempEnd,
                                      'pmv': -1,
                                      'ael': 0,
                                    })
                                    .then((value) => runApp(MainTabBar(userInfo: currentUserInfo,)));

                              }
                            }
                          });

                          // Register.
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: currentUserInfo.email,
                                    password: currentUserInfo.password)
                                .then((value) =>
                                    // Log in after registering
                                    FirebaseAuth.instance.signInWithEmailAndPassword(
                                        email: currentUserInfo.email,
                                        password: currentUserInfo.password));
                          } on FirebaseAuthException {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('The email is already been used')),
                            );
                          }
                        }else{
                          // check the input when the user interacts
                          setState(() {
                            _validateMode = AutovalidateMode.onUserInteraction;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              GestureDetector(
                child: const Text("Want to Login?", textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.black54,
                  ),
                ),
                onTap: (){runApp(const LoginPage());},
              )
            ],
          ),
        ),
      ),
    );
  }
}