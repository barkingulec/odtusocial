import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../views/event_detail_view.dart';
import 'custom_image.dart';
import 'enroll_button.dart';

class SingleNotification extends StatefulWidget {
  final String eventId;
  final String communityId;
  final bool isNew;
  const SingleNotification({Key? key, required this.eventId, required this.communityId, required this.isNew}) : super(key: key);

  @override
  State<SingleNotification> createState() => _SingleNotificationState();
}

class _SingleNotificationState extends State<SingleNotification> {
  var eventData = {};
  var communityData = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var eventSnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .doc(widget.eventId)
          .get();

      eventData = eventSnap.data()!;

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
    return isLoading ? const Center( child: Text("") ) : 
      SingleChildScrollView(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EventDetailView(
                            communityId: widget.communityId.toString(),
                            eventId: widget.eventId.toString(),
                          ),
                        ),
                      );
          },
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            decoration: BoxDecoration(
                color: widget.isNew ? lightGray : white,
                border: const Border(
                  bottom: BorderSide(width: 1.0, color: gray),
                )
              ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: <Widget>[
                    CustomImage(
                                eventData['image'],
                                radius: 18,
                                width: 75,
                                height: 75,
                              ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('HH:mm - dd/MM/yyyy, EEEE').format(eventData['date'].toDate()),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                              softWrap: false,
                              style: TextStyle(fontSize: 14, color: black.withOpacity(0.7)),
                              ),
                        const SizedBox(height: 5),
                        Text("${eventData['name']}",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            softWrap: false,
                            style: const TextStyle(fontSize: 19),
                          ),
                        const SizedBox(height: 5),
                        Text("${communityData['name']}",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            softWrap: false,
                            style: const TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                forWhom(),
              ],
            ),
          ),
        ),
      );
  }

  forWhom() {
    if (eventData['for_whom'][0] == true) {
      return const Text("Admins only", style: TextStyle(fontSize: 12, color: pink), overflow: TextOverflow.ellipsis,);
    }
    else if (eventData['for_whom'][1] == true) {
      return const Text("Members only", style: TextStyle(fontSize: 12, color: pink), overflow: TextOverflow.ellipsis,);
    }
    else {
      return const Text("For everyone", style: TextStyle(fontSize: 12, color: pink), overflow: TextOverflow.ellipsis,);
    }
  }

}