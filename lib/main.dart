import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:med_reminder/provider/auth_provider.dart';
import 'package:med_reminder/screens/home_screen.dart';
import 'package:med_reminder/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Sizer(
        builder: (context,orientation,deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: WelcomeScreen(),
            routes: {
              // When navigating to the "/" route, build the FirstScreen widget.
              '/home': (context) => const HomeScreen(),
            },
            title: "MedReminder",
            theme:ThemeData(
              appBarTheme: AppBarTheme(
                centerTitle: true,
                toolbarHeight: 8.h,
                iconTheme: IconThemeData(
                  size:20.sp,
                  color:Colors.white,
                ),
                titleTextStyle: GoogleFonts.mulish(
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize:16.sp,

                ),
                color: Colors.green
              ),
              textTheme: TextTheme(
                  headlineSmall:TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900
                  ),
                headlineMedium: GoogleFonts.aBeeZee(
                    color:Color(0xFF564850),
                    fontSize:24.sp,
                    fontWeight: FontWeight.w900),
                titleSmall:GoogleFonts.poppins(
                    color:Color(0xFF564850),
                    fontSize:12.sp,
                    ),
                  titleMedium:GoogleFonts.poppins(
                    color:Color(0xFF564850),
                    fontSize:15.sp,
                  ),
                  displaySmall:TextStyle(
                    fontSize: 28.sp,
                    color:Color(0xFFFF5252),
                      fontWeight: FontWeight.w400
                  ),
                  labelMedium:TextStyle(
                    fontSize:10.sp,
                    fontWeight: FontWeight.w500
                  ),
                  bodySmall:GoogleFonts.poppins(
                    color:Colors.green,
                    fontSize:9.sp,
                      fontWeight: FontWeight.w500
                  ),
                  titleLarge:GoogleFonts.poppins(
                      fontSize:13.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0
                  ),
              ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                     foregroundColor: Colors.white,
                  ),
                ),
              inputDecorationTheme: const InputDecorationTheme(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color:Color(0xFF59C180),width:0.7),

                ),
                border:UnderlineInputBorder(
                  borderSide: BorderSide(color:Color(0xFF59C180))
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:Colors.black12,
                  )
                )
               ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.green[500],
                hourMinuteColor: Colors.white,
                hourMinuteTextColor: Colors.green,
                dayPeriodColor: Colors.white,
                // dayPeriodTextColor:Colors.green,
                dialBackgroundColor: Colors.white,
                dialHandColor: Colors.green,
                entryModeIconColor: Colors.white,
                dayPeriodTextStyle: GoogleFonts.aBeeZee(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold
                ),
                dayPeriodBorderSide: BorderSide(color:Colors.green)
              )
            ),

          );
        }
      ),
    );
  }
}


