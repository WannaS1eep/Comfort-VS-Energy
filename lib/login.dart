import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myflutter/element/rounded_button.dart';
import 'package:myflutter/element/rounded_container.dart';
import 'package:myflutter/register.dart';
import './element/participant_info.dart';
import 'main_tab_bar.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _validateMode = AutovalidateMode.disabled;

  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: _validateMode,
          child: ListView(
            shrinkWrap: true,
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
                    email = value;
                    return null;
                  },
                ),
              ),
              RoundedContainer(
                child: TextFormField(
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
                    password = value;
                    return null;
                  },
                  obscureText: true,
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
                          // Listener, after logging in,
                          FirebaseAuth.instance.authStateChanges().listen((User? user) {
                            if(user != null){
                              if(user.email == email){
                                ParticipantInfo userInfo = ParticipantInfo();
                                userInfo.getUserInfoByID(user.uid);
                                runApp(MainTabBar(userInfo: userInfo));
                              }
                            }
                          });
                          try{
                            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: (email), password: password);
                          }on FirebaseAuthException catch (e){
                            if(e.code == 'user-not-found') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('No user found for that email.')),
                              );
                            } else if (e.code == 'wrong-password') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Wrong password provided for that user.')),
                              );
                            }
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
                child: const Text("Already have an account?", textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.black54,
                ),
                ),
                onTap: (){runApp(const RegisterPage());},
              ),
            ],
          ),
        ),
      ),
    );
  }
}