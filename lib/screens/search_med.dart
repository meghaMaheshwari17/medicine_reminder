
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchQueryController =
  TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void _submitSearchQuery() async {
    String searchQuery = _searchQueryController.text;
    List<Map<String, dynamic>> results = await search(searchQuery);
    setState(() {
      _searchResults = results;
    });
  }
  Future<List<Map<String, dynamic>>> search(String query) async {
    String apiKey = "******";
    String searchEngineId = "****";
    String apiUrl = "https://www.googleapis.com/customsearch/v1";
    String queryString = "?q=$query&cx=$searchEngineId&key=$apiKey";

    final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$searchEngineId&q=$query');

    final response = await http.get(url);

     if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print(json);
      final items = json['items'] as List;
      return items
          .map((item) => {
        'title': item['title'],
        'snippet': item['snippet'],
        'url': item['link'],
      })
          .toList();
    } else {
      throw Exception('Failed to load search results');
    }
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
            Text("Med",style:TextStyle(color:Colors.black,fontSize:3.h,fontWeight: FontWeight.bold)),
            Text("Alert",style:GoogleFonts.abel(color:Colors.green,fontSize:3.h,fontWeight: FontWeight.bold))
          ],
        ),
      ),
      body:  Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    bottom: 1.h,
                  ),
                  child: Text('Search Page',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color:Colors.green))),
              Text("Want to learn about a drug? search it",textAlign: TextAlign.center,),
              SizedBox(height:2.h),
              TextField(
                controller: _searchQueryController,
                decoration: const InputDecoration(
                  labelText: 'Enter something... e.g Paracetamol',
                  labelStyle: TextStyle(color:Colors.green)
                ),
              ),
              SizedBox(height: 16.0),
              // Expanded(
              //   child:
                ElevatedButton(
                  onPressed: (){
                    if(_searchQueryController.text.length==0){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Enter a name!"),
                        backgroundColor: Colors.red,
                        duration: Duration(milliseconds: 2000),
                      ));
                      return;
                    }
             _submitSearchQuery();
                 },
                    child: Text('Search'),
                    style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.green,
                     )
                ),
              // ),
              SizedBox(height: 16.0),
              Expanded(child: Result(searchResults: _searchResults)),
            ]
          ),
      ),
    );
  }
}


class Result extends StatelessWidget {
  const Result({Key? key, required this.searchResults}) : super(key: key);
  final searchResults;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> result = searchResults[index];
          return Card(
            elevation: 6,
            child: ListTile(
              title: Text(result["title"]),
              selectedColor: Colors.green,
              subtitle: Text(result["snippet"]),
              onTap: () => launchUrl(Uri.parse(result["url"])),
            ),
          );
        });
  }
}


