import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myflutter/element/participant_info.dart';
import 'package:rxdart/rxdart.dart';

class CurrentStatesTab extends StatefulWidget {
  const CurrentStatesTab({Key? key, required this.userInfo}) : super(key: key);

  final ParticipantInfo userInfo;

  @override
  _CurrentStatesTabState createState() => _CurrentStatesTabState();
}

class _CurrentStatesTabState extends State<CurrentStatesTab> {
  final Stream<DocumentSnapshot> _currentValueStream = FirebaseFirestore.instance
      .collection('CurrentValue')
      .doc("currentTemp")
      .snapshots();
  final Stream<DocumentSnapshot> _userValueStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .snapshots();

  Map<String, String> rooms = {"Room1": "1", "Room2": "2", "Room3": "3"};
  late String _selectedLocation = widget.userInfo.location;
  double _scaleValue = 3;
  List<String> pmvScale = ["COLD","COOL","SLIGHTLY COOL", "NEUTRAL", "SLIGHTLY WARM", "WARM", "HOT"];
  List<Color> pmvScaleColors= [const Color(0xFF0555F7), const Color(0xFF3DBEFA), const Color(0xFF4EEFB5),const Color(0xFF43EE4C), const Color(0xFFE1EB72), const Color(0xFFF5994E),const Color(0xFFEB0000)];
  LinearGradient pmvScaleGradient = const LinearGradient(colors: [Color(0x800555F7), Color(0x803DBEFA), Color(0x804EEFB5),Color(0x8043EE4C), Color(0x80E1EB72), Color(0x80F5994E),Color(0x80EB0000)]);

  int minSettingValue = 19;
  int maxSettingValue = 30;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CombineLatestStream.list([_currentValueStream,_userValueStream]),
      builder:
          (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Something went wrong');
        }
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Text("Loading");
        // }

        return Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 200,
                child: Card(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
                      // FirebaseAuth.instance
                      //     .authStateChanges()
                      //     .listen((User? user) {
                      //   if (user != null) {
                      //     // if the user is the one just registered
                      //
                      //     CollectionReference usersTable =
                      //         FirebaseFirestore.instance.collection("users");
                      //     usersTable.doc(user.uid).update({
                      //       'location': _selectedLocation,
                      //     });
                      //   }
                      // });
                      widget.userInfo.location = value.toString();
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
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 20, 10, 0),
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: [
                    const Text("Current Temperature Setting:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold)),
                    Text(
                      "${snapshot.data![0].get(_selectedLocation)}℃",
                      style: const TextStyle(
                          fontSize: 50.0,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 50,),

                    const Text(
                      "How do you feel now?",
                      style: TextStyle(
                        color: Colors.black54,
                    ),),

                    SliderTheme(
                      data:SliderTheme.of(context).copyWith(
                        trackHeight: 20,
                        thumbColor: pmvScaleColors[_scaleValue.round()],
                        valueIndicatorColor: pmvScaleColors[_scaleValue.round()],
                        trackShape: GradientRectSliderTrackShape(gradient: pmvScaleGradient, darkenInactive: false),
                      ),
                      child: Slider(
                          min: 0.0,
                          max: 6.0,
                          divisions:6,
                          value: _scaleValue,
                          label: pmvScale[_scaleValue.round()],
                          onChanged: (snapshot.data![1].get("voted") && snapshot.data![1].get("location") == widget.userInfo.location)? null : (value) {
                            double valueAfter = snapshot.data![0].get(_selectedLocation) + value -3;
                            if(valueAfter>minSettingValue && valueAfter<maxSettingValue){
                              setState(() {
                                _scaleValue = value;
                              });
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('The email is already been used')),
                              );
                            }

                          },
                      ),
                    ),
                    ElevatedButton(onPressed: (snapshot.data![1].get("voted") && snapshot.data![1].get("location") == widget.userInfo.location)? null : (){
                      setState(() {

                        // Cause the question is "How do you feel", so the voteValue should be current setting minus scaleValue.
                        // For instance, if the user vote "hot(+3)", his preference should be current setting -(+3).
                        double voteValue = snapshot.data![0].get(_selectedLocation) - _scaleValue;
                        if(widget.userInfo.votes.length <= widget.userInfo.voteIndex){
                          widget.userInfo.votes.add(voteValue);
                        }else{
                          widget.userInfo.votes[widget.userInfo.voteIndex] = voteValue;
                        }
                        widget.userInfo.voteIndex = (widget.userInfo.voteIndex + 1) % 3;

                        CollectionReference usersTable =
                        FirebaseFirestore.instance.collection("users");
                        usersTable
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .update({
                          'location': _selectedLocation,
                          'voteIndex': widget.userInfo.voteIndex,
                          'votes': widget.userInfo.votes,
                          'voted': true,
                        });

                      });


                      }, child: const Text("Submit")),

                    const SizedBox(height: 10),
                    // const Text("My thermal comfort: 20℃ - 23℃",
                    //     style: TextStyle(
                    //         fontSize: 18.0,
                    //         color: Colors.black54,
                    //         fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
            ),
          ],
        );
      },
    );
  }
}

class GradientRectSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  final LinearGradient gradient;
  final bool darkenInactive;
  const GradientRectSliderTrackShape({ this.gradient = const LinearGradient(colors: [Colors.lightBlue, Colors.blue]), this.darkenInactive = true});

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = false,
        double additionalActiveTrackHeight = 2,
      }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.


    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = darkenInactive
        ? ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor)
        : activeTrackColorTween;
    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }
    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(trackRect.height / 2 + 1);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr) ? trackRect.top - (additionalActiveTrackHeight / 2): trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr) ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr) ? activeTrackRadius : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr) ? activeTrackRadius: trackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl) ? trackRect.top - (additionalActiveTrackHeight / 2) : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl) ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
        bottomRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      ),
      rightTrackPaint,
    );
  }
}