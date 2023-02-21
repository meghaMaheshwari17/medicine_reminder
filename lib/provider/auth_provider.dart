// // package downloded for this is :- provider
// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:med_reminder/models/user_model.dart';
// import 'package:med_reminder/screens/otp_screen.dart';
// import 'package:med_reminder/utils/utils.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/cupertino.dart';
//
// class AuthProvider extends ChangeNotifier {
//   bool _isSignedIn = false; //check if user is signed in
//   bool get isSignedIn => _isSignedIn;
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//   // storing userid
//   String? _uid;
//   String get uid => _uid!;
//
//   // global user model
//   UserModel? _userModel;
//   UserModel get userModel => _userModel!;
//   // initialise firebase authentication
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   // intialise firebase firestore
//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//   // intialise firebase storage
//   final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
//   AuthProvider() {
//     checkSign();
//   }
//
// //  check if user is already signed in or out
//   void checkSign() async {
//     final SharedPreferences s = await SharedPreferences.getInstance();
//     _isSignedIn = s.getBool("is_signedin") ??
//         false; //if that key exists in the device it will return true
//     notifyListeners();
//   }
//
// // setting sign in to true after user data is saved to SP
//   Future setSignIn() async {
//     final SharedPreferences s = await SharedPreferences.getInstance();
//     s.setBool("is_signedin", true);
//     _isSignedIn = true;
//   }
//
//   // sign in with phone
//   void signInWithPhone(BuildContext context, String phoneNumber) async {
//     try {
//       // verify phone number
//       await _firebaseAuth.verifyPhoneNumber(
//           phoneNumber: phoneNumber!, //sending the phone number
//           timeout: const Duration(seconds: 60),
//           verificationCompleted:
//               (PhoneAuthCredential phoneAuthCredential) async {
//             // when the phone number is verified
//             // await _firebaseAuth!.signInWithCredential(phoneAuthCredential);
//                 await _firebaseAuth!.signInWithCredential(phoneAuthCredential).then((value) async {
//                   if (value.user != null) {
//                     print("Done !! verificationCompleted");
//                   } else {
//                     print("Failed!! verificationCompleted");
//                   }
//                 }).catchError((e) {
//                   // Fluttertoast.showToast(msg: 'Something Went Wrong: ${e.toString()}');
//                   showSnackBar(context, e.toString());
//                 });
//           },
//           verificationFailed: (error) {
//             throw Exception(error.message);
//           },
//           codeSent: ((verificationId, forceResendingToken) {
//             //when the code is sent to otp screen
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: ((context) =>
//                         OtpScreen(verificationId: verificationId))));
//           }),
//           codeAutoRetrievalTimeout: ((verificationId) {}));
//     } on FirebaseAuthException catch (e) {
//       // show error on signin
//       showSnackBar(context, e.message.toString());
//     }
//   }
//
//   // verifying otp getting from OtpScreen
//   void verifyOtp({
//     required BuildContext context,
//     required String verificationId, //code sent by firebase
//     required userOtp, //code enetered by the user
//     required Function onSuccess,
//   }) async {
//     _isLoading = true;
//     notifyListeners(); //notify the listener that loading is true
//     try {
//       PhoneAuthCredential creds = PhoneAuthProvider.credential(
//           verificationId: verificationId, smsCode: userOtp);
//       User? user = (await _firebaseAuth.signInWithCredential(creds))
//           .user!; //this will return a User value
//       // checking if user is not null
//       if (user != null) {
//         _uid = user.uid; //getting the user id
//         onSuccess();
//       }
//       // if it is null
//       _isLoading = false;
//       notifyListeners();
//     } on FirebaseAuthException catch (e) {
//       showSnackBar(context, e.message.toString());
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Database operations
//   // check after verifying the otp that user exists in the database or not
//   Future<bool> checkExistingUser() async {
//     // checking the user collection for the global uid that was set in verifyOtp function
//     DocumentSnapshot snapshot =
//         await _firebaseFirestore.collection("users").doc(_uid).get();
//     if (snapshot.exists) {
//       print("User exists");
//       return true;
//     } else {
//       print("New user");
//       return false;
//     }
//   }
//
// // to save user data to firestore
//   void saveUserDataToFirebase({
//     required BuildContext context,
//     required UserModel userModel,
//     required File profilePic,
//     required Function onSuccess,
//   }) async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       // uploading image to firebase storage
//       await storeFileToStorage("profilePic/$_uid", profilePic).then((value) {
//         // after storing it in storage
//         // update the usermodel
//         userModel.profilePic = value;
//         userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
//         userModel.phoneNumber = _firebaseAuth.currentUser!
//             .phoneNumber!; //getting the phone number from firebaseAuth
//         userModel.uid =
//             _firebaseAuth.currentUser!.uid!; //getting the uid from firebaseAuth
//       });
//       _userModel = userModel; //update the usermodel
//       //  uploading to database
//       await _firebaseFirestore
//           .collection("users")
//           .doc(_uid)
//           .set(userModel.toMap())
//           .then((value) {
//         // after uploading it in firebase
//         onSuccess();
//         _isLoading = false;
//         notifyListeners();
//       });
//     } on FirebaseAuthException catch (e) {
//       showSnackBar(context, e.message.toString());
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // storing the profile pic to firebase storage and the returning the url from it
//   Future<String> storeFileToStorage(String ref, File file) async {
//     UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
//     TaskSnapshot snapshot = await uploadTask;
//     String downloadUrl = await snapshot.ref.getDownloadURL();
//     return downloadUrl;
//   }
//
// // getting the data from the firestore
//   Future getDataFromFirestore() async {
//     await _firebaseFirestore
//         .collection("users")
//         .doc(_firebaseAuth.currentUser!.uid)
//         .get()
//         .then((DocumentSnapshot snapshot) {
//       _userModel = UserModel(
//           name: snapshot['name'],
//           email: snapshot['email'],
//           profilePic: snapshot['profilePic'],
//           phoneNumber: snapshot['phoneNumber'],
//           uid: snapshot['uid'],
//           createdAt: snapshot['createdAt']);
//     });
//     _uid = userModel.uid;
//   }
//
//   // storing data locally in the app
//   Future saveUserDataToSP() async {
//     SharedPreferences s = await SharedPreferences.getInstance();
//     await s.setString("user_model", jsonEncode(userModel.toMap()));
//   }
//
// //  getting the data from shared preferences
//   Future getDataFromSP() async {
//     SharedPreferences s = await SharedPreferences.getInstance();
//     String data = s.getString("user_model") ?? '';
//     _userModel = UserModel.fromMap(jsonDecode(data));
//     _uid = userModel.uid;
//     notifyListeners();
//   }
//
// // signing out the user from the app
//   Future userSignOut() async {
//     SharedPreferences s = await SharedPreferences.getInstance();
//     await _firebaseAuth.signOut();
//     _isSignedIn = false;
//     notifyListeners();
//     // also clear out the data stored locally
//     s.clear();
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:med_reminder/models/add_medicine_model.dart';
import 'package:med_reminder/models/add_refill_model.dart';
import 'package:med_reminder/models/feedback_model.dart';
import 'package:med_reminder/models/user_model.dart';
 import 'package:med_reminder/screens/otp_screen.dart';
import 'package:med_reminder/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../notifications/notifications.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;
  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSign();
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // signin
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          // timeout: const Duration(seconds: 60),
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(verificationId: verificationId,phoneNumber: phoneNumber),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  // verify otp
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;

      if (user != null) {
        // carry our logic
        _uid = user.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // DATABASE OPERTAIONS
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
    await _firebaseFirestore.collection("users").doc(_uid).get();
    if (snapshot.exists) {
      print("USER EXISTS");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required File profilePic,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // uploading image to firebase storage.
      await storeFileToStorage("profilePic/$_uid", profilePic).then((value) {
        userModel.profilePic = value;
        userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        userModel.uid = _firebaseAuth.currentUser!.uid!;
      });
      _userModel = userModel;

      // uploading to database
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future getDataFromFirestore() async {
    await _firebaseFirestore
        .collection("users")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _userModel = UserModel(
        name: snapshot['name'],
        email: snapshot['email'],
        createdAt: snapshot['createdAt'],
        uid: snapshot['uid'],
        profilePic: snapshot['profilePic'],
        phoneNumber: snapshot['phoneNumber'],
      );
      _uid = userModel.uid;
    });
  }

  // STORING DATA LOCALLY
  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(userModel.toMap()));
  }

  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? '';
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }

//  deleting pdf to firebase storage
  Future<void> deletePdf(String ref, String file)async{
    print(ref);
    try{
      _isLoading = true;
      notifyListeners();
      await _firebaseStorage.ref().child(ref).delete();
    }on FirebaseAuthException catch (e) {
      _isLoading = false;
      print(e.toString());
    }

  }
  Future<String> savePdf(String ref, File file)async{
    print(ref);
    String downloadUrl="";
    try{
      _isLoading = true;
      notifyListeners();
      UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
       downloadUrl = await snapshot.ref.getDownloadURL();
    }on FirebaseAuthException catch (e) {
      _isLoading = false;
      print(e.toString());
     }
     return downloadUrl;
  }

//  getting files from firebase storage
//   Future<List<String>> getPdfs()async{
  Future<ListResult> getPdfs()async{
    final storageRef = _firebaseStorage.ref().child("prescription/$_uid");
    final listResult = await storageRef.listAll();
    return listResult;
  }


//  store new medicine reminder in firebase

  void saveMedicineReminderToFirebase({
    required BuildContext context,
    required MedicineModel medicineModel,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // uploading to database
      await _firebaseFirestore
          .collection("medicine_reminder")
          .doc()
          .set(medicineModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

//  get medicine reminders from
Future<List<MedicineModel>>getMedicineRemindersFromFirebase()async{
     List<MedicineModel>?medReminders=[];
    await _firebaseFirestore
        .collection("medicine_reminder")
        .where("uid",isEqualTo: _uid)
        .get()
        .then((QuerySnapshot snapshot)=> {
            snapshot.docs.forEach ((reminder) async {
                 MedicineModel? m =MedicineModel(
                   medicineName: reminder['medicineName'],
                   dosage: reminder['dosage'],
                   medicineType: reminder['medicineType'],
                   startTime: reminder['startTime'],
                   interval: reminder['interval'],
                   uid: reminder['uid'],
                   dateTime:reminder['dateTime'],
                   notifyId: reminder['notifyId'],
                 );
                    medReminders!.add(m);
              })
          });
    return medReminders!;
  }

//delete medicine reminder from firebase
  Future<List<int>> deleteMedicineReminderFromFirebase(String medicineName)async{
    List<int>notifyIds=[];
    try{
      _isLoading = true;
      notifyListeners();
      await _firebaseFirestore.collection("medicine_reminder")
          .where("uid",isEqualTo: _uid)
          .where("medicineName",isEqualTo:medicineName).get().then((QuerySnapshot snapshot){
            for(var i in snapshot.docs){
               print("reminder: ${i['notifyId']}");
               notifyIds.add(i['notifyId']);
               i.reference.delete();
            }
      });

    }on FirebaseAuthException catch (e) {
      _isLoading = false;
      print(e.toString());
    }
    return notifyIds;

  }


//  add refill reminder to firebase
  void saveRefillReminderToFirebase({
    required BuildContext context,
    required RefillModel refillModel,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // uploading to database
      await _firebaseFirestore
          .collection("refill_reminders")
          .doc()
          .set(refillModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

//  get refill reminders from
  Future<List<RefillModel>>getrefillRemindersFromFirebase()async{
    List<RefillModel>?refillReminders=[];
    await _firebaseFirestore
        .collection("refill_reminders")
        .where("uid",isEqualTo: _uid)
        .get()
        .then((QuerySnapshot snapshot)=> {
      snapshot.docs.forEach ((reminder) async {
        RefillModel? m =RefillModel(
            medicineName: reminder['medicineName'],
            medicineType:reminder['medicineType'],
            time: reminder['time'],
            uid: reminder['uid'],
            date: reminder['date'],
            notifyId: reminder['notifyId']
        );
        refillReminders!.add(m);
      })
    });
    return refillReminders!;
  }

  //delete refill reminder from firebase
  Future<int> deleteRefillReminderFromFirebase(String medicineName)async{
    int notifyId=0;
    try{
      _isLoading = true;
      notifyListeners();
      await _firebaseFirestore.collection("refill_reminders")
          .where("uid",isEqualTo: _uid)
           .where("medicineName",isEqualTo:medicineName).get().then((QuerySnapshot snapshot){
               notifyId=snapshot.docs[0]['notifyId'];
               print("delete refill:${snapshot.docs[0]['notifyId']}");
                snapshot.docs[0].reference.delete();
                print("refill reminder deleted");
      });

    }on FirebaseAuthException catch (e) {
      _isLoading = false;
      print(e.toString());
    }
    return notifyId;
  }

//  add feedback to the firebase
  Future<void> saveFeedbackToFirebase({
    required BuildContext context,
    required FeedbackModel feedbackModel,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // uploading feedback to firebase storage
      // uploading to database
      feedbackModel.uid=_uid!;
      await _firebaseFirestore
          .collection("feedbacks")
          .doc()
          .set(feedbackModel.toMap())
          .then((value) {
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Thank you for your feedback!",style:TextStyle(color:Colors.white)),
          backgroundColor: Colors.green,
          padding:EdgeInsets.all(2.w),
          duration: Duration(milliseconds: 2000),
        ));
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

}

