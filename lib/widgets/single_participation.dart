import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';
import '../views/event_detail_view.dart';
import 'custom_image.dart';

class SingleParticipation extends StatefulWidget {
  final participationData;
  const SingleParticipation({super.key, this.participationData});

  @override
  State<SingleParticipation> createState() => _SingleParticipationState();
}

class _SingleParticipationState extends State<SingleParticipation> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EventDetailView(
                            communityId: widget.participationData['communityId'],
                            eventId: widget.participationData['eventId'],
                          ),
                        ),
                      );
          },
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            decoration: const BoxDecoration(
                color: white,
                border: Border(
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
                                widget.participationData['eventImage'],
                                radius: 18,
                                width: 75,
                                height: 75,
                              ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('HH:mm - dd/MM/yyyy, EEEE').format(widget.participationData['date'].toDate()),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                              softWrap: false,
                              style: TextStyle(fontSize: 14, color: black.withOpacity(0.7)),
                              ),
                        const SizedBox(height: 5),
                        Text("${widget.participationData['eventName']}",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            softWrap: false,
                            style: const TextStyle(fontSize: 19),
                          ),
                        const SizedBox(height: 5),
                        Text("${widget.participationData['communityName']}",
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
                Text(widget.participationData['isOnline'] ? "Online" : "${widget.participationData['attendedWith']}", style: const TextStyle(fontSize: 12, color: pink), overflow: TextOverflow.ellipsis,),
              ],
            ),
          ),
        ),
      );
  }
}