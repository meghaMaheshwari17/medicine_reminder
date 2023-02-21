import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
class SuccessScreen extends StatefulWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(milliseconds: 2200),(){
      // Navigator.popUntil(context, ModalRoute.withName('/home'));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen()),
              (route) => false);
      setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
       // color:Colors.green,
      child:Center(
         child:FlareActor("assets/check.flr",
         fit:BoxFit.contain,
         animation: 'Untitled',
           alignment: Alignment.center,
         )
      )
    );
  }
}
