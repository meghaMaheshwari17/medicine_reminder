import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_reminder/models/med_info_model.dart';

// will show notification
void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

// for uploading image file
Future<File?> pickImage(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(context, e.toString());
  }
  return image; //return the image picked from the user's gallery
}


// for fetching data from an api
//Note:- have to make this error free:-
  Future<MedInfoModel>fetchMed(String searchVal) async {
  final response = await http.get(
    Uri.parse('https://api.fda.gov/drug/label.json?search=active_ingredient:%22{$searchVal}%22&limit=1'),
    // Send authorization headers to the backend.
    // headers: {
    //   'X-RapidAPI-Key': '4cd680501cmshdd62b700e11d555p19fc11jsnc25cc79d85ed',
    //   'X-RapidAPI-Host': 'medicine-name-and-details.p.rapidapi.com'
    // },
  );
  // print("response:${response}");
  // final responseJson = jsonDecode(response.body);
  // print('Response body: ${responseJson['results'][0]['active_ingredient']}');
  // final responseJson = jsonDecode(response.body);
  // print(responseJson);
  //  Map<String,dynamic>result=responseJson['results'][0];
  //   print(result['purpose']);
  //    return MedInfoModel(active_ingredient: result['active_ingredient'], purpose: result['purpose'], indications_and_usage: result['indications_and_usage'], warnings: result['warnings'], dosage_and_administration: result['dosage_and_administration'], storage_and_handling: result['storage_and_handling']);
  // return Album.fromJson(responseJson);
  //  return MedInfoModel.fromJson(result!);
    Map<String,dynamic>map=jsonDecode(response.body);
    print(map);
    // MedInfoModel m;
    // if(map['error'])return ;
    final result=map['results'][0];
    print(result);
    // return MedInfoModel.fromJson(map['results'][0]);
    // return MedInfoModel(active_ingredient: result['active_ingredient'], purpose: purpose, indications_and_usage: indications_and_usage, warnings: warnings, dosage_and_administration: dosage_and_administration, storage_and_handling: storage_and_handling)
  // return MedInfoModel(active_ingredient: result['active_ingredient'], purpose: result['purpose'], indications_and_usage: result['indications_and_usage'], warnings: result['warnings'], dosage_and_administration: result['dosage_and_administration'], storage_and_handling: result['storage_and_handling']);
    return MedInfoModel.fromMap(result);
}