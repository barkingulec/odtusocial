import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/colors.dart';

class SettingItem extends StatelessWidget {
  final String? leadingIcon;
  final Color leadingIconColor;
  final Color bgIconColor;
  final Color boxBackgroundColor;
  final Color trailingIconColor;
  final String title;
  final GestureTapCallback? onTap;
  const SettingItem({ Key? key, required this.title, this.onTap, this.leadingIcon, this.leadingIconColor = Colors.white, this.bgIconColor =  white, this.boxBackgroundColor = Colors.transparent, this.trailingIconColor = pink,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
                color: boxBackgroundColor,
              ),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: leadingIcon != null ?
          [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgIconColor,
                shape: BoxShape.circle
              ),
              child: SvgPicture.asset(leadingIcon!, color: leadingIconColor, width: 25, height: 25,),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: trailingIconColor,
              size: 17,
            )
          ]
          :
          [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: black,
              size: 17,
            )
          ],
        ),
      ),
    );
  }
}