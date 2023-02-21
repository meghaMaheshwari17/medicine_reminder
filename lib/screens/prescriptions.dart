import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/screens/displayPdf.dart';
import 'package:provider/provider.dart';
import 'package:med_reminder/provider/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
class Prescriptions extends StatefulWidget {
  const Prescriptions({Key? key}) : super(key: key);

  @override
  State<Prescriptions> createState() => _PrescriptionsState();
}

class _PrescriptionsState extends State<Prescriptions> {
  List<String>pdfUrls=[];
  List<String>fileNames=[];
  bool exists = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  late PDFViewController _pdfViewController;
  bool loaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFiles();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xf1f4f8),
        elevation: 0,
        iconTheme: IconThemeData(color:Colors.black),
        title:Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Med",style:TextStyle(color:Colors.black,fontSize:4.h,fontWeight: FontWeight.bold)),
            Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:4.h,fontWeight: FontWeight.bold))
          ],
        ), //takes widget as argument and not string that's why Text widget is used
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  bottom: 1.h,
                ),
                child: Text('Prescriptions',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color:Colors.green))),
            SizedBox(height:2.h),
            Text("Upload and View all your prescriptions in one place...",textAlign: TextAlign.center,style: TextStyle(fontSize: 3.h),),
            SizedBox(height:2.h),
            pdfUrls.length>0 ? Expanded(
              child: ListView.builder(
                itemCount: pdfUrls.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: const Icon(Icons.file_present_rounded,color: Colors.green),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,color: Colors.red,),
                        onPressed: () {
                        //  delete from firebase
                          deletePriscription(fileNames[index],pdfUrls[index]);
                        },
                      ),
                      title: Text('${fileNames[index]}'),
                      onTap: () {
                        // final docFile = DefaultCacheManager().getSingleFile(pdfUrls[index]);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  DisplayPdf(urlPrescription: pdfUrls[index])
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ): Container(
               width:80.w,
               margin:EdgeInsets.only(left:10.w,top:10.h),
                child: Center(
                  child: Text("No prescriptions added yet",textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(color:Colors.grey)),
                ),
            ),
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // upload file on pressing this button!
            getPdfAndUpload();
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.upload_file),
        )
    );
  }

  Future<void>deletePriscription(String fileName,String url)async{
  //     delete file from firebase
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String _uid=ap.uid;
    // print("prescription/$_uid/$fileName");
    await ap.deletePdf("prescription/$_uid/$fileName", url);
    setState(() {
      pdfUrls.remove(url);
      fileNames.remove(fileName);
    });
  }

  Future<void> getPdfAndUpload()async{
  //  generate random name of the file
    var rng=new Random();
    // String randomName="";
    // for(var i=0;i<20;i++){
    //   print(rng.nextInt(100));
    //   randomName+=rng.nextInt(100).toString();
    // }
    // String fileName='${randomName}.pdf';
    final result=await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.first.name;

      // Upload file
      saveFile(fileName,file);
      // await FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes);
    }else {
      print("file is null");
    }
  }

  void saveFile(String fileName,File file)async{
    if(file!=null){
      final ap = Provider.of<AuthProvider>(context, listen: false);
      String _uid=ap.uid;
      print("prescription/$_uid/$fileName");
      String newPdf=await ap.savePdf("prescription/$_uid/$fileName", file!); //calling this from authProvider method
      // getFiles();
      setState(() {
        pdfUrls.add(newPdf);
        fileNames.add(fileName);
      });

    }else {
      print("file null");
    }
  }

  void getFiles()async{
    final ap = Provider.of<AuthProvider>(context, listen: false);
    // List<String>pdfs=await ap.getPdfs();
    ListResult listResult=await ap.getPdfs();
    final pdfs = await Future.wait(
        listResult.items.map((pdfRef){
          print(pdfRef.getDownloadURL());
          return pdfRef.getDownloadURL();
        })
    );
    for(var item in listResult.items){
      print(item.fullPath);
      String temp=item.fullPath;
      String name="";
      for(int i=temp.length-1;i>=0;i--){
        if(temp[i]=='/')break;
        name+=temp[i];
      }
      name= name.split('').reversed.join('');
      setState(() {
        fileNames.add(name);
      });
    }
    setState(() {
      pdfUrls=pdfs;
    });
  }


}
