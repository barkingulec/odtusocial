import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;

import '../utils/colors.dart';

class NotificationBox extends StatelessWidget {
  const NotificationBox({ Key? key, this.onTap, this.size = 5, this.notifiedNumber = 2}) : super(key: key);
  final GestureTapCallback? onTap;
  final int notifiedNumber;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: white.withOpacity(0),
          //border: Border.all(color: Colors.grey.withOpacity(.6)),
        ),
        child: notifiedNumber > 0 ? badges.Badge(
          badgeStyle: const badges.BadgeStyle(          
            badgeColor: pink,
            padding: EdgeInsets.all(4),
            ),
          position: BadgePosition.topEnd(top: -5, end: 3),
          badgeContent: const Text('', style: TextStyle(color: white),),
          child: SvgPicture.asset("assets/notification.svg", color: primaryColor, width: 29, height: 29,),
        )
        // child: notifiedNumber > 0 ? const Icon(Icons.notification_add)
        : SvgPicture.asset("assets/notification.svg", color: primaryColor, width: 29, height: 29,),
      ),
    );
  }
}