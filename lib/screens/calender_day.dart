 import "package:flutter/material.dart";
import "../models/calender_day_model.dart";

class CalendarDay extends StatelessWidget {
  const CalendarDay( this.day, this.onDayClick,{Key? key}) : super(key: key);
  final CalendarDayModel day;
   final Function onDayClick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constrains) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            day.dayLetter!,
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 17.0,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: constrains.maxHeight * 0.1,
          ),
          GestureDetector(
            onTap: () => onDayClick(day),
            child: CircleAvatar(
              radius: constrains.maxHeight * 0.25,
              backgroundColor: day.isChecked!
                  ? Colors.green
                  : Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  day.dayNumber.toString(),
                  style: TextStyle(
                      color: day.isChecked! ? Colors.white : Colors.black,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );;
  }
}
