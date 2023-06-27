import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social/widgets/community.dart';
import 'package:social/widgets/single_event.dart';
import '../services/auth/firestore_methods.dart';
import '../services/auth/storage_methods.dart';
import '../services/notification_service.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';
import '../utils/utils.dart';
import '../views/feed_view.dart';
import 'custom_image.dart';
import 'enroll_button.dart';
import 'package:http/http.dart' as http;

import 'location_select.dart';

class AddEventView extends StatefulWidget {
  final communityId;
  const AddEventView({Key? key, required this.communityId}) : super(key: key);

  @override
  _AddEventViewState createState() => _AddEventViewState();
}

class _AddEventViewState extends State<AddEventView> {
  var communityData = {};
  final TextEditingController descEditingController =
      TextEditingController();
  final TextEditingController nameEditingController =
      TextEditingController();
  DateTime date = DateTime.now();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userUid = ""; 
  String username = "";
  bool isLoading = false;
  final List<bool> _selectedOptions = <bool>[false, true, false];
  String photoURL = "";
  var futurePhotoURL;
  final StorageMethods storage = StorageMethods();
  String? mtoken = " ";
  int durationHours = 2;
  int durationMinutes = 0;
  TextEditingController hoursController =
      TextEditingController(text: "2");
  TextEditingController minutesController =
      TextEditingController(text: "0");
  bool isOnline = false;
  final TextEditingController eventLinkController =
      TextEditingController();
  String selectedValue = "No attendance";
  String info = "";
  bool showInfo = false;
  GeoPoint location = const GeoPoint(39.89171561144314, 32.78581707629186);

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
    username = curUser.displayName!;
    getData();
    requestPermission();
    getToken();
    initInfo();
    // notificationHelper
    //     .setListenerForLowerVersions(onNotificationInLowerVersions);
    // notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
    );
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("permission");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("provisional");
    } else {
        print("denied");
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
      (token) {
        setState(() {
          mtoken = token;
          print("my token is $mtoken");
        });
        saveToken(token!);
      }
    );
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("profiles").doc(userUid).update({
      "token": token,
    });
  }

  void sentPushMessage(String? token, String body, String title) async {
    try {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAVgKpwfY:APA91bFpMGO6KoYSAXqOKIRBy7Vv4yAXZXPQJ_tTiFG3TXlotuPm-1wbMDlM5mmwIw9mvn6ltdzcnlFEKBRxXSWzbU7R8KAbMRgKWGrZ2rwl4WzeOxE9RtGRyEUOgOzRZ-IUijnYmNPO',
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',

          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': title,
          },

          'notification': <String, dynamic>{
            'title': title,
            'body': body,
            'android_channel_id': 'dbfood',
          },

          'to': token,
        }),
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

await flutterLocalNotificationsPlugin
  .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  // If `onMessage` is triggered with a notification, construct our own
  // local notification to show to users using the created channel.
  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: android.smallIcon,
            // other properties...
          ),
        ));
  }
});

    } catch (e) {
      showSnackBar(context, e.toString());
      print(e.toString());
    }
  }

  void initInfo() {

  }
  
  void addEvent() async {
    try {
      String res = await FireStoreMethods().addEvent(
        widget.communityId,
        descEditingController.text,
        nameEditingController.text,
        userUid,
        username,
        Timestamp.fromDate(date),
        _selectedOptions,
        photoURL,
        Timestamp.fromDate(date.add(Duration(hours: int.parse(hoursController.text), minutes: int.parse(minutesController.text),))),
        isOnline,
        location,
        eventLinkController.text,
        selectedValue,
      );
        // SEND NOTIFICATION **************************
        // await notificationHelper.showNotification();

      if (res != 'success') {
        showSnackBar(context, res);
      }
      else {
        sentPushMessage(mtoken, descEditingController.text, nameEditingController.text);
        showSnackBar(context, "Event is successfully added.");

        Navigator.pop(context);
      }
      setState(() {
        descEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var communitySnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .get();

      communityData = communitySnap.data()!;
      location = communityData['location'];

      setState(() {
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
      photoURL = communityData['image'];
    });
  }

uploadImage() async {
                          final results = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.image,
                          );
                          if (results == null) {
                            showSnackBar(context, "No file selected");
                            return null;
                          }
                          final path = results.files.single.path!;
                          final fileName = results.files.single.name;
                          
                          futurePhotoURL = storage.uploadFile(path, fileName);
                          futurePhotoURL.then((String result){
                            setState(() {
                                  photoURL = result;
                                });
                            });
                            // .then((value) => 
                            // print('Done.'));
                          //var url = storage.downloadURL(fileName);
                          setState(() {
                            //photoURL = url;
                          });
                        }

  @override
  Widget build(BuildContext context) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    

    return isLoading ? const Center(child: CircularProgressIndicator()) : Scaffold(
      appBar: AppBar(
      title: const Text(
        "Add Event", 
        style: TextStyle(color: black),
      ),
              iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
    ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(
                      top: 6.0,
                      bottom: 6.0,
                    ),
                    child: CustomImage(
                        photoURL,
                        radius: 20,
                        width: 360,
                        height: 200,
                      ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: uploadImage,
                        child: Row(
                          children: [
                            Icon(Icons.file_upload_outlined, color: pink.withOpacity(.8)),
                            const SizedBox(width: 5),
                            Text("Upload"),
                          ],
                        ),
                      ),
                      photoURL == communityData['image'] ? const SizedBox() : const SizedBox(width: 20),
                      photoURL == communityData['image'] ? const SizedBox() : GestureDetector(
                        onTap:() {
                          setState(() {
                            photoURL = communityData['image'];
                          });
                        },
                        child: Row(
                          children: [   
                              SvgPicture.asset("assets/delete.svg", color: pink.withOpacity(.8), width: 20, height: 20,),
                              const SizedBox(width: 5),
                              Text("Remove"),
                        ],
                        ),
                      ),
                    ],
                  ),
                  // EnrollButton(
                  //       text: 'Upload Image',
                  //       backgroundColor: Colors.white,
                  //       textColor: pink,
                  //       borderColor: pink,
                  //       function: uploadImage,
                  //       height: 30,
                  //       width: 120,
                  // ),
                const SizedBox(height: 10,),
                buildEventNameField(),
                const SizedBox(height: 10,),
                buildDescField(),
                  const SizedBox(height: 20,),
                  Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //SvgPicture.asset("assets/schedule.svg", color: pink.withOpacity(.8), width: 20, height: 20,),
                          //const SizedBox(width: 5,),
                          Text("Date"),
                        ],
                      ),
                      const SizedBox(height: 4,),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                          color: white,
                          border: Border.all(color: gray.withOpacity(.9), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          
                          children: [
                            const SizedBox(width: 5),
                            SvgPicture.asset("assets/schedule.svg", color: pink.withOpacity(.8), width: 21, height: 21,),
                            const SizedBox(width: 5),
                            Text("${date.day}/${date.month}/${date.year}", style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 10),
                            Icon(Icons.schedule_outlined, color: pink.withOpacity(.8), size: 21),
                            const SizedBox(width: 5),
                            Text("$hours:$minutes", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: pickDateTime,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset("assets/edit_profile.svg", color: pink.withOpacity(.8), width: 25, height: 25,),
                              const SizedBox(width: 5),
                              Text("Change"),
                              const SizedBox(width: 8),
                            ],
                          ),
                          // child: Container(
                          //   padding: const EdgeInsets.all(3),
                          //   width: 34,
                          //   height: 34,
                          //   decoration: BoxDecoration(
                          //     border: Border.all(width: 1, color: pink),
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: SvgPicture.asset("assets/edit_profile.svg", color: pink.withOpacity(.8), width: 20, height: 20,)
                          //   ),
                        ),
                        // EnrollButton(
                        //       text: 'Change Date',
                        //       backgroundColor: Colors.white,
                        //       textColor: pink,
                        //       borderColor: pink,
                        //       function: pickDateTime,
                        //       height: 30,
                        //       width: 120,
                        // ),
                        
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Icon(Icons.schedule_outlined, color: pink.withOpacity(.8), size: 20),
                          //const SizedBox(width: 5,),
                          Text("Duration"),
                        ],
                      ),
                      const SizedBox(height: 4,),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: white,
                          border: Border.all(color: gray.withOpacity(.9), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                        onPressed: () {
                                          setState(() {
                                            durationHours -= 1;
                                            hoursController = TextEditingController(text: durationHours.toString());
                                          });
                                        },
                                        icon: Icon(Icons.arrow_drop_down_outlined, color: pink.withOpacity(.8))),
                              Flexible(
                                child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: hoursController,
                                    autocorrect: false,
                                    textAlign: TextAlign.center,
                                  ),
                              ),
                              IconButton(
                                        onPressed: () {
                                          setState(() {
                                            durationHours += 1;
                                            hoursController = TextEditingController(text: durationHours.toString());
                                          });
                                        },
                                        icon: Icon(Icons.arrow_drop_up_outlined, color: pink.withOpacity(.8))),
                              Text(" hours"),
                              IconButton(
                                        onPressed: () {
                                          setState(() {
                                            durationMinutes -= 1;
                                            minutesController = TextEditingController(text: durationMinutes.toString());
                                          });
                                        },
                                        icon: Icon(Icons.arrow_drop_down_outlined, color: pink.withOpacity(.8))),
                              Flexible(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                    controller: minutesController,
                                    autocorrect: false,
                                    textAlign: TextAlign.center,
                                  ),
                              ),
                              IconButton(
                                        onPressed: () {
                                          setState(() {
                                            durationMinutes += 1;
                                            minutesController = TextEditingController(text: durationMinutes.toString());
                                          });
                                        },
                                        icon: Icon(Icons.arrow_drop_up_outlined, color: pink.withOpacity(.8))),
                              Text("minutes."),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,                  
                    children: [
                      Text("Add this event for"),
                    ],
                  ),

                  const SizedBox(height: 10,),

                  Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                          color: white,
                          border: Border.all(color: gray.withOpacity(.9), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                          ToggleButtons(
                            direction: Axis.horizontal,
                            onPressed: (int index) {
                              setState(() {
                                // The button that is tapped is set to true, and the others to false.
                                for (int i = 0; i < _selectedOptions.length; i++) {
                                  _selectedOptions[i] = i == index;
                                }
                              });
                            },
                            borderRadius: const BorderRadius.all(Radius.circular(18)),
                            selectedBorderColor: pink.withOpacity(1),
                            selectedColor: Colors.white,
                            fillColor: pink.withOpacity(.6),
                            color: pink.withOpacity(.85),
                            constraints: const BoxConstraints(
                              minHeight: 35.0,
                              minWidth: 70.0,
                            ),
                            isSelected: _selectedOptions,
                            children: options,
                                   ),
                      ],
                    ),
                  ),

                 const SizedBox(height: 20,),

                 Row(
                    children: [
                      Text("F2F"),
                      const SizedBox(width: 5,),
                      Switch(
                        activeColor: white,
                        activeTrackColor: gray,
                        inactiveTrackColor: gray,
                        value: isOnline,
                        onChanged: (value) {
                          setState(() {
                            isOnline = value;
                          });
                        },
                      ),
                      const SizedBox(width: 5,),
                      Text("Online"),
                    ],
                  ),

                  const SizedBox(height: 10,),

                  isOnline ? Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: eventLinkController,
                          decoration: const InputDecoration(
                            hintText: "Enter Event Link",
                            hintStyle: TextStyle(fontSize: 15),
                            border: OutlineInputBorder()
                          ),
                        ),
                      ),
                    ],
                  ) 
                  : Row(
                    children: [
                      const Text("Please update this event after creating to change location."),
                      const SizedBox(width: 5,),
                      // TextButton(
                      //   onPressed: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (context) => LocationPicker(
                      //             position: location,
                      //         ),
                      //       ),
                      //     ).then((_) => setState(() {}));
                      //   },
                      //   child: const Text("Select Location"),
                      //   ),
                    ],
                  ),

                  const SizedBox(height: 20,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Attendance"),
                    ],
                  ),
                  const SizedBox(height: 6,),
                  Container(
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                          color: white,
                          border: Border.all(color: gray.withOpacity(.9), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Attendance type: "),
                            const SizedBox(width: 5,),
                            DropdownButton(
                              value: selectedValue,
                              items: dropdownItems, 
                              onChanged: (String? newValue) {
                                String temp = "";
                                if (newValue == "No attendance") {
                                  temp = "";
                                }
                                if (newValue == "Location based") {
                                  temp = "Give attendance button will be available in event detail page during event duration. Members' attendance will be taken when they press this button if they are very close to the event location. Admins can observe who is attended from event detail page -> attendance.";
                                }
                                if (newValue == "Code based") {
                                  temp = "Give attendance button will be available in event detail page during event duration. A random 4 digit code will be generated after creation of this event. Only admins will be able to see this code in event detail -> attendance page. Members will enter this code when admins share with them. Admins can observe who is attended from event detail page -> attendance.";
                                }
                                if (newValue == "Location and code based") {
                                  temp = "Give attendance button will be available in event detail page during event duration. It will be enough to use one of these methods to give attendance. Admins can observe who is attended from event detail page -> attendance.";
                                }
                                setState(() {
                                  selectedValue = newValue!;
                                  info = temp;
                                });
                              },
                              ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        selectedValue != "No attendance" ? GestureDetector(
                          onTap: () {
                            setState(() {
                              showInfo = !showInfo;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: pink.withOpacity(.8), size: 17),
                              const SizedBox(width: 5,),
                              showInfo ? const Text("Hide Explanation", style: TextStyle(fontSize: 13)) : const Text("Show Explanation", style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ) : const SizedBox(),
                        showInfo ? const SizedBox(height: 5,) : const SizedBox(),                        
                        showInfo ? Text(info) : const SizedBox(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20,),

                EnrollButton(
                            text: 'Add Event',
                            backgroundColor: Colors.white,
                            textColor: pink,
                            borderColor: pink,
                            function: addEvent,
                            height: 50,
                            width: 200,
                            radius: 30,
                            fontSize: 16,
                        ),

                const SizedBox(height: 20),
              ],
            ),
          ),
                    
        ),
      ),
    );
  }

List<DropdownMenuItem<String>> get dropdownItems{
  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("No attendance"),value: "No attendance"),
    DropdownMenuItem(child: Text("Location based"),value: "Location based"),
    DropdownMenuItem(child: Text("Code based"),value: "Code based"),
    DropdownMenuItem(child: Text("Location and code based"),value: "Location and code based"),
  ];
  List<DropdownMenuItem<String>> onlineMenuItems = [
    DropdownMenuItem(child: Text("No attendance"),value: "No attendance"),
    DropdownMenuItem(child: Text("Code based"),value: "Code based"),
  ];
  return isOnline ? onlineMenuItems : menuItems;
}

    Future pickDateTime() async {
      DateTime? dateTime = await pickDate();
      if (dateTime == null) return;
      TimeOfDay? time = await pickTime();
      if (time == null) return;

      final date = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        time.hour,
        time.minute,
      );
      setState(() {
        this.date = date;
      });
    }

   Future<DateTime?> pickDate() => showDatePicker(
                          context: context, 
                          initialDate: date, 
                          firstDate: date, 
                          lastDate: DateTime(2026),
                          );

  Future<TimeOfDay?> pickTime() => showTimePicker(
    context: context, 
    initialTime: TimeOfDay(hour: date.hour, minute: date.minute));

  Column buildEventNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0, bottom: 6),
            child: Text(
              "Title",
              //style: TextStyle(color: Colors.grey),
            )),
        Container(
          decoration: BoxDecoration(
                          color: white,
                          border: Border.all(color: gray.withOpacity(.9), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
          child: TextField(
            controller: nameEditingController,
            decoration: InputDecoration(
              // filled: true,
              // fillColor: white,
              hintText: "  Event Title",
              hintStyle: TextStyle(fontSize: 15),
              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                                borderSide: BorderSide.none,
                              ),
            ),
          ),
        )
      ],
    );
  }

  Column buildDescField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 12.0, bottom: 6),
          child: Text(
            "Description",
            //style: TextStyle(color: Colors.grey),
          ),
        ),
        Container(
          decoration: BoxDecoration(
                          color: white,
                          border: Border.all(color: gray.withOpacity(.9), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
          child: TextField(
            controller: descEditingController,
            maxLines: 4,
            decoration: InputDecoration(
              // filled: true,
              // fillColor: white,
              hintText: "  Event Description",
              hintStyle: TextStyle(fontSize: 15),
              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                                borderSide: BorderSide.none,
                              ),
            ),
          ),
        )
      ],
    );
  }
}