import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/screens/success_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../notifications/notifications.dart';
import '../provider/auth_provider.dart';

class MedicineDetails extends StatefulWidget {
  const MedicineDetails({Key? key, required this.medicineName, required this.medicineType, required this.dosage, required this.interval, required this.startTime, required this.date}) : super(key: key);
  final String? medicineName;
  final String? medicineType;
  final int? dosage;
  final int? interval;
  final String? startTime;
  final String? date;
  @override
  State<MedicineDetails> createState() => _MedicineDetailsState();
}

class _MedicineDetailsState extends State<MedicineDetails> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Notifications _notifications = Notifications();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initNotifies();
  }
  Future initNotifies() async => flutterLocalNotificationsPlugin =
  await _notifications.initNotifies(context);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xf1f4f8),
        elevation: 0,
        iconTheme: IconThemeData(color:Colors.black),
        title:Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Med",style:TextStyle(color:Colors.black,fontSize:4.h,fontWeight: FontWeight.bold)),
            Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:4.h,fontWeight: FontWeight.bold))
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(2.3.h),
        child: Column(children: [
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                bottom: 1.h,
              ),
              child: Text('Reminder Detail',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color:Colors.green))),
          SizedBox(height: 2.h,),
          MainSection(medicineName: widget.medicineName!, dosage: widget.dosage!.toString(), medicineType: widget.medicineType!,),
          ExtendedInfoSection(interval: widget.interval!, medicineType:  widget.medicineType!, startTime: widget.startTime!, date: widget.date!,),
          Spacer(),
          SizedBox(
            width:100.w,
            height:7.h,
            child:TextButton(
              style:TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape:const StadiumBorder()
              ),
              onPressed: (){
              //   open alert box
                openAlertBox(context);

              },
              child:Text("Delete", style: Theme.of(context).textTheme.titleMedium!.copyWith(color:Colors.white))
            )
          ),
          SizedBox(height:2.h),
        ]),
      ),
    );
  }

//  open alert box
  openAlertBox(BuildContext context){
     return showDialog(
         context: context,
         builder: (context){
           return AlertDialog(
             shape:const RoundedRectangleBorder(
               borderRadius: BorderRadius.all(
                 Radius.circular(20.0)
               )
             ),
             contentPadding: EdgeInsets.only(top:1.h),
             title:Text('Delete This Reminder?',textAlign:TextAlign.center,style:Theme.of(context).textTheme.titleMedium),
             actions:[
               TextButton(onPressed: (){
                 Navigator.of(context).pop();
               }, child: Text("Cancel",style:Theme.of(context).textTheme.bodySmall!.copyWith(color:Colors.grey)),),
               TextButton(onPressed: (){
               //  delete medicine from firebase
                 deleteMedicineReminder(widget.medicineName!);
               }, child: Text("Yes",style:Theme.of(context).textTheme.bodySmall!.copyWith(color:Colors.red)),
               )
             ]
           );
         });
  }

  void deleteMedicineReminder(String medicineName)async{
    final ap = Provider.of<AuthProvider>(context, listen: false);
    List<int>notifyIds=await ap.deleteMedicineReminderFromFirebase(medicineName);
    for(int i in notifyIds){
       await _notifications.removeNotify(i, flutterLocalNotificationsPlugin);
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SuccessScreen()));
  }

}

class MainSection extends StatelessWidget {
  const MainSection({Key? key, required this.medicineName, required this.dosage, required this.medicineType}) : super(key: key);
  final String medicineName;
  final String dosage;
  final String medicineType;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Image.asset("assets/${medicineType}.png", height: 7.h),
      SizedBox(width: 2.w),
      Column(children:  [
        MainInfoTab(fieldTitle: 'Medicine Name', fieldInfo: medicineName),
        MainInfoTab(fieldTitle: 'Dosage', fieldInfo: '${dosage} MG'),
      ])
    ]);
  }
}

class MainInfoTab extends StatelessWidget {
  const MainInfoTab(
      {Key? key, required this.fieldTitle, required this.fieldInfo})
      : super(key: key);
  final String? fieldTitle;
  final String? fieldInfo;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 10.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fieldTitle!,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.grey)),
            SizedBox(height: 0.3.h),
            Text(fieldInfo!, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class ExtendedInfoSection extends StatelessWidget {
  const ExtendedInfoSection({Key? key, required this.interval, required this.medicineType, required this.startTime, required this.date}) : super(key: key);
  final int interval;
  final String medicineType;
  final String startTime;
  final String date;
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ExtendedInfoTab(fieldTitle: "Medicine Type", fieldInfo: medicineType),
        ExtendedInfoTab(fieldTitle: "Dosage Interval", fieldInfo: "Every ${interval.toString()} hours | ${(24/interval).toInt().toString()} times a day"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendedInfoTab(fieldTitle: "Start Time", fieldInfo: startTime),
            ExtendedInfoTab(fieldTitle: "Date", fieldInfo: date)
          ],
        ),

      ]
    );

  }
}


class ExtendedInfoTab extends StatelessWidget {
  const ExtendedInfoTab({Key? key, required this.fieldTitle, required this.fieldInfo}) : super(key: key);
  final String fieldTitle;
  final String fieldInfo;
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding:  EdgeInsets.symmetric(vertical:2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Padding(
          padding: EdgeInsets.only(bottom:1.h),
          child: Text(fieldTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Colors.grey)),
        ),
        Text(fieldInfo, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color:Colors.green))
      ]),
    );
  }
}
