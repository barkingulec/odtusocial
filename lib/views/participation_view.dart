import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/colors.dart';
import '../widgets/single_participation.dart';

class ParticipationView extends StatefulWidget {
  final uid;
  final userData;
  const ParticipationView({super.key, this.uid, this.userData});

  @override
  State<ParticipationView> createState() => _ParticipationViewState();
}

class _ParticipationViewState extends State<ParticipationView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List participations = widget.userData['participation'];
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
          title: const Text(
            "Participations",
            style: TextStyle(color: black),),
          ),
        body: Container(
          child: participations.isNotEmpty ? ListView.builder(
            itemCount: participations.length,
            itemBuilder: (context, index) {
              return SingleParticipation(
                participationData: participations[index],
                );
            },
          )
          : const Center(child: Text("There is no participation."),),
          ),
        );
  }
}