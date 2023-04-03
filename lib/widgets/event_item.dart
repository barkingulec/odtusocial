import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/colors.dart';
import '../views/event_detail_view.dart';
import 'custom_image.dart';

class UpcomingEventItem extends StatelessWidget {
  final data;
  const UpcomingEventItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var datediff = data.data()['date'].toDate().difference(DateTime.now());
    var minutes = datediff.inMinutes % datediff.inHours;
    bool isUpcoming = datediff.inMinutes > 0;
    return isUpcoming ? InkWell(
      onTap: () { Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventDetailView(
                                communityId: data.data()['communityId'],
                                eventId: data.data()['eventId'], 
                              ),
                            ),
                          );},
      child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(.097),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomImage(data.data()['image'], radius: 10, width:70, height: 70),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.data()['name'], style: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w500),),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.schedule_outlined, color: pink, size: 16),
                          SizedBox(width: 5),
                          Text("${datediff.inHours} hours ${minutes} minutes later.", style: TextStyle(color: gray, fontSize: 13, fontWeight: FontWeight.w500),),
                        ],
                      ),
                  ],),
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
    ) : const SizedBox(height: 0);
  }
}


class PastEventItem extends StatelessWidget {
  final data;
  const PastEventItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var datediff = data.data()['date'].toDate().difference(DateTime.now());
    bool isPast = datediff.inMinutes < 0;
    return isPast ? Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: black.withOpacity(.097),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(1, 1),
              )
            ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomImage(data.data()['image'], radius: 10, width:70, height: 70),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.data()['name'], style: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w500),),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.schedule_outlined, color: pink, size: 16),
                        SizedBox(width: 5),
                        Text("This event is past", style: TextStyle(color: pink, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                ],),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ) : const SizedBox(height: 0);
  }
}