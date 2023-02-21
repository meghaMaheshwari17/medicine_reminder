import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/provider/auth_provider.dart';
import 'package:med_reminder/screens/feedback.dart';
import 'package:med_reminder/screens/map_screen.dart';
import 'package:med_reminder/screens/prescriptions.dart';
import 'package:med_reminder/screens/search_med.dart';
import 'package:med_reminder/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Drawer(
      //Listview is used as an array
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(color: Color(0xf1f4f8)),
              accountName: Text(ap.userModel.name,style: GoogleFonts.poppins(color: Colors.black,fontWeight: FontWeight.bold),),
              accountEmail: Text(ap.userModel.email,style: GoogleFonts.abel(color: Colors.black)),

              // currentAccountPicture: Image.asset(image), //image was rendered as a square
              currentAccountPicture: //image will get rendered in a circle
                  CircleAvatar(
                      backgroundImage: NetworkImage(ap.userModel
                          .profilePic)), //for taking image from internet do NetworkImage
            ),
          ),
          ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            children:  <Widget>[
              // ListTile(
              //   //adding items to the drawer
              //   leading: Icon(CupertinoIcons.profile_circled,
              //       color: Colors.black), //home icon in start
              //   title: Text("Profile",
              //       textScaleFactor: 1.2,
              //       style: TextStyle(fontWeight: FontWeight.bold)),
              // ),
              ListTile(
                //adding items to the drawer
                  leading: const Icon(CupertinoIcons.folder_circle,
                      color: Colors.black), //home icon in start
                  title: const Text("Prescriptions",
                      textScaleFactor: 1.2,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>const Prescriptions()));
                  }
              ),
              ListTile(
                //adding items to the drawer
                leading: Icon(CupertinoIcons.search,
                    color: Colors.black), //home icon in start
                title: Text("Get Information",
                    textScaleFactor: 1.2,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>SearchPage()));
                },
              ),
              ListTile(
                //adding items to the drawer
                leading: Icon(CupertinoIcons.map,
                    color: Colors.black), //home icon in start
                title: Text("Search stores",
                    textScaleFactor: 1.2,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>const MapScreen()));
                },
              ),
              ListTile(
                //adding items to the drawer
                leading: Icon(CupertinoIcons.pen,
                    color: Colors.black), //home icon in start
                title: Text("Feedback",
                    textScaleFactor: 1.2,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>const FeedbackByUser()));
                },
              ),
              ListTile(
                //adding items to the drawer
                leading: Icon(CupertinoIcons.square_arrow_right,
                    color: Colors.black), //home icon in start
                title: Text("Log Out",
                    textScaleFactor: 1.2,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  //show alert box
                  // openAlertBox(context);
                  showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                            shape:const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20.0)
                                )
                            ),
                            contentPadding: EdgeInsets.only(top:1.h),
                            title:Text('Are you sure you want to logout?',textAlign:TextAlign.center,style:Theme.of(context).textTheme.titleMedium),
                            actions:[
                              TextButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: Text("No",style:Theme.of(context).textTheme.bodySmall!.copyWith(color:Colors.grey)),),
                              TextButton(onPressed: (){
                                // log out
                                ap.userSignOut().then(
                                        (value) => Navigator.of(context).pushAndRemoveUntil( MaterialPageRoute(builder: (context)=> const WelcomeScreen()), ((route) => false))
                                );
                              }, child: Text("Yes",style:Theme.of(context).textTheme.bodySmall!.copyWith(color:Colors.red)),
                              )
                            ]
                        );
                      });
                },
              ),
            ],
          ),

        ],
      ),
    );
  }

  // openAlertBox(BuildContext context){
  //   return showDialog(
  //       context: context,
  //       builder: (context){
  //         return AlertDialog(
  //             shape:const RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.all(
  //                     Radius.circular(20.0)
  //                 )
  //             ),
  //             contentPadding: EdgeInsets.only(top:1.h),
  //             title:Text('Are you sure you want to logout?',textAlign:TextAlign.center,style:Theme.of(context).textTheme.titleMedium),
  //             actions:[
  //               TextButton(onPressed: (){
  //                 Navigator.of(context).pop();
  //               }, child: Text("No",style:Theme.of(context).textTheme.bodySmall!.copyWith(color:Colors.grey)),),
  //               TextButton(onPressed: (){
  //                 // log out
  //                 ap.userSignOut().then(
  //                         (value) => Navigator.of(context).pushAndRemoveUntil( MaterialPageRoute(builder: (context)=> const WelcomeScreen()), ((route) => false))
  //                 );
  //               }, child: Text("Yes",style:Theme.of(context).textTheme.bodySmall!.copyWith(color:Colors.red)),
  //               )
  //             ]
  //         );
  //       });
  // }
}
