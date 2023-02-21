
import 'package:flutter/material.dart';
import 'package:med_reminder/widgets/platform_slider.dart';


class UserSlider extends StatelessWidget {
  final Function handler;
  final int howManyDays;
  UserSlider(this.handler,this.howManyDays);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: PlatformSlider(
              divisions: 30,
              min: 1,
              max: 30,
              value: howManyDays,
              color: Colors.green,
              handler:  this.handler,)),
      ],
    );
  }
}
