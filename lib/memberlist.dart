import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webproject/memberdetails.dart';
import 'package:webproject/modal/bottom_sheet_widget.dart';
import 'package:webproject/modal/getcontroller.dart';
import 'package:webproject/modal/memberitem.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:webproject/modal/pdfile.dart';


void main() {
  runApp(new MaterialApp(
      home: new memberlist_item()
  ));
}

class memberlist_item extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

String gyn_data;
String name;

class HomePageState extends State<memberlist_item> {

  List<memberitem> data_details=[];
  List<memberitem> member_list=[];
  List<memberitem> contain_filter=[];
  var from_datevalue='From';
  var to_datevalue='to';
  bool state=false;
  FocusScopeNode currentFocus;
  bool data_filter=false;
  var filter_value;

  var filter_from_date;
  var filter_to_date;
  var filter_type_date;

  Future<dynamic> future_data;



  final scaffoldState = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController statuscontroller=TextEditingController();
  TextEditingController searchcontroller=TextEditingController();
  final getcontroller c = Get.put(getcontroller());
  SharedPreferences prefs;

  Future shareprefs_dec() async {
    prefs=await SharedPreferences.getInstance();
    setState(() {
      gyn_data=prefs.getString("gym_name");
      name=prefs.getString("Login_id");
      print(gyn_data);
    });
  }



  // writeOnPdf(){
  //   pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4,
  //       margin: pw.EdgeInsets.all(32),
  //       build: (pw.Context context){
  //         return <pw.Widget>[
  //           pw.Header(
  //               level: 0,
  //               child: pw.Text("Memberlist document")
  //           ),
  //           pw.Paragraph(
  //               text:'Sahil kahana fdsfdsf  af sfa'
  //           ),
  //           pw.Paragraph(
  //               text:'Sahil kahana fdsfdsf  af sfa'
  //           ),
  //           pw.Header(
  //               level: 1,
  //               child: pw.Text("Memberlist document 2")
  //           ),
  //           pw.Paragraph(
  //               text:'Sahil kahana fdsfdsf  af sfa'
  //           ),
  //           pw.Paragraph(
  //               text:'Sahil kahana fdsfdsf  af sfa'
  //           ),
  //
  //         ];
  //       }));
  // }
  //
  // Future savePdf() async {
  //   Directory documentDirectory = await getApplicationDocumentsDirectory();
  //   String documentPath = documentDirectory.path;
  //   File receiptFile = File("$documentPath/fitlancefile1.pdf");
  //   receiptFile.writeAsBytesSync(List.from(await pdf.save()));
  //   print("Your file is save");
  // }





  Future _getData() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'members','branch_id':sharedPreferences.getString("Branch_id")}
    );
      var data = jsonDecode(response.body);
      var dataarray=data['data'];
      data_details.clear();
    for(var memberdata in dataarray)
      {
        memberitem listdata=memberitem(memberdata['id'],memberdata['name'],memberdata['join_date'],memberdata['exp_date'],memberdata['balance'],memberdata['contact']);
        data_details.add(listdata);
      }
      return data_details;
  }

  Future _getFilterData() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'membersFilter','branch_id':sharedPreferences.getString("Branch_id"),'from':filter_from_date,'to':filter_to_date,'type':filter_type_date}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    print(dataarray);
    data_details.clear();
    for(var memberdata in dataarray)
    {
      memberitem listdata=memberitem(memberdata['id'],memberdata['name'],memberdata['join_date'],memberdata['exp_date'],memberdata['balance'],memberdata['contact']);
      data_details.add(listdata);
    }
    c.state_change=RxInt(0);
    return data_details;
  }


  bottom_open()
  {
    setState(() {
      state=true;
    });
  }
  bottom_close()
  {
    setState(() {
      state=false;
    });
  }
  filter_memberlist()
  {
    List<memberitem> _details=[];
    _details.addAll(data_details);
    if(searchcontroller.text.isNotEmpty)
    {
      _details.retainWhere((data_details){
        String searchterm=searchcontroller.text.toLowerCase();
        String name=data_details.name.toLowerCase();
        String mobile=data_details.contact.toLowerCase();
        String mem_id=data_details.id.toLowerCase();
        String join_date=data_details.join_date.toLowerCase();
        String exp_date=data_details.exp_date.toLowerCase();
        return name.contains(searchterm) || mobile.contains(searchterm) || mem_id.contains(searchterm) ||mobile.contains(searchterm) ||join_date.contains(searchterm) ||exp_date.contains(searchterm);
      });
      setState(() {
        contain_filter.clear();
        contain_filter=_details;
      });
    }
    else
      {
        if(data_filter==true)
        {
          setState(() {
            _details.clear();
            //_details.addAll(data_details);
          });
        }
        else
        {
          setState(() {
            _details.addAll(data_details);
          });
        }
      }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shareprefs_dec();
    searchcontroller.addListener(() {
      filter_memberlist();
    });
  }

  @override
  Widget build(BuildContext context){
    bool issearching=searchcontroller.text.isNotEmpty;



    return Scaffold(
      appBar: AppBar(
        title: Text('Member List',style: TextStyle(fontFamily: 'Titilliumweb'),),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
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
      bottomSheet: state==true? bottom_sheet_widget(
        title: 'first setup',
        close:(){
          setState(() {
            state=false;
          });
        },
        submit:(){
          setState(() {
            data_details.clear();
            state=false;
            data_filter=true;
            filter_from_date=bottom_sheet_widget.from_date;
            filter_to_date=bottom_sheet_widget.to_date_value;
            filter_type_date=bottom_sheet_widget.type_date_value;
            if(filter_type_date=='joining_date')
            {
              filter_value='joining date';
            }
            else
            {
              filter_value='Expiry date';
            }
            if(filter_from_date==null)
              {
                filter_from_date=DateTime.now().day.toString()+"-"+DateTime.now().month.toString()+"-"+DateTime.now().year.toString();
              }
            if(filter_to_date==null)
            {
              filter_to_date=DateTime.now().day.toString()+"-"+DateTime.now().month.toString()+"-"+DateTime.now().year.toString();
            }
            c.state_change=RxInt(1);
            print(data_details);
          });
        },
      ):null,
      body: Container(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.black,
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap:()=>{
                            filter_memberlist()
                          },
                          child:Container(
                            width: 150,
                            height: 50,
                            child: TextField(
                              controller: searchcontroller,
                              style: TextStyle(color:Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Search..',
                                fillColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                focusedBorder: new OutlineInputBorder(
                                  borderSide: new BorderSide(color:Colors.white,width: 1.0)
                                ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 1.0),
                                  ),
                                prefixIcon: Icon(Icons.search,color:Colors.white,)
                              ),
                            ),
                           // child: Icon(Icons.search,color: Colors.white,),
                          ),
                        ),
                        GestureDetector(
                          onTap: ()=>{
                            currentFocus = FocusScope.of(context),
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus()
                            },
                            bottom_open(),
                        },
                          child:Icon(Icons.filter_list,color: Colors.white,),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    data_filter==false?Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12
                          ),),
                        SizedBox(height: 10,),
                        Text('',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12
                          ),)
                      ],
                    ):Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Filtered by '+filter_value,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12
                          ),),
                        SizedBox(height: 10,),
                        Text('From '+filter_from_date+' to '+filter_to_date,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12
                          ),),
                      ],
                    )
                  ],
                ),
              ),
                Expanded(
                    child: Container(
                        color: Colors.black,
                        child:FutureBuilder(
                          future:data_filter==true?_getFilterData():_getData(),
                          //future: future_data,
                          builder:(context,snapshot)
                          {
                            if(c.state_change.toString()=='1')
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

                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            if(!snapshot.hasData)
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

                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                            }
                            else
                            {
                              if(data_details.length.toString()!="0")
                                {
                                  return ListView.builder(itemCount: issearching==true?contain_filter.length:data_details.length,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemBuilder: (context,index){
                                        memberitem member_data=issearching==true?contain_filter[index]:data_details[index];
                                          return Padding(
                                            padding: EdgeInsets.only(top: 5,bottom: 5,left:5,right: 5),
                                            child:Card(
                                              color: HexColor("#222222"),
                                              shape:RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15.0),
                                              ),
                                              child:Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        alignment: Alignment.topLeft,
                                                        padding: EdgeInsets.only(top:5,left:10,right:10,bottom: 5),
                                                        decoration: BoxDecoration(
                                                          color: HexColor("#666666"),
                                                          borderRadius: BorderRadius.only(topLeft:Radius.circular(15),topRight:Radius.circular(0) ,bottomLeft: Radius.circular(0),bottomRight: Radius.circular(0)),
                                                        ),
                                                        child:Text(
                                                          //    'Member id:'+snapshot.data[index].id,
                                                          'Member id:'+member_data.id,
                                                          //'Member id:',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 35/MediaQuery.of(context).devicePixelRatio,
                                                          ),
                                                        ),
                                                      ),
                                                      member_data.balance!="0"?Container(
                                                        alignment: Alignment.topLeft,
                                                        padding: EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                          color: HexColor("#81791D"),
                                                          borderRadius: BorderRadius.only(topLeft:Radius.circular(0),topRight:Radius.circular(15) ,bottomLeft: Radius.circular(0),bottomRight: Radius.circular(0)),
                                                        ),
                                                        child:Row(
                                                          children: <Widget>[
                                                            Text('Due:',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            Text(//'₹'+snapshot.data[index].balance,
                                                              '₹'+member_data.balance,
                                                              //"member_data",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                      ):Container(
                                                        alignment: Alignment.topLeft,
                                                        padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
                                                        decoration: BoxDecoration(
                                                          color: HexColor("#33552A"),
                                                          borderRadius: BorderRadius.only(topLeft:Radius.circular(0),topRight:Radius.circular(15) ,bottomLeft: Radius.circular(0),bottomRight: Radius.circular(0)),
                                                        ),
                                                        child:Row(
                                                          children: <Widget>[
                                                            Text('No Due',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            Text(//'₹'+snapshot.data[index].balance,
                                                              '',
                                                              //"member_data",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  GestureDetector(
                                                    onTap:()=>{
                                                      currentFocus = FocusScope.of(context),
                                                      if (!currentFocus.hasPrimaryFocus) {
                                                        currentFocus.unfocus()
                                                      },
                                                      Navigator.push(context, MaterialPageRoute(builder: (context) => memberdetails(data:member_data.id)),),
                                                    },
                                                    child: Container(
                                                        child:Padding(padding: EdgeInsets.only(left:7,top:5,bottom:5,right:15),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children:<Widget>[
                                                              Padding(
                                                                padding: EdgeInsets.only(top: 10,left: 5,bottom: 5,right: 10),
                                                                child: Container(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      Row(
                                                                        children: <Widget>[
                                                                          Text(
                                                                            //snapshot.data[index].name,
                                                                            member_data.name,
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 14
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 5,),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children:<Widget> [
                                                                          Row(
                                                                            children: <Widget>[
                                                                              Text('Mob.',
                                                                                style: TextStyle(
                                                                                  color: Colors.white70,
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),
                                                                              Text(member_data.contact,
                                                                                style: TextStyle(
                                                                                  color: Colors.white.withOpacity(0.9),
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),

                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 5,),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: <Widget>[
                                                                          Row(
                                                                            children: <Widget>[
                                                                              Text('Join date:',
                                                                                style: TextStyle(
                                                                                  color: Colors.white70,
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),
                                                                              Text(member_data.join_date,
                                                                                style: TextStyle(
                                                                                  color: Colors.white.withOpacity(0.9),
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),

                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 5,),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: <Widget>[
                                                                          Text('Exp. date:',
                                                                            style: TextStyle(
                                                                              color: Colors.white70,
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                          Text(member_data.exp_date,
                                                                            style: TextStyle(
                                                                              color: Colors.white.withOpacity(0.9),
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),

                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets.only(top:4,left:10,right:10,bottom: 4),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(5),
                                                                    border: Border.all(color:Colors.white,width: 1)
                                                                ),
                                                                child: Text(
                                                                  'See details',style: TextStyle(
                                                                  fontFamily: 'Titilliumweb',
                                                                  color: Colors.white,
                                                                  fontSize: 12,
                                                                ),),
                                                              )
                                                            ],
                                                          ),
                                                        )

                                                    ),
                                                  ),

                                                ],
                                              ),

                                            ),
                                          );
                                      });
                                }
                              else
                                {
                                      return Container(
                                        color: Colors.black,
                                        width: double.infinity,
                                        height: double.infinity,
                                        child:Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children:<Widget>[
                                            Text('No data found',style: TextStyle(color: Colors.white,fontSize: 16),),
                                          ],
                                        ),
                                      );
                                }
                            }
                          },
                        )
                    ),),
            ],
          ),
        ),
      ),
    );

  }
}


