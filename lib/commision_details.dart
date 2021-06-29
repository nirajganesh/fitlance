import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main()
{
  runApp(new MaterialApp(
    home: new commision_details(),
  ));
}


class commision_details extends StatefulWidget {
  final String data;
  const commision_details({Key key,this.data}) : super(key: key);


  @override
  _commision_detailsState createState() => _commision_detailsState();
}



class _commision_detailsState extends State<commision_details> {

  String gyn_data;
  String name;
  TextEditingController searchcontroller=TextEditingController();
  SharedPreferences prefs;
  String pt_id='',total='',percent='',paid='',invoice='',pay_date='',mem_name='',mem_id='',session_name='',from='',to='',pt_name='';


  Future loadmembership_plan(String record) async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'commissionDetail','branch_id':sharedPreferences.getString("Branch_id"),'id':record}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    print(dataarray);
    for(var memberdata in dataarray)
    {
      setState(() {
        mem_id=memberdata['mem_id'];
        pt_name=memberdata['pt_name'];
        pt_id=memberdata['pt_id'];
        mem_name=memberdata['mem_name'];
        session_name=memberdata['sess_name'];
        from=memberdata['sess_from'];
        to=memberdata['sess_to'];
        total=memberdata['total'];
        percent=memberdata['percent'];
        paid=memberdata['paid'];
        invoice=memberdata['invoice'];
        pay_date=memberdata['pay_date'];
      });
    }
  }

  Future shareprefs_dec() async {
    prefs=await SharedPreferences.getInstance();
    setState(() {
      gyn_data=prefs.getString("gym_name");
      name=prefs.getString("Login_id");
      print(gyn_data);
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shareprefs_dec();
    loadmembership_plan(widget.data);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commission Details',style: TextStyle(fontFamily: 'Titilliumweb'),),
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
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            SizedBox(height: 5,),
            Padding(padding: EdgeInsets.only(left: 20,right: 10),
              child:Container(
                child: Row(
                  children: <Widget>[
                    Text('Commission details of: ',style: TextStyle(fontFamily: 'Oswald',fontSize: 18,color: Colors.white.withOpacity(0.7)),),
                    Text(pt_name,style: TextStyle(fontFamily: 'Oswald',fontSize: 18,color: Colors.white),)
                  ],
                ),
              ),
            ),
            SizedBox(height: 5,),
            Padding(padding: EdgeInsets.all(15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: HexColor("#222222"),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Total: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                        Text('₹'+total,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Percent: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                        Text('%'+percent,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Paid: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                        Text('₹'+paid,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                      ],
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Invoice no. ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                        Text(invoice,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Date: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                        Text(pay_date,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                      ],
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        mem_name!=null?Row(
                          children: [
                            Text('Mem. name: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                            Text(mem_name,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                          ],
                        ):Row(
                          children: [
                            Text('No member name: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        mem_id!=null?Row(
                          children: [
                            Text('Mem. id: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                            Text(mem_id,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                          ],
                        ):Row(
                          children: [
                            Text('No member id: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 15,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        session_name!=null?Row(
                          children: [
                            Text('Session name: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                            Text(session_name,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                          ],
                        ):Row(
                          children: [
                            Text('No session name',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                          ],
                        )
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        from!=null?Row(
                          children: [
                            Text('From: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                            Text(from,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                          ],
                        ):Row(
                          children: [
                            Text('Session from:null',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                          ],
                        )
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        to!=null?Row(
                          children: [
                            Text('To: ',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                            Text(to,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white),)
                          ],
                        ):Row(
                          children: [
                            Text('Session to:null',style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 14,color: Colors.white.withOpacity(0.7)),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
