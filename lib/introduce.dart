import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntroducePage extends StatefulWidget {
  const IntroducePage({super.key});

  @override
  State<IntroducePage> createState() => _IntroducePageState();
}

class _IntroducePageState extends State<IntroducePage> {
  List<String> goodImageList=["good1.png","good2.png","good3.png","good4.png","good5.png"];
  List<String> badImageList =["bad1.png","bad2.png","bad3.png","bad4.png","bad5.png","bad6.png","bad7.png"];
  Future<void> jsonDe()async{
    final r = await rootBundle.loadString("data.json");
    final data = jsonDecode(r);
    final d = await JsonData.fromJson(data);
  }
  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(10),child: Center(
        child: Column(
          children: [
            Row(
              children: [

              ],
            )
          ],
        ),
      ),),
    );
  }
}
class JsonData{
  final String name;
  final String content;
  JsonData({required this.name,required this.content});
  factory JsonData.fromJson(Map<String,dynamic> json){
    return JsonData(name: json['name'], content: json['content']);
  }
}
