import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/provider/auth_provider.dart';
import 'package:med_reminder/screens/home_screen.dart';
import 'package:med_reminder/screens/register_screen.dart';
import 'package:med_reminder/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context,
        listen: false); //ap means authProvider
    return Scaffold(
        body: SafeArea(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Med",style:TextStyle(fontSize:6.h,fontWeight: FontWeight.bold)),
                  Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:6.h,fontWeight: FontWeight.bold))
                ],
              ),
              SizedBox(height: 5.h),
              Image.asset(
                "assets/medicine.png",
                height: 300,
                fit:BoxFit.contain,
              ),
               SizedBox(height: 8.h),
               const Text(
                "Be in control of your medicines",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "An easy-to-use and reliable app that helps you remember to take your medicines at the right time",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // getting custom button from widgets
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    onPressed: () async {
                      // if the user is already signed in then we have to redirect them to our home screen

                      if (ap.isSignedIn == true) {
                        // if the user is already signed in and we refresh the app , then we need to get the data from shared preferences again or it will throw an error inside the app
                        await ap.getDataFromSP().whenComplete(() =>
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen())));
                      } else {
                        //on pressing the button it will reroute to register screen
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()));
                      }
                    },
                    text: "Get started",
                  ))
            ],
          )),
    ));
  }
}
