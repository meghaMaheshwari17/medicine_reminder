// import 'package:medicine/models/pill.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class Notifications {

  BuildContext ?_context;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Future<FlutterLocalNotificationsPlugin> initNotifies(BuildContext context) async{
    this._context = context;
    //-----------------------------| Inicialize local notifications |--------------------------------------
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //      onDidReceiveNotificationResponse: (details){
    //           new AlertDialog(
    //          title: Text("PayLoad"),
    //          content: Text("Payload : "),
    //        );
    //      }
    // );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {});
    return flutterLocalNotificationsPlugin;
    //======================================================================================================
  }
  // initializeNotification() async {
  //   _configureLocalTimeZone();
  //   const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
  //
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //   AndroidInitializationSettings("ic_launcher");
  //
  //   const InitializationSettings initializationSettings = InitializationSettings(
  //     iOS: initializationSettingsIOS,
  //     android: initializationSettingsAndroid,
  //   );
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }



  //---------------------------------| Show the notification in the specific time |-------------------------------
  // Future showNotification(String title, String description, DateTime time, int id, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //       id.toInt(),
  //       title,
  //       description,
  //       // tz.TZDateTime.now(tz.local).add(Duration(milliseconds: 3000)),
  //       tz.TZDateTime.from(time, tz.local),
  //       const NotificationDetails(
  //           android: AndroidNotificationDetails(
  //               'medicines_id',
  //               'medicines',
  //               channelDescription: 'medicine reminder channel',
  //               importance: Importance.high,
  //               priority: Priority.high,
  //               playSound: true,
  //               color: Colors.green)),
  //       androidAllowWhileIdle: true,
  //       uiLocalNotificationDateInterpretation:
  //       UILocalNotificationDateInterpretation.absoluteTime);
  // }
  Future showNotification(int interval,String title, String description, DateTime time, int id, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    //scheduling for particular time interval
      for (int i = 0; i < (24/interval).floor(); i++) {
       var notificationTime = time.add(Duration(hours: 0 * interval));
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          description,
          tz.TZDateTime.from(notificationTime, tz.local),
           NotificationDetails(
              android: AndroidNotificationDetails(
                  'medicines_id_5_${id}',
                  'medicines',
                  channelDescription: 'medicine reminder channel',
                  importance: Importance.max,
                  priority: Priority.high,
                  playSound: true,
                  color: Colors.green,
              )),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime);
     }

      if(interval==0){
        await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            title,
            description,
            tz.TZDateTime.from(time, tz.local),
            NotificationDetails(
                android: AndroidNotificationDetails(
                  'medicines_id_5_${id}',
                  'medicines',
                  channelDescription: 'medicine reminder channel',
                  importance: Importance.max,
                  priority: Priority.high,
                  playSound: true,
                  color: Colors.green,
                )),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime);
      }
  }

  Future showRefillNotification(String title, String description, DateTime time, int id, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    //scheduling for particular time interval
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          description,
          tz.TZDateTime.from(time, tz.local),
          NotificationDetails(
              android: AndroidNotificationDetails(
                'refill_id_1_${id}',
                'medicines',
                channelDescription: 'refill reminder channel',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                color: Colors.green,
              )),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime);
  }

  //================================================================================================================


  //-------------------------| Cancel the notify |---------------------------
  Future removeNotify(int notifyId, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async{
    try{
      return await flutterLocalNotificationsPlugin.cancel(notifyId);
    }catch(e){
      return null;
    }
  }

  //==========================================================================


  //-------------| function to inicialize local notifications |---------------------------
  // Future onSelectNotification(String payload) async {
  //   showDialog(
  //     context: _context!,
  //     builder: (_) {
  //       return new AlertDialog(
  //         title: Text("PayLoad"),
  //         content: Text("Payload : $payload"),
  //       );
  //     },
  //   );
  // }

//======================================================================================


}