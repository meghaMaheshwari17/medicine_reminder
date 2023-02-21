import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/models/add_medicine_model.dart';
import 'package:med_reminder/models/add_refill_model.dart';
import 'package:med_reminder/screens/slider.dart';
import 'package:med_reminder/screens/success_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../notifications/notifications.dart';
 import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../provider/auth_provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../utils/utils.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../widgets/convert_time.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({Key? key}) : super(key: key);

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Notifications _notifications = Notifications();
  late TextEditingController nameController;
  late TextEditingController dosageController;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  //which medicine type was clicked
  late bool bottle = false;
  late bool syringe = false;
  late bool tablet = false;
  late bool pill = false;
  //medicine name written
  String? medicineName;
  //dosage written
  int? dosage;
  //interval selected
  final _intervals = [6, 8, 12, 24];
  var _selected = 0; //for selecting interval
  //time selected
  TimeOfDay _reminderTime = const TimeOfDay(hour: 0, minute: 00);
  TimeOfDay _refillTime = const TimeOfDay(hour: 0, minute: 00);
  bool _reminderTimeClicked = false; //time was clicked or not
  bool _refillTimeClicked = false; //time was clicked or not
  //how many weeks have to set the reminder for
  int howManyDays = 1;
  DateTime refillDate=DateTime.now();
  //refill status toggle
  bool refillStatus=false;
  bool _refillDateClicked=false;
  final homeController=ScrollController();
  // to show clock for picking time
  Future<TimeOfDay> _selectTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
        _reminderTimeClicked = true;
      });
    }
    return picked!;
  }

  //to show clock for picking refill time
  Future<TimeOfDay> _selectRefillTime() async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: _refillTime);
    if (picked != null && picked != _refillTime) {
      setState(() {
        _refillTime = picked;
        _refillTimeClicked = true;
      });
    }
    return picked!;
  }

  //date picker
  Future<void> openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2100),
        builder: (BuildContext context, Widget ?child) {
          return Theme(
            data: ThemeData(
              splashColor: Colors.black,
              textTheme: TextTheme(
                titleMedium: TextStyle(color: Colors.black),
                labelLarge: TextStyle(color: Colors.black),
              ),
              dialogBackgroundColor: Colors.white, colorScheme: ColorScheme.light(
                  primary: Colors.green,
                  onSecondary: Colors.black,
                  onPrimary: Colors.white,
                  surface: Colors.black,
                  onSurface: Colors.black,
                  secondary: Colors.black),
            ),
            child: child ??Text(""),
          );
        }
    
    );

    if (pickedDate != null) {
      print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
      setState(() {
        refillDate=pickedDate;
        _refillDateClicked=true;
      });
    }
  }
  void sliderChanged(double value) =>
      setState(() => this.howManyDays = value.round());

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    dosageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    dosageController = TextEditingController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    initNotifies();
  }

  Future initNotifies() async => flutterLocalNotificationsPlugin =
      await _notifications.initNotifies(context);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color(0xf1f4f8),
          elevation: 0,
          iconTheme: IconThemeData(color:Colors.black),
          title:Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Med",style:TextStyle(color:Colors.black,fontSize:3.h,fontWeight: FontWeight.bold)),
              Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:3.h,fontWeight: FontWeight.bold))
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12, 12, 16, 0),
          child: SingleChildScrollView(
              controller: homeController,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PanelTitle(title: "Medicine Name", isRequired: true),
              TextFormField(
                  controller: nameController,
                  maxLength: 12,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Name of your medication"),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Color(0xFF59C180))),
              const PanelTitle(title: "Dosage in mg", isRequired: false),
              TextFormField(
                  controller: dosageController,
                  maxLength: 12,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Dosage of your medication"),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Color(0xFF59C180))),
              const PanelTitle(title: "Medicine Type", isRequired: false),
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: StreamBuilder(builder: (context, snapshot) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //bottle
                        GestureDetector(
                          onTap: () {
                            //  selected medicine type
                            setState(() {
                              bottle = !bottle;
                              tablet = false;
                              syringe = false;
                              pill = false;
                            });
                          },
                          child: Column(children: [
                            Container(
                                width: 20.w,
                                alignment: Alignment.center,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.h),
                                  color: bottle ? Colors.green : Colors.white,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(top: 1.h, bottom: 1.h),
                                    child: Image.asset('assets/bottle.png',
                                        height: 12.h, width: 12.w),
                                  ),
                                ) //flutter_svg package
                                ),
                            Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Container(
                                  width: 20.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: bottle
                                        ? Colors.green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                      child: Text("Bottle",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: bottle
                                                      ? Colors.white
                                                      : Colors.black)))),
                            )
                          ]),
                        ),

                        //pill
                        GestureDetector(
                          onTap: () {
                            //  selected medicine type
                            setState(() {
                              pill = !pill;
                              bottle = false;
                              tablet = false;
                              syringe = false;
                            });
                          },
                          child: Column(children: [
                            Container(
                                width: 20.w,
                                alignment: Alignment.center,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.h),
                                  color: pill ? Colors.green : Colors.white,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(top: 1.h, bottom: 1.h),
                                    child: Image.asset('assets/pill.png',
                                        height: 12.h, width: 12.w),
                                  ),
                                )),
                            Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Container(
                                  width: 20.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: pill
                                        ? Colors.green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                      child: Text("Pill",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: pill
                                                      ? Colors.white
                                                      : Colors.black)))),
                            )
                          ]),
                        ),

                        //syringe
                        GestureDetector(
                          onTap: () {
                            //  selected medicine type
                            setState(() {
                              syringe = !syringe;
                              bottle = false;
                              tablet = false;
                              pill = false;
                            });
                          },
                          child: Column(children: [
                            Container(
                                width: 20.w,
                                alignment: Alignment.center,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.h),
                                  color: syringe ? Colors.green : Colors.white,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(top: 1.h, bottom: 1.h),
                                    child: Image.asset('assets/syringe.png',
                                        height: 12.h, width: 12.w),
                                  ),
                                )),
                            Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Container(
                                  width: 20.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: syringe
                                        ? Colors.green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                      child: Text("Syringe",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: syringe
                                                      ? Colors.white
                                                      : Colors.black)))),
                            )
                          ]),
                        ),

                        //  tablet
                        GestureDetector(
                          onTap: () {
                            //  selected medicine type
                            setState(() {
                              tablet = !tablet;
                              bottle = false;
                              syringe = false;
                              pill = false;
                            });
                          },
                          child: Column(children: [
                            Container(
                                width: 20.w,
                                alignment: Alignment.center,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.h),
                                  color: tablet ? Colors.green : Colors.white,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(top: 1.h, bottom: 1.h),
                                    child: Image.asset('assets/tablet.png',
                                        height: 12.h, width: 12.w),
                                  ),
                                )),
                            Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Container(
                                  width: 20.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: tablet
                                        ? Colors.green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                      child: Text("Tablet",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: tablet
                                                      ? Colors.white
                                                      : Colors.black)))),
                            )
                          ]),
                        )
                      ]);
                }),
              ),
              SizedBox(height:1.h),
              Container(
                child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:[
                    Column(
                      children: [
                        const PanelTitle(title: "For how long?", isRequired: false),
                        Container(
                          // height: 0.18.h,
                            width:50.w,
                            child: UserSlider(this.sliderChanged, this.howManyDays)),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: FittedBox(
                              child: Text('$howManyDays days',
                                  style: Theme.of(context).textTheme.bodySmall)),
                        ),
                      ],
                    ),
                    Column(
                      children:[
                        const PanelTitle(title: "Starting Time", isRequired: true),
                        SizedBox(
                            height: 8.h,
                            width:35.w,
                            child: Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: const StadiumBorder()),
                                  onPressed: () {
                                    _selectTime();
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.access_time),
                                        Text(
                                            _reminderTimeClicked == false
                                                ? "Select Time"
                                                : "${convertTime(_reminderTime.hour.toString())}:${convertTime(_reminderTime.minute.toString())}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(color: Colors.white)),
                                      ],
                                    ),
                                  )),
                            )),
                      ]
                    )

                  ]
                )
              ),


              //for selecting time interval
              const PanelTitle(title: "Interval Selection", isRequired: true),
              Padding(
                 padding: EdgeInsets.only(top: 0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remind me every',
                        style: Theme.of(context).textTheme.titleSmall),
                    DropdownButton(
                        iconEnabledColor:
                            _selected == 0 ? Colors.green : Colors.red,
                        itemHeight: 8.h,
                        hint: _selected == 0
                            ? Text('Select an Interval',
                                style: Theme.of(context).textTheme.bodySmall)
                            : null,
                        elevation: 4,
                        value: _selected == 0 ? null : _selected,
                        items: _intervals.map((int value) {
                          return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(color: Colors.red)));
                        }).toList(),
                        onChanged: (newVal) {
                          setState(() {
                            _selected = newVal!;
                          });
                        }),
                    Text(_selected == 1 ? "hour" : "hours",
                        style: Theme.of(context).textTheme.titleSmall)
                  ],
                ),
              ),
              //class down


              // SizedBox(height: 2.h),

              // for refill alert
              Row(
                children: [
                  const PanelTitle(title: "Set refill alert?", isRequired: false),
                  SizedBox(width:6.w),
                  FlutterSwitch(
                    activeColor: Colors.green,
                    width: 15.w,
                    height: 4.h,
                    showOnOff: true,
                    activeText: "Yes",
                    valueFontSize: 10.0,
                    inactiveText: "No",
                    activeTextColor: Colors.white,
                    inactiveTextColor: Colors.blue[50]!,
                    value: refillStatus,
                    onToggle: (val) {
                      setState(() {
                        refillStatus = val;
                      });
                      if(refillStatus){ //if refillStatus is true than scroll to the end
                        homeController.animateTo(
                          600, // change 0.0 {double offset} to corresponding widget position
                          duration: Duration(seconds: 1),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                  ),
                ],
              ),
                  //  if refill status is true then show the time picker and date picker
                  if(refillStatus)...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            height: 7.h,
                            width:30.w,
                            child: Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: const StadiumBorder()),
                                  onPressed: () {
                                    openDatePicker();
                                  },
                                  child: Center(
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children:[
                                        Icon(Icons.date_range_outlined),
                                        Text(
                                            _refillDateClicked == false
                                                ? "Select Date"
                                                : "${refillDate.day}/${refillDate.month}/${refillDate.year}",
                                            style: Theme.of(context)
                                                .textTheme.bodySmall?.copyWith(color: Colors.white)
                                        ),
                                      ]
                                    ),

                                  )),
                            )),
                        SizedBox(
                            height: 7.h,
                            width:30.w,
                            child: Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: const StadiumBorder()),
                                  onPressed: () {
                                    _selectRefillTime();
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.access_time
                                        ),
                                        Text(
                                            _refillTimeClicked == false
                                                ? "Select Time"
                                                : "${convertTime(_refillTime.hour.toString())}:${convertTime(_refillTime.minute.toString())}",
                                            style: Theme.of(context)
                                                .textTheme.bodySmall?.copyWith(color: Colors.white)
                                        ),
                                      ],
                                    ),
                                  )),
                            )),
                      ],
                    ),
                    SizedBox(height:4.h),
                  ],


            ]),
          ),
        ),
      bottomNavigationBar:  BottomAppBar(
        elevation: 0,
        notchMargin: 20.0,
        child: Padding(
          padding: EdgeInsets.only(left: 8.w, right: 8.w),
          child: SizedBox(
              width: 80.w,
              height: 6.5.h,
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.green,
                  onPressed: () async {
                    //validation
                    String name;
                    int tempDosage;
                    if (nameController.text.length <= 1) {
                      //name of the medicine is not added
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Add name of the medicine!"),
                        backgroundColor: Colors.red,
                        duration: Duration(milliseconds: 2000),
                      ));
                      return;
                    }
                    if (_selected == 0) {
                      //interval of dosage is not added
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Add interval of the reminder!"),
                        backgroundColor: Colors.red,
                        duration: Duration(milliseconds: 2000),
                      ));
                      return;
                    }
                    if (_reminderTimeClicked != true) {
                      //time was not picked
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Add time of the reminder!"),
                        backgroundColor: Colors.red,
                        duration: Duration(milliseconds: 2000),
                      ));

                      return;
                    }
                    if(refillStatus){ //if refill alert is also turned on
                      //  if date is not picked
                      if(!_refillDateClicked){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Add date for the refill alert!"),
                          backgroundColor: Colors.red,
                          duration: Duration(milliseconds: 2000),
                        ));
                        return;
                      }
                      if(!_refillTimeClicked){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Add time for the refill alert!"),
                          backgroundColor: Colors.red,
                          duration: Duration(milliseconds: 2000),
                        ));
                        return;
                      }

                    }
                    name = nameController.text;
                    if (dosageController.text == "") {
                      tempDosage = 0;
                    } else {
                      tempDosage = int.parse(dosageController.text);
                    }
                    setState(() {
                      medicineName = name;
                      dosage = tempDosage;
                    });
                    //  add medicine to the firebase
                    await storeData();
                  },
                elevation: 4.0,
                icon: const Icon(Icons.add),
                  label: const Text('Add reminder'),
              )
          ),
        ),
      ),

    );
  }

  DateTime join(DateTime date, TimeOfDay time) {
    return new DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
  }

  //store data in firebase
  Future<void> storeData() async {
    String? medicineType = "none";
    if (pill) {
      medicineType = "pill";
    } else if (tablet) {
      medicineType = "tablet";
    } else if (syringe) {
      medicineType = "syringe";
    } else if (bottle) {
      medicineType = "bottle";
    }
    final now = new DateTime.now();
    final ap = Provider.of<AuthProvider>(context, listen: false);
    DateTime timeInDateTime = join(now, _reminderTime);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
    for (int i = 0; i < howManyDays; i++) {
        int nId=Random().nextInt(50000000);
        print(nId);
         MedicineModel medicineModel = MedicineModel(
             medicineName: medicineName!,
             dosage: dosage!,
             medicineType: medicineType!,
             startTime: "${convertTime(timeInDateTime.hour.toString())}:${convertTime(timeInDateTime.minute.toString())}",
             interval: _selected,
             uid: ap.uid,
             dateTime: timeInDateTime.toString(),
             notifyId:nId,
         );
         ap.saveMedicineReminderToFirebase(
             context: context,
             medicineModel: medicineModel,
             onSuccess: (){print('reminder saved successfully');});
        //set the notification schedule
        await _notifications.showNotification(
            _selected,
            "Reminder to take your ${medicineType} : ${medicineName!}",
            "$dosage MG ${medicineType!}",
            timeInDateTime,
            nId,
            flutterLocalNotificationsPlugin);
          timeInDateTime=timeInDateTime.add(Duration(days:1));
     }
    //if refill alert was filled then add its reminder also
    if(refillStatus){
      DateTime refillTimeInDateTime = join(refillDate, _refillTime);
      int notifyId=Random().nextInt(50000000);
      RefillModel refillModel=RefillModel(
          medicineName: medicineName!,
          medicineType: medicineType,
          time: "${convertTime(_refillTime.hour.toString())}:${convertTime(_refillTime.minute.toString())}",
          uid: ap.uid,
          date: refillDate.toString(),
          notifyId: notifyId
      );
      //save to firebase
      ap.saveRefillReminderToFirebase(context: context, refillModel: refillModel, onSuccess: (){print('refill saved successfully');});
      //save its notification
      await _notifications.showRefillNotification(
          'Refill Reminder for ${medicineName}',
          'Sending you a reminder that you are due for your refill',
          refillTimeInDateTime,
          notifyId,
          flutterLocalNotificationsPlugin);
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SuccessScreen()));
  }

  //
}
//for input label

class PanelTitle extends StatelessWidget {
  const PanelTitle({Key? key, required this.title, required this.isRequired})
      : super(key: key);
  final String title;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: title,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            TextSpan(
              text: isRequired ? '*' : '',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
