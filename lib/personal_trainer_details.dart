
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webproject/modal/expances_item.dart';
import 'package:webproject/modal/member_details_trainer.dart';
import 'package:webproject/modal/member_plan.dart';
import 'package:webproject/modal/memberitem.dart';
import 'package:webproject/modal/personal_trainer_item.dart';

void main()
{
  runApp(new MaterialApp(
    home: new personal_trainer_details(),
  ));
}
class personal_trainer_details extends StatefulWidget {
  final String data;
  const personal_trainer_details({Key key,this.data}) : super(key: key);

  @override
  _personal_trainer_detailsState createState() => _personal_trainer_detailsState();
}

class _personal_trainer_detailsState extends State<personal_trainer_details> {

  List<member_plan> memberplan_list=[];
  List mem_detail_list=[];
  String id='',name='',contact='',address='',gender='',workout_time='',join_date='';
  List<member_details_trainer> trainer_list=[];
  var due_cal;
  SharedPreferences prefs;
  String gyn_data,gym_name;

  Future loadmembership_plan(String record) async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'memberDetails','branch_id':sharedPreferences.getString("Branch_id"),'id':record}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    print(dataarray);
    for(var memberdata in dataarray['mem_details'])
    {
      setState(() {
        memberplan_list.clear();
        id=memberdata['id'];
        name=memberdata['name'];
        contact=memberdata['contact'];
        address=memberdata['address'];
        gender=memberdata['gender'];
        workout_time=memberdata['workout_time'];
        join_date=memberdata['join_date'];
      });
    }
  }

  Future shareprefs_dec() async {
    prefs=await SharedPreferences.getInstance();
    setState(() {
      gyn_data=prefs.getString("gym_name");
      gym_name=prefs.getString("Login_id");
    });
  }

  Future member_trainer_details(String record) async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'memberDetails','branch_id':sharedPreferences.getString("Branch_id"),'id':record}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    setState(() {
      trainer_list.clear();
    });
    for(var plans in dataarray['trainer'])
    {
      member_details_trainer trainer=member_details_trainer(plans['name'],plans['id'],plans['plan_name'],plans['plan_time'],plans['join_date'],plans['exp_date'],plans['total'],plans['paid']);
      trainer_list.add(trainer);
    }
    return trainer_list;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadmembership_plan(widget.data);
    shareprefs_dec();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Member Details',style: TextStyle(fontFamily: 'Titilliumweb'),),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
        backgroundColor: HexColor("#222222"),
        actions: [
          Container(
            padding: EdgeInsets.all(10),
            child: Container(
              child: gyn_data=="Aim fitness"?Image.asset('images/aim_fitness_logo.png',height: 50.0,):Image.asset('images/strong_room_logo.png',height: 50.0,),
            ),
          ),
        ],
      ),
      body:  Container(
          color: Colors.black,
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 10,top: 10),
                child: Row(
                  children: <Widget>[
                    Text('Member details of: ',
                      style: TextStyle(color:Colors.white.withOpacity(0.7),fontSize:16,fontFamily: 'Titilliumweb'),),
                    Text(name.toString(),
                      style: TextStyle(color:Colors.white.withOpacity(0.7),fontSize:16,fontFamily: 'Titilliumweb'),),
                  ],
                ),),
              SizedBox(height: 5,),
              Card(
                color: HexColor("#222222"),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: HexColor("#666666"),
                            borderRadius: BorderRadius.only(topLeft:Radius.circular(7),topRight:Radius.circular(0) ,bottomLeft: Radius.circular(0),bottomRight: Radius.circular(0)),
                          ),
                          child:Text(
                            'Member id:'+id.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Titilliumweb'
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(5),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children:<Widget>[
                                    Text('Mob: ',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                    Text(contact.toString(),style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                  ],
                                ),
                                Row(
                                  children:<Widget>[
                                    Text('Gender: ',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                    Text(gender.toString(),style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                  ],
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text('Worktime: ',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                Text(workout_time!=null? workout_time:'null',style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text('Address: ',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                Text(address.toString(),style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                              ],
                            )
                          ],
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Padding(padding: EdgeInsets.only(left: 10,top: 10),
                child:  Row(
                  children: <Widget>[
                    Text('Personal trainer details of: ',
                      style: TextStyle(color:Colors.white.withOpacity(0.7),fontSize:16,fontFamily: 'Titilliumweb'),),
                    Text('',
                      style: TextStyle(color:Colors.white,fontSize:16),),
                  ],
                ),),
              SizedBox(height: 10,),
              Expanded(child:
              Container(
                child: FutureBuilder(
                  future: member_trainer_details(widget.data),
                  builder: (context,snapshot)
                  {
                    if(snapshot.data==null)
                    {
                      return Container(
                        child: Center(
                          child:Shimmer.fromColors(baseColor: HexColor("#222222"), highlightColor: Color(
                              0xff343436),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child:Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          child:Column(
                                            children: <Widget>[
                                              Row(
                                                children:<Widget> [
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children:<Widget> [
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children:<Widget> [
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children:<Widget> [
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
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
                                  Container(
                                    child:Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          child:Column(
                                            children: <Widget>[
                                              Row(
                                                children:<Widget> [
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children:<Widget> [
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children:<Widget> [
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children:<Widget> [
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 50,
                                                    height: 10,
                                                    alignment: Alignment.topLeft,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                    ),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    else{
                      return ListView.builder(itemCount:snapshot.data.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder:(context,index)
                          {
                            return new Card(
                              color: HexColor("#222222"),
                              child: Column(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children:<Widget>[
                                                  Text('',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                                  Text(snapshot.data[index].name,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                                ],
                                              ),

                                            ],
                                          ),
                                          SizedBox(height: 1,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children:<Widget>[
                                                  Text('Plan name: ',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                                  Text(snapshot.data[index].plan_name,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                                ],
                                              ),
                                              Row(
                                                children:<Widget>[
                                                  Text('Join date: ',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                                  Text(snapshot.data[index].join_date,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text('Plan time: ',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                                  Text(snapshot.data[index].plan_time,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                                ],
                                              ),
                                              Row(
                                                children:<Widget>[
                                                  Text('Exp date: ',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                                  Text(snapshot.data[index].exp_date,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                                ],
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text('Total: ₹',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                              Text(snapshot.data[index].total,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text('Paid: ₹',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                              Text(snapshot.data[index].paid,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              int.parse(snapshot.data[index].total)-int.parse(snapshot.data[index].paid)==0?Row(
                                                children: <Widget>[
                                                  Container(
                                                    alignment: Alignment.topLeft,
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: HexColor("#33552A"),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child:  Text('No Due ',style: TextStyle(color: Colors.white70,fontSize: 14,fontFamily: 'Titilliumweb'),),
                                                  ),
                                                ],
                                              ):Row(
                                                children: <Widget>[
                                                  Container(
                                                      alignment: Alignment.topLeft,
                                                      padding: EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        color: HexColor("#81791D"),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text('Due: ₹'+(int.parse(snapshot.data[index].total)-int.parse(snapshot.data[index].paid)).toString(),style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Titilliumweb'),)
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),

                                        ],
                                      )
                                  ),
                                ],
                              ),
                            );
                          });
                    }
                  },
                ),
              ),),
            ],
          ),
        ),
    );
  }
}
