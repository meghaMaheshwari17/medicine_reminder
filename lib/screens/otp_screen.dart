import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/provider/auth_provider.dart';
import 'package:med_reminder/screens/home_screen.dart';
import 'package:med_reminder/screens/user_information_screen.dart';
import 'package:med_reminder/utils/utils.dart';
import 'package:med_reminder/widgets/custom_button.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId; //otp was sent after the user
  final String phoneNumber;
  const OtpScreen({super.key, required this.verificationId,required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode; //will store the otp entered by the user
  @override
  Widget build(BuildContext context) {
    // whenever the loading state is changed this will get updated
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              )
            : Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            //this will give an arrow which will navigate the user back
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Med",style:TextStyle(fontSize:6.h,fontWeight: FontWeight.bold)),
                            Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:6.h,fontWeight: FontWeight.bold))
                          ],
                        ),
                        SizedBox(height:4.h),
                        Container(
                          width: 200,
                          height: 200,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.shade300,
                          ),
                          child: Image.asset(
                            "assets/otp.png",
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Verification",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Enter the OTP send to your phone number",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // boxes for the otp :- from a package called PinPut
                        Pinput(
                          length: 6,
                          showCursor: true,
                          defaultPinTheme: PinTheme(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.green.shade200,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onCompleted: (value) {
                            setState(() {
                              otpCode = value;
                            });
                          },
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: CustomButton(
                            text: "Verify",
                            onPressed: () {
                              //on pressing the verify button
                              if (otpCode != null) {
                                //if user entered the otp
                                verifyOtp(context, otpCode!);
                              } else {
                                //if user didn't
                                showSnackBar(context, "Enter 6-Digit code");
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Didn't receive any code?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 15),
                    Center(
                      child: GestureDetector(
                        onTap: ()=>{
                          sendOtpAgain(context,widget.phoneNumber)
                          // verifyOtp(context, otpCode!);
                        },
                        child: Container(
                          child: Text(
                            'Resend New Code',
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 0.688,
                            ),
                          ),
                        ),
                      ),)
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void sendOtpAgain(BuildContext context,phoneNumber){
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.signInWithPhone(context,phoneNumber);
    verifyOtp(context,otpCode!);
  }

  // verifying the otp
  void verifyOtp(BuildContext context, String userOtp) {
    //
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
        context: context,
        verificationId: widget
            .verificationId, //the verificationId was passed to this page from register screen
        userOtp: userOtp,
        onSuccess: () {
          // after verifying the otp we have to check if the user already exists in the database
          ap.checkExistingUser().then((value) async {
            if (value == true) {
              // user exists in the database then get the data from the firestore and save it locally
              ap.getDataFromFirestore().then((value) => ap
                  .saveUserDataToSP()
                  .then((value) => ap.setSignIn().then((value) =>
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (route) => false))));
            } else {
              // new user
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserInformationScreen()),
                  (route) => false);
            }
          });
        });
  }
}
