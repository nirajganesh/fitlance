import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webproject/admin_login.dart';
import 'package:webproject/commision.dart';
import 'package:webproject/dashboard_commission.dart';
import 'package:webproject/dashboard_expenses.dart';
import 'package:webproject/dashboard_memberlist.dart';
import 'package:webproject/dashboard_personal_trainer.dart';
import 'package:webproject/expances.dart';
import 'package:webproject/memberlist.dart';
import 'package:webproject/personal_trainer.dart';
import 'package:webproject/select_gym.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

String gyn_data;
String name;

class _HomeState extends State<Home> {
  SharedPreferences prefs;
  String valuechoose;
  List listitem=["Joining date","Expiry date"];
  int month_revenue,month_paid,month_balance,month_revenue_pt,month_paid_pt,month_balance_pt,
     month_commision,month_expances;
  String month_join_mem,month_trainer_assign,date;
  static const _url = 'http://digikraftsocial.com';



  Future<Null> refreshlist() async{
    await Future.delayed(Duration(seconds: 3));
  }

  Future shareprefs_dec() async {
    prefs=await SharedPreferences.getInstance();
    setState(() {
      gyn_data=prefs.getString("gym_name");
      name=prefs.getString("Login_id");
      print(gyn_data);
    });
  }

  void dashboard_data() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'dashboard','branch_id':sharedPreferences.getString("Branch_id")}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    print(dataarray);
    print(dataarray['month_revenue']);
      setState(() {
        month_revenue=dataarray['month_revenue'];
        month_balance=dataarray['month_bal'];
        month_paid=dataarray['month_paid'];
        month_revenue_pt=dataarray['month_revenue_pt'];
        month_paid_pt=dataarray['month_paid_pt'];
        month_balance_pt=dataarray['month_bal_pt'];
        month_commision=dataarray['comission_paid'];
        month_expances=dataarray['expenses'];
        month_join_mem=dataarray['month_joining_mem'];
        month_trainer_assign=dataarray['month_joining_pt'];
        date=dataarray['date'];
       });
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    shareprefs_dec();
    dashboard_data();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard',style: TextStyle(fontFamily:'Oswald')),
        backgroundColor: HexColor("#222222"),
        foregroundColor: Colors.black,
        actions: [
          GestureDetector(
            onTap: ()=>{
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>
                  select_gym(data: "yes",gym:gyn_data,)))
            },
            child: Container(
              width: 130,
              height: 10,
              padding: EdgeInsets.only(top:15,bottom:10,right:15,left:10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white,width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child:Text('Change Gym',style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child:Container(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children:<Widget> [
                  Container(
                    height: 90,
                    child: DrawerHeader(
                      child: gyn_data=="Aim fitness"? Image.asset('images/aim_fitness_logo.png',height: 100.0,)
                          :Image.asset('images/strong_room_logo.png',height: 100.0,),
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Dashboard',
                      style: TextStyle(fontFamily:'Titilliumweb',fontSize: 18.0, color: Colors.black),
                    ),
                    leading: Icon(
                      Icons.dashboard,
                      size: 20.0,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Member List',
                      style: TextStyle(fontFamily:'Titilliumweb',fontSize: 18.0, color: Colors.black),
                    ),
                    leading: Icon(
                      Icons.supervised_user_circle,
                      size: 20.0,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => memberlist_item()),);
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Personal Trainer',
                      style: TextStyle(fontFamily:'Titilliumweb',fontSize: 18.0, color: Colors.black),
                    ),
                    leading: Icon(
                      Icons.fitness_center,
                      size: 20.0,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => personal_trainer()),);
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Expenses',
                      style: TextStyle(fontFamily:'Titilliumweb',fontSize: 18.0, color: Colors.black),
                    ),
                    leading: Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => expances()),);
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Commission',
                      style: TextStyle(fontFamily:'Titilliumweb',fontSize: 18.0, color: Colors.black),
                    ),
                    leading: Icon(
                      Icons.low_priority,
                      size: 20.0,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => commision()),);
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Log out',
                      style: TextStyle(fontFamily:'Titilliumweb',fontSize: 18.0, color: Colors.red),
                    ),
                    leading: Icon(
                      Icons.logout,
                      size: 20.0,
                      color: Colors.red,
                    ),
                    onTap: () {
                      prefs.remove('Login_id');
                      prefs.remove('Branch_id');
                      prefs.remove('gym_name');
                      prefs.remove('Password');
                      prefs.remove('Name');
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) =>
                          admin_login()), (Route<dynamic> route) => false);
                    },
                  ),
                ],

              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 80,
                            color: Colors.black,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('images/fitlance_logo.png',height:25,),
                                  ],
                                ),
                                SizedBox(height: 8,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Powered by:   ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Titilliumweb',
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: ()=>{
                                        _launchInBrowser(_url)
                                      },
                                      child: Text(
                                        'DigiKraft Social',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Titilliumweb',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    )

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )


        ),

      ),
      body:RefreshIndicator(
        onRefresh: refreshlist,child:SingleChildScrollView(
        //       physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
          color: Colors.black,
          child: Column(
            children:<Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                alignment: Alignment.topLeft,
                color: HexColor("#222222"),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                         // 'Hello $name',
                          'Hello Admin',
                          style: TextStyle(
                            fontFamily: 'Tittliumweb_bold',
                            color: HexColor("#cccccc"),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              'Welcome to ',
                              style: TextStyle(
                                fontFamily: 'Tittliumweb',
                                color: HexColor("#aaaaaa"),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$gyn_data',
                              style: TextStyle(
                                fontFamily: 'Tittliumweb_bold',
                                color: HexColor("#cccccc"),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),

                      ],
                    ),
                    gyn_data=="Aim fitness" ? Image.asset('images/aim_fitness_logo.png',height: 40,)
                        :Image.asset('images/strong_room_logo.png',height: 40,),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: ()=>{
                  Navigator.push(context, MaterialPageRoute(builder: (context) => dashboard_memberlist()),),
                },
                child:Container(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  alignment: Alignment.topLeft,
                  child:Card(
                    color: HexColor("#33552A"),
                    child:Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'For membership:',
                                style: TextStyle(
                                  fontFamily: 'Titilliumweb',
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Icon(Icons.arrow_forward,color: Colors.white,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Revenue for '+date.toString(),
                                style: TextStyle(
                                  fontFamily: 'Titilliumweb',
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    '₹'+month_revenue.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Oswald_bold',
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Divider(color: Colors.white,height: 2,),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:<Widget> [
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Paid:',
                                    style: TextStyle(
                                      fontFamily: 'Titilliumweb',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' ₹'+month_paid.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Oswald_bold',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Balance: ',
                                    style: TextStyle(
                                      fontFamily: 'Titilliumweb',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹'+month_balance.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Oswald_bold',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: ()=>{
                  Navigator.push(context, MaterialPageRoute(builder: (context) => dashboard_personal_trainer()),),
                },
                child:Container(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  alignment: Alignment.topLeft,
                  child:Card(
                    color: HexColor("#33552A"),
                    child:Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'For trainer:',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Icon(Icons.arrow_forward,color: Colors.white,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Revenue for '+date.toString(),
                                style: TextStyle(
                                  fontFamily: 'Titilliumweb',
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    ' ₹'+month_revenue_pt.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Oswald_bold',
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Divider(color: Colors.white,height: 2,),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:<Widget> [
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Paid:',
                                    style: TextStyle(
                                      fontFamily: 'Titilliumweb',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' ₹'+month_paid_pt.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Oswald_bold',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Balance:',
                                    style: TextStyle(
                                      fontFamily: 'Titilliumweb',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' ₹'+month_balance_pt.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Oswald_bold',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: ()=>{
                  Navigator.push(context, MaterialPageRoute(builder: (context) => dashboard_commission()),),
                },
                child:Container(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  alignment: Alignment.topLeft,
                  child:Card(
                    color: HexColor("#81791D"),
                    child:Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Paid to trainer:',
                                style: TextStyle(
                                  fontFamily: 'Titilliumweb',
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Icon(Icons.arrow_forward,color: Colors.white,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Commission for '+date.toString(),
                                style: TextStyle(
                                  fontFamily: 'Titilliumweb',
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    ' ₹'+month_commision.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Oswald_bold',
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: ()=>{
                  Navigator.push(context, MaterialPageRoute(builder: (context) => dashboard_expenses()),),
                },
                child:Container(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  alignment: Alignment.topLeft,
                  child:Card(
                    color: HexColor("#81791D"),
                    child:Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Monthly expenses:',
                                style: TextStyle(
                                  fontFamily: 'Titilliumweb',
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Icon(Icons.arrow_forward,color: Colors.white,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Revenue for '+date.toString(),
                                style: TextStyle(
                                  fontFamily: 'Titilliumweb',
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    ' ₹'+month_expances.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Oswald_bold',
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:<Widget> [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white,width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            month_join_mem.toString(),
                            style: TextStyle(
                              fontFamily: 'Titilliumweb',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 10,),
                          Text(
                            'Members joined in '+date.toString(),
                            style: TextStyle(
                              fontFamily: 'Titilliumweb',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white,width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            month_trainer_assign.toString(),
                            style: TextStyle(
                              fontFamily: 'Titilliumweb',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 10,),
                          Text(
                            'Trainer assigned in '+date.toString(),
                            style: TextStyle(
                              fontFamily: 'Titilliumweb',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}




