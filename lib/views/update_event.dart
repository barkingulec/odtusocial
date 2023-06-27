import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:social/services/auth/firestore_methods.dart';
import 'package:social/widgets/custom_image.dart';

import '../services/auth/storage_methods.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';
import '../utils/utils.dart';
import '../widgets/enroll_button.dart';
import '../widgets/location_select.dart';

class UpdateEvent extends StatefulWidget {
  final String eventId;
  final String communityId;
  const UpdateEvent({super.key, required this.eventId, required this.communityId});

  @override
  State<UpdateEvent> createState() => _UpdateEventState();
}

class _UpdateEventState extends State<UpdateEvent> {
  var communityData = {};
  var eventData = {};
  var eventRef;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isLoading = false;
  bool _nameValid = true;
  bool _descValid = true;
  String? username = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  DateTime date = DateTime.now();
  List<bool> _selectedOptions = <bool>[false, true, false];
  List<bool> prevSelectedOptions = <bool>[false, true, false];
  bool isUploaded= false;
  String photoURL = "";
  var futurePhotoURL;
  final StorageMethods storage = StorageMethods();
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
  var location;
  String eventLink = "";
  String attendanceType = "No attendance";
  var address;
  String stAddress = "";

  @override
  void initState() {
    super.initState();
    getData();
    final User? curUser = auth.currentUser;
    username = curUser!.displayName;
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

      var eventSnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .doc(widget.eventId)
          .get();

      eventData = eventSnap.data()!;

      eventRef = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .doc(widget.eventId);

      var duration = eventData['endDate'].toDate().difference(eventData['date'].toDate());

      setState(() {
        nameController = TextEditingController(text: eventData['name']);
        descController = TextEditingController(text: eventData['desc']);
        hoursController = TextEditingController(text: duration.inHours.toString());
        minutesController = TextEditingController(text: (duration.inMinutes % 60).toString());
        date = eventData['date'].toDate();
        _selectedOptions = (eventData['for_whom'] as List).map((item) => item as bool).toList();
        prevSelectedOptions = _selectedOptions;
        isOnline = eventData['isOnline'];
        location = eventData['location'];
        eventLink = eventData['eventLink'];
        attendanceType = eventData['attendanceType'];
        selectedValue = attendanceType;
      });

      location = eventData['location'];
      address = await placemarkFromCoordinates(location.latitude, location.longitude);
      var temp = address.first;
      setState(() {
          stAddress = "${temp.name}, ${temp.street}, ${temp.subAdministrativeArea}, ${temp.administrativeArea}";
      });

    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
      photoURL = communityData['image'];
    });
  }

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
            controller: nameController,
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
            controller: descController,
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

  updateEvent() {
    setState(() {
      nameController.text.trim().length < 3 ||
              nameController.text.isEmpty
          ? _nameValid = false
          : _nameValid = true;
      descController.text.trim().length > 100
          ? _descValid = false
          : _descValid = true;
    });

    if (_nameValid && _descValid) {
      eventRef.update({
        "name": nameController.text,
        "username": nameController.text,
        "desc": descController.text,
        "edit_history": FieldValue.arrayUnion([{username: DateTime.now()}]),
        "date": Timestamp.fromDate(date),
        'for_whom': _selectedOptions,
        "image": photoURL,
        "photoUrl": photoURL,
        "endDate": Timestamp.fromDate(date.add(Duration(hours: int.parse(hoursController.text), minutes: int.parse(minutesController.text)))),
        "isOnline": isOnline,
        //"location": location,
        "eventLink": eventLinkController.text,
        "attendanceType": selectedValue,
      });
      FireStoreMethods().updateNotificationOnEventUpdate(widget.communityId, widget.eventId, _selectedOptions, prevSelectedOptions);
      showSnackBar(context, "Event updated!");
      Navigator.pop(context);
    }
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
                          isUploaded = true;
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
        title: Text(
          "Update Event",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? const CircularProgressIndicator()
          : ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                        ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20.0,
                          bottom: 10.0,
                        ),
                        child: CustomImage(
                            eventData['image'],
                            radius: 20,
                            width: 360,
                            height: 200,
                          ),
                      ),
                      // ElevatedButton(
                      //   onPressed: uploadImage,
                      //   style: ElevatedButton.styleFrom(
                      //       backgroundColor: pink,
                      //     ),
                      //   child: const Text("Upload Image"),
                      //   ),
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
                      const SizedBox(height: 4),
                      Column(
                        children: <Widget>[
                          buildEventNameField(),
                          const SizedBox(height: 6),
                          buildDescField(),
                          const SizedBox(height: 6),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Date"),
                        ],
                      ),
                      const SizedBox(height: 6,),
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
                        ),       
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
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

                 const SizedBox(height: 30),


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

                  !isOnline ? Text(stAddress) : const SizedBox(),

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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const Text("Location"),
                      // const SizedBox(width: 5,),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LocationPicker(
                                  position: location,
                                  communityId: widget.communityId,
                                  eventId: widget.eventId,
                              ),
                            ),
                          ).then((value) { 
                            setState(() 
                            {
                              location = GeoPoint(value.latitude, value.longitude);
                            }
                            );
                          });
                          //showSnackBar(context, "Location Selected.");
                          setState(() {
                            //location = GeoPoint(temp.latitude, temp.longtitude);
                          });
                        },
                        child: Text(location.latitude == eventData['location'].latitude ? "Select Location" : "Change Location"),
                        ),
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


                      EnrollButton(
                          text: 'Update Event',
                          backgroundColor: Colors.white,
                          textColor: pink,
                          borderColor: pink,
                          function: updateEvent,
                          height: 50,
                          width: 200,
                          radius: 30,
                          fontSize: 16,
                    ),
                    const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
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
                          firstDate: DateTime(2020), 
                          lastDate: DateTime(2030),
                          );

  Future<TimeOfDay?> pickTime() => showTimePicker(
    context: context, 
    initialTime: TimeOfDay(hour: date.hour, minute: date.minute));
}