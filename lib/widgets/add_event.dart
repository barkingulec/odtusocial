import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/widgets/community.dart';
import 'package:social/widgets/single_event.dart';
import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';
import '../utils/utils.dart';
import 'custom_image.dart';

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

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
    username = curUser.displayName!;
    getData();
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
      );

      if (res != 'success') {
        showSnackBar(context, res);
      }
      else {
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

      setState(() {
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    

    return isLoading ? const CircularProgressIndicator() : Scaffold(
      appBar: AppBar(
      title: const Text(
        "Add Event", 
        style: TextStyle(color: black),
      ),
      iconTheme: const IconThemeData(color: black),
      backgroundColor: whiteGray,
    ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                        top: 20.0,
                        bottom: 14.0,
                      ),
                      child: CustomImage(
                          communityData['image'],
                          radius: 20,
                          width: 100,
                          height: 100,
                        ),
                    ),
                  buildEventNameField(),
                  const SizedBox(height: 10,),
                  buildDescField(),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Event Date: ${date.day}/${date.month}/${date.year} $hours:$minutes", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 110,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: pickDateTime, 
                            child: Text("Select Date"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pink,
                            ),
                            ),
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Text("Add This Event For: "),
                    const SizedBox(height: 10,),
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
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.red[700],
                        selectedColor: Colors.white,
                        fillColor: Colors.red[200],
                        color: Colors.red[400],
                        constraints: const BoxConstraints(
                          minHeight: 40.0,
                          minWidth: 80.0,
                        ),
                        isSelected: _selectedOptions,
                        children: options,
                   ),
                   const SizedBox(height: 20,),
                   ElevatedButton(
                          onPressed: addEvent,
                          child: Text(
                            "Add Event",
                            style: TextStyle(
                              color: white,
                              fontSize: 18.0,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(pink),
                          ),
                        ),
                ],
              ),
            ),
                      
          ),
        ),
      ),
    );
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

  Column buildEventNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Event Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: nameEditingController,
          decoration: const InputDecoration(
            hintText: "Enter Event Name",
            hintStyle: TextStyle(fontSize: 15),
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
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Description",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: descEditingController,
          decoration: const InputDecoration(
            hintText: "Enter Description",
            hintStyle: TextStyle(fontSize: 15),
          ),
        )
      ],
    );
  }
}