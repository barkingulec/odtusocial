import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:social/widgets/custom_image.dart';

import '../utils/colors.dart';
import '../utils/global_variables.dart';
import '../utils/utils.dart';

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

      setState(() {
        nameController = TextEditingController(text: eventData['name']);
        descController = TextEditingController(text: eventData['desc']);
        date = eventData['date'].toDate();
        _selectedOptions = (eventData['for_whom'] as List).map((item) => item as bool).toList();
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

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
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Update Event Name",
            errorText: _nameValid ? null : "Event name is too short",
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
          controller: descController,
          decoration: InputDecoration(
            hintText: "Update Description",
            errorText: _descValid ? null : "Description is too long",
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
        "desc": descController.text,
        "edited_on": FieldValue.arrayUnion([DateTime.now()]),
        "edited_by": FieldValue.arrayUnion([username]),
        "date": Timestamp.fromDate(date),
        'for_whom': _selectedOptions,
      });
      showSnackBar(context, "Event updated!");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: black),
        backgroundColor: whiteGray,
        title: Text(
          "Update Event",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: pink,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const CircularProgressIndicator()
          : ListView(
              children: <Widget>[
                Container(
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
                            width: 100,
                            height: 100,
                          ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildEventNameField(),
                            buildDescField(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Text("Event Date: ${date.day}/${date.month}/${date.year} $hours:$minutes", style: TextStyle(fontSize: 16)),
                      Text("Event Date: ${DateFormat('HH:mm - dd/MM/yyyy').format(eventData['date'].toDate())}", style: const TextStyle(fontSize: 16)),
                      SizedBox(
                        width: 115,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: pickDateTime, 
                          child: Text("Change Date"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pink,
                          ),
                          ),
                      ),
                      
                    ],
                  ),
                  const SizedBox(height: 20),
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
                 const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: updateEvent,
                        child: Text(
                          "Update Event",
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
              ],
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
}