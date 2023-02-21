// will show the map on user's screen
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' ;
import 'package:med_reminder/screens/home_screen.dart';
import 'package:sizer/sizer.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:geocoder2/geocoder2.dart';
// import 'package:google_maps_webservice/places.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  GoogleMapController? _controller;
  Location _location = Location();
  late StreamSubscription<LocationData> locationSubscription;

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    locationSubscription = _location.onLocationChanged.listen((l) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l!.latitude!, l!.longitude!), zoom: 15),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xf1f4f8),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Med", style: TextStyle(color: Colors.black,
                fontSize: 6.h,
                fontWeight: FontWeight.bold)),
            Text("Alert", style: GoogleFonts.abel(color: Colors.green,
                fontSize: 6.h,
                fontWeight: FontWeight.bold))
          ],
        ), //takes widget as argument and not string that's why Text widget is used
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: _initialcameraposition),
                      mapType: MapType.normal,
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                    ),
                  ],
                ),
              ),
            ]
        ),
      ),
    );
  }
}