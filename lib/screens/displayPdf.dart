import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
class DisplayPdf extends StatefulWidget {
  const DisplayPdf({Key? key, required this.urlPrescription}) : super(key: key);
  final urlPrescription;
  @override
  State<DisplayPdf> createState() => _DisplayPdfState();
}

class _DisplayPdfState extends State<DisplayPdf> {
  String urlPDFPath = "";
  bool exists = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  late PDFViewController _pdfViewController;
  bool loaded = false;

  Future<File> getFileFromUrl(String url, {name}) async {
    var fileName = 'testonline';
    if (name != null) {
      fileName = name;
    }
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" + fileName + ".pdf");
      print(dir.path);
      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  void requestPersmission() async {
     // await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    await Permission.storage;
  }

  @override
  void initState() {
    requestPersmission();
    getFileFromUrl(widget.urlPrescription).then(
          (value) => {
        setState(() {
          if (value != null) {
            urlPDFPath = value.path;
            loaded = true;
            exists = true;
          } else {
            exists = false;
          }
        })
      },
    );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print(urlPDFPath);
    if (loaded) {
      return Scaffold(
        body: PDFView(
          filePath: urlPDFPath,
          autoSpacing: true,
          enableSwipe: true,
          pageSnap: true,
          swipeHorizontal: true,
          nightMode: false,
          onError: (e) {
            //Show some error message or UI
          },
          onRender: (_pages) {
            setState(() {
              _totalPages = _pages!;
              pdfReady = true;
            });
          },
          onViewCreated: (PDFViewController vc) {
            setState(() {
              _pdfViewController = vc;
            });
          },
          onPageChanged: (int ?page, int ?total) {
            setState(() {
              _currentPage = page!;
            });
          },
          onPageError: (page, e) {},
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.chevron_left),
              iconSize: 50,
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (_currentPage > 0) {
                    _currentPage--;
                    _pdfViewController.setPage(_currentPage);
                  }
                });
              },
            ),
            Text(
              "${_currentPage + 1}/$_totalPages",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              iconSize: 50,
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (_currentPage < _totalPages - 1) {
                    _currentPage++;
                    _pdfViewController.setPage(_currentPage);
                  }
                });
              },
            ),
          ],
        ),
      );
    } else {
      if (exists) {
        //Replace with your loading UI
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xf1f4f8),
            elevation: 0,
            iconTheme: IconThemeData(color:Colors.black),
            title:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Med",style:TextStyle(color:Colors.black,fontSize:4.h,fontWeight: FontWeight.bold)),
                Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:4.h,fontWeight: FontWeight.bold))
              ],
            ),
          ),
          body: Center(
            child: Text(
              "Loading..",
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      } else {
        //Replace Error UI
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xf1f4f8),
            elevation: 0,
            iconTheme: IconThemeData(color:Colors.black),
            title:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Med",style:TextStyle(color:Colors.black,fontSize:4.h,fontWeight: FontWeight.bold)),
                Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:4.h,fontWeight: FontWeight.bold))
              ],
            ),
          ),
          body: Text(
            "PDF Not Available",
            style: TextStyle(fontSize: 20),
          ),
        );
      }
    }
  }
}


