import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/models/add_medicine_model.dart';
import 'package:med_reminder/models/add_refill_model.dart';
import 'package:med_reminder/screens/drawer.dart';
import 'package:med_reminder/screens/medicine_detail.dart';
import 'package:med_reminder/screens/new_entry.dart';
import 'package:med_reminder/screens/refill_detail.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/calender_day_model.dart';
import '../notifications/notifications.dart';
import '../provider/auth_provider.dart';
import 'calender.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //-------------------| Flutter notifications |-------------------
  final Notifications _notifications = Notifications();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  //for medicine reminders
  List<MedicineModel>? medReminders = [];
  List<MedicineModel>? todayMedReminders = [];
  //for refill reminders
  List<RefillModel>? refillReminders = [];
  List<RefillModel>? todayRefillReminders = [];
  //-----------------| Calendar days |------------------
  CalendarDayModel _days = CalendarDayModel();
  List<CalendarDayModel> _daysList = [];
  final months = <String>[ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December', ];
  //====================================================

  //handle last choose day index in calendar
  int _lastChooseDay = 0;

  @override
  void initState() {
    super.initState();
    // getData(); from firebase here
    // medReminders=[];
    setState(() {
      _daysList = _days.getCurrentDays();
    });
    initNotifies();
    setData();
  }

  Future setData() async {
    medReminders?.clear();
    refillReminders?.clear();
    //set refill reminders
    getRefillReminders().then((value){
      setState(() {
        refillReminders=value;
        _lastChooseDay=0;
      });
    });
    //set reminders
    getReminders().then((value) {
      setState(() {
        medReminders = value;
        _lastChooseDay=0;
      });
      chooseDay(_daysList[_lastChooseDay]);
    });


  }
  //init notifications
  Future initNotifies() async => flutterLocalNotificationsPlugin = await _notifications.initNotifies(context);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //has body and head
      appBar: AppBar(
           backgroundColor: Color(0xf1f4f8),
           elevation: 0,
           iconTheme: IconThemeData(color:Colors.black),
           title:Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               Text("Med",style:TextStyle(color:Colors.black,fontSize:5.h,fontWeight: FontWeight.bold)),
               Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:5.h,fontWeight: FontWeight.bold))
             ],
           ),
      ), //adds bar at the top
      body: Padding(
        // padding: EdgeInsets.all(2.h),
        padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
        child: Column(
          children: [
            const TopContainer(),
            Text("${months[DateTime.now().month]} ${DateTime.now().year}",style:GoogleFonts.poppins(fontSize: 3.h)),
            SizedBox(height:1.5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Calendar(chooseDay, _daysList),
            ),
            SizedBox(height: 2.h),
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  bottom: 1.h,
                ),
                child: Text("Reminders today: ${todayMedReminders!.length.toString()}",
                    style: Theme.of(context).textTheme.headlineSmall)),
            //the widget task space as per need
                Flexible(
                  child: BottomContainer(m: todayMedReminders),
                 ),
            SizedBox(height: 2.h),
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  bottom: 1.h,
                ),
                child: Text("Refill reminders today: ${todayRefillReminders!.length.toString()}",
                    style: Theme.of(context).textTheme.headlineSmall)),
                Flexible(
                  child: RefillContainer(r: todayRefillReminders),
                ),
          ],
        ),
      ),
      drawer: MyDrawer(), //side drawer with all the info
      floatingActionButton: SizedBox(
        width: 18.w,
        height: 9.h,
        child: FloatingActionButton(
          onPressed: () {
            // go to add medicine page
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const NewEntryPage()));
          },
          backgroundColor: Colors.green,
          child: Icon(Icons.add, size: 35.sp),
        ),
      ),
    );
  }

  //get medicine reminders from firebase
  Future<List<MedicineModel>> getReminders() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    List<MedicineModel>? m = await ap.getMedicineRemindersFromFirebase();
    return m;
  }
  //get refill reminders from firebase
  Future<List<RefillModel>> getRefillReminders() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    List<RefillModel>? r = await ap.getrefillRemindersFromFirebase();
    return r;
  }

  void chooseDay(CalendarDayModel clickedDay) {
    setState(() {
      _lastChooseDay = _daysList.indexOf(clickedDay);
      _daysList.forEach((day) => day.isChecked = false);
      CalendarDayModel chooseDay = _daysList[_daysList.indexOf(clickedDay)];
      chooseDay.isChecked = true;
       todayMedReminders?.clear();
       todayRefillReminders?.clear();
      // set today's reminders
      medReminders?.forEach((reminder)async {
        //add notification bool in every reminder
        DateTime pillDate=DateTime.parse(reminder.dateTime);
        if(chooseDay.dayNumber==pillDate.day && chooseDay.month== pillDate.month && chooseDay.year == pillDate.year){
          todayMedReminders?.add(reminder);
        }
      });
      //set today's refill reminders
      refillReminders?.forEach((reminder)async {
        //add notification bool in every reminder
        DateTime pillDate=DateTime.parse(reminder.date);
        if(chooseDay.dayNumber==pillDate.day && chooseDay.month== pillDate.month && chooseDay.year == pillDate.year){
          todayRefillReminders?.add(reminder);
        }
      });
      todayMedReminders?.sort((pill1,pill2)=>pill1.startTime.compareTo(pill2.startTime));
      todayRefillReminders?.sort((pill1,pill2)=>pill1.time.compareTo(pill2.time));
    });
  }
}

class TopContainer extends StatelessWidget {
  const TopContainer({super.key});
  // final int? count;
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
              bottom: 1.h,
            ),
            child: Text('Hello,',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color:Colors.green))),
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
              bottom: 1.h,
            ),
            child: Text('${ap.userModel.name}',
                style: Theme.of(context).textTheme.titleSmall)),
        SizedBox(
          height: 2.h,
        ),
      ],
    );
  }
}

class BottomContainer extends StatelessWidget {
  const BottomContainer({super.key, required this.m});
  final List<MedicineModel>? m;
  @override
  Widget build(BuildContext context) {
    return m?.length == 0
        ? Center(
            child: Text('No reminder added!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color:Colors.grey)),
          )
        :  GridView.builder(
            scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(top: 1.h),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              itemCount: m?.length,
              itemBuilder: (context, index) {
                return MedicineCard(
                  medicineName: m?[index]?.medicineName,
                  dosage: m?[index].dosage,
                  interval: m?[index].interval,
                  medicineType: m?[index].medicineType,
                  startTime: m?[index].startTime,
                  date:m?[index].dateTime,
                );
              },
            );
  }
}

class RefillContainer extends StatelessWidget {
  const RefillContainer({super.key, required this.r});
  final List<RefillModel>? r;
  @override
  Widget build(BuildContext context) {
    return r?.length == 0
        ? Center(
      child: Text('No refill reminder added!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(color:Colors.grey)),
        )
        : GridView.builder(
      padding: EdgeInsets.only(top: 1.h),
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ),
      itemCount: r?.length,
      itemBuilder: (context, index) {
        return RefillMedicineCard(
          medicineName: r?[index]?.medicineName,
          medicineType: r?[index]?.medicineType,
          time: r?[index].time,
          date: r?[index].date,
        );
      },
    );
  }
}

class MedicineCard extends StatelessWidget {
  const MedicineCard(
      {Key? key,
      required this.medicineName,
      required this.dosage,
      required this.interval,
      required this.medicineType,
      required this.startTime,
        required this.date})
      : super(key: key);
  final String? medicineName;
  final int? dosage;
  final int? interval;
  final String? medicineType;
  final String? startTime;
  final String? date;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.green[100],
      splashColor: Colors.green,
      onTap: () {
        //   go to medicine detail page
        DateTime newDate=DateTime.parse(date!);
        String d="${newDate.day}/${newDate.month}/${newDate.year}";
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                MedicineDetails(medicineName: medicineName, medicineType: medicineType, dosage: dosage, interval: interval,startTime: startTime,date:d)));
      },
      child: Container(
          padding:
              EdgeInsets.only(left: 2.w, right: 2.h, top: 1.h, bottom: 1.h),
          margin: EdgeInsets.all(1.h),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(2.h),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset("assets/${medicineType}.png", height: 7.h),
                const Spacer(),
                Text(medicineName!,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 0.3.h),
                //time interval data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Every ${interval!} hours",
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.grey)),
                   Text("${startTime}"),
                  ],
                ),
              ])),
    );
  }
}

class RefillMedicineCard extends StatelessWidget {
  const RefillMedicineCard(
      {Key? key,
        required this.medicineName,
        required this.medicineType,
        required this.time, required this.date,
      })
      : super(key: key);
  final String? medicineName;
  final String? medicineType;
  final String? time;
  final String? date;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.red[100],
      splashColor: Colors.red,
      onTap: () {
        //   go to refill detail page
        DateTime newDate=DateTime.parse(date!);
        String d="${newDate.day}/${newDate.month}/${newDate.year}";
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                RefillDetails(medicineName: medicineName, medicineType: medicineType, time: time,date:d)));
      },
      child: Container(
          padding:
          EdgeInsets.only(left: 2.w, right: 2.h, top: 1.h, bottom: 1.h),
          margin: EdgeInsets.all(1.h),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(2.h),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset("assets/${medicineType}.png", height: 7.h),
                const Spacer(),
                Text(medicineName!,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 0.3.h),
                //time interval data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Refill today",
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.grey)),
                    Text("${time}"),
                  ],
                ),
              ])),
    );
  }
}
