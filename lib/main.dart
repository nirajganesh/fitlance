import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webproject/admin_login.dart';
import 'package:webproject/home.dart';
import 'package:webproject/login.dart';
import 'package:webproject/select_gym.dart';


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Fitlance',
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var branch_id;
  var gym_name;

  @override
  void initState(){
    super.initState();
    // Timer(Duration(seconds: 4),()=> Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) =>
    //     Home()), (Route<dynamic> route) => false));
    getSharedPrefs(branch_id,gym_name,context);
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        color: Colors.black,
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: <Widget>[
           Image.asset('images/fitlance_logo.png',height: 70.0,),
           SizedBox(height: 10,),
           SpinKitChasingDots(
             color: HexColor("#F15C29"),
             size: 40.0,
           )
         ],
       ),
      ),
    );
  }
}

Future<Null> getSharedPrefs(var branch_id,var gym_name,BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  branch_id=prefs.getString("Branch_id");
  gym_name=prefs.getString("gym_name");
  if(branch_id==null)
  {
    Timer(Duration(seconds: 4),()=> Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) =>
        admin_login()), (Route<dynamic> route) => false));
  }
  else
  {
    if(gym_name==null)
    {
      Timer(Duration(seconds: 4), ()=> Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) =>
          select_gym(data: "no",gym:"no")), (Route<dynamic> route) => false));
    }
    else
    {
      Timer(Duration(seconds: 4), ()=> Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) =>
          Home()), (Route<dynamic> route) => false));
    }
  }
}




