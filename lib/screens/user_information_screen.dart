// will get the info from user here
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/models/user_model.dart';
import 'package:med_reminder/provider/auth_provider.dart';
import 'package:med_reminder/screens/home_screen.dart';
import 'package:med_reminder/utils/utils.dart';
import 'dart:io';
import 'package:med_reminder/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  File? image; //user avatar
  final nameController = TextEditingController(); //for name
  final emailController = TextEditingController(); //for email

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
  }

  // for selecting image:- package used is image_picker
  void selectImage() async {
    image = await pickImage(context); //function written in utils
    setState(() {});
  }

  Widget build(BuildContext context) {
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
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height:10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Med",style:TextStyle(fontSize:6.h,fontWeight: FontWeight.bold)),
                          Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:6.h,fontWeight: FontWeight.bold))
                        ],
                      ),
                      SizedBox(height:8.h),
                      InkWell(
                        //on tapping the avatar
                        onTap: () =>
                            selectImage(), //selecting the image from gallery
                        child: image ==
                                null //if there is no image then simply show icon
                            ? const CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 50,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                backgroundImage: FileImage(image!), //user image
                                radius: 50,
                              ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        margin: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            // name field
                            textField(
                              hintText: "John Smith",
                              icon: Icons.account_circle,
                              inputType: TextInputType.name,
                              maxLines: 1,
                              controller: nameController,
                            ),

                            // email
                            textField(
                              hintText: "abc@example.com",
                              icon: Icons.email,
                              inputType: TextInputType.emailAddress,
                              maxLines: 1,
                              controller: emailController,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: CustomButton(
                          text: "Continue",
                          onPressed: () =>
                              storeData(), //store the data when user press this button
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // custom textField
  Widget textField({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Colors.green,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.green,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Colors.green.shade50,
          filled: true,
        ),
      ),
    );
  }

  // store user data to database
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        profilePic: "",
        phoneNumber: "",
        uid: "",
        createdAt: "");
    if (image != null) {
      // if image is not null then save the data to firestore
      ap.saveUserDataToFirebase(
          context: context,
          userModel: userModel,
          profilePic: image!,
          onSuccess: () {
            // after saving the data to firebase, save the data locally
            ap.saveUserDataToSP().then((value) => ap.setSignIn().then(
                  (value) => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                      (route) => false),
                ));
          });
    } else {
      showSnackBar(context, "Please upload your profile picture");
    }
  }
}
