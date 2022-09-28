import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webproject/modal/dashboard_bottom_sheet.dart';
import 'package:webproject/modal/dashboard_memberitem.dart';
import 'package:webproject/modal/getcontroller.dart';
import 'package:webproject/modal/memberitem.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:webproject/modal/pdfile.dart';


void main() {
  runApp(new MaterialApp(
      home: new dashboard_memberlist()
  ));
}
class dashboard_memberlist extends StatefulWidget {

  @override
  _dashboard_memberlistState createState() => _dashboard_memberlistState();
}

class _dashboard_memberlistState extends State<dashboard_memberlist> {

  List<dashboard_memberitem> data_details=[];
  List<dashboard_memberitem> member_list=[];
  List<dashboard_memberitem> contain_filter=[];
  bool data_filter=false;
  var filter_value;
  bool state=false;
  FocusScopeNode currentFocus;

  String filter_from_date='';
  int month_rev,month_paid,month_bal,count;
  String month;
  var filter_to_date;
  var filter_type_date;
  final scaffoldState = GlobalKey<ScaffoldState>();
  String gyn_data;
  String name;
  SharedPreferences prefs;
  TextEditingController searchcontroller=TextEditingController();
  final getcontroller c=Get.put(getcontroller());
  bool floating_change=true;


  Future _getData() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'membersMonthRev','branch_id':sharedPreferences.getString("Branch_id")}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    data_details.clear();
     //setState(() {
     //  month_rev=data['month_revenue'];
     //  month_paid=data['month_paid'];
     //  month_bal=data['month_bal'];
     //  month=data['month'];
     //  count=data['count'];
  //  });
    for(var memberdata in dataarray)
    {
      dashboard_memberitem listdata=dashboard_memberitem(memberdata['id'],memberdata['name'],memberdata['join_date'],memberdata['exp_date'],memberdata['balance'],memberdata['contact'],memberdata['total'],memberdata['paid']);
      data_details.add(listdata);
    }
    return data_details;
  }

  Future _gettopdata() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'membersMonthRev','branch_id':sharedPreferences.getString("Branch_id")}
    );
    var data = jsonDecode(response.body);
    setState(() {
    month_rev=data['month_revenue'];
    month_paid=data['month_paid'];
    month_bal=data['month_bal'];
    month=data['month'];
    count=data['count'];
    });
  }

  bottom_open()
  {
    setState(() {
      state=true;
      floating_change=false;
    });
  }
  bottom_close()
  {
    setState(() {
      state=false;
      floating_change=true;
    });
  }

  filter_memberlist()
  {
    List<dashboard_memberitem> _details=[];
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

  Future shareprefs_dec() async {
    prefs=await SharedPreferences.getInstance();
    setState(() {
      gyn_data=prefs.getString("gym_name");
      name=prefs.getString("Login_id");
      print(gyn_data);
    });
  }

  Future<void> createPDF() async
  {
    if(data_details.length!=0)
      {
        PdfDocument document = PdfDocument();
        // final page=document.pages.add();
        PdfGrid grid1=PdfGrid();
        grid1.style=PdfGridStyle(
            font: PdfStandardFont(PdfFontFamily.helvetica,16),
            cellPadding: PdfPaddings(left:5,right:2,top:2,bottom:2)
        );
        PdfGrid grid=PdfGrid();
        grid.style=PdfGridStyle(
            font: PdfStandardFont(PdfFontFamily.helvetica,16),
            cellPadding: PdfPaddings(left:5,right:2,top:2,bottom:2)
        );
        grid.columns.add(count: 6);
        grid.headers.add(1);

        final PdfPageTemplateElement headerTemplate =
        PdfPageTemplateElement(const Rect.fromLTWH(100, 0, 900, 50));
        String head_date='Month report revenue of Memberlist '+month;
//Draw text in the header.
        headerTemplate.graphics.drawString(
          head_date, PdfStandardFont(PdfFontFamily.helvetica, 20),
          // bounds: const Rect.fromLTWH(0, 15, 600, 20)
        );
//Add the header element to the document.
        document.template.top = headerTemplate;


        PdfGridRow header=grid.headers[0];
        header.cells[0].value='id';
        header.cells[1].value='Mem_name';
        header.cells[2].value='Join_date';
        header.cells[3].value='Exp_date';
        header.cells[4].value='Mobile';
        header.cells[5].value='Balance';

        PdfGridRow row=grid.rows.add();
        for(var alldata in data_details)
        {
          row=grid.rows.add();
          row.cells[0].value=alldata.id;
          row.cells[1].value=alldata.name;
          row.cells[2].value=alldata.join_date;
          row.cells[3].value=alldata.exp_date;
          row.cells[4].value=alldata.contact;
          row.cells[5].value=alldata.balance;
        }

        row=grid.rows.add();
        row.cells[0].value='';
        row.cells[1].value='';
        row.cells[2].value='';
        row.cells[3].value='';
        row.cells[4].value='';
        row.cells[5].value='';

        row=grid.rows.add();
        row.cells[0].value='';
        row.cells[1].value='';
        row.cells[2].value='';
        row.cells[3].value='';
        row.cells[4].value='';
        row.cells[5].value='';

        row=grid.rows.add();
        row.cells[0].value='TOTAL';
        row.cells[1].value=month_rev.toString();
        row.cells[4].value='Balance';
        row.cells[5].value=month_bal.toString();
        grid.draw(page:document.pages.add(),bounds:const Rect.fromLTWH(0, 0, 0,0));
        List<int> bytes=document.save();
        document.dispose();
        saveAndlaunchfile(bytes, (gyn_data+'_'+'memberlist'+'_'+month+DateTime.now().toString()+'.pdf').toString());
      }
    else
      {
        Fluttertoast.showToast(
          msg: "Not commission available",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black.withOpacity(0.8),
          fontSize: 14.0,
        );
      }

  }

  Future _getFilterData() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'membersMonthRevfilter','branch_id':sharedPreferences.getString("Branch_id"),'from':filter_from_date}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
      data_details.clear();
       if(data['data']!=null)
         {
          month_rev=data['month_revenue'];
          month_paid=data['month_paid'];
          month_bal=data['month_bal'];
          month=data['month'];
          count=data['count'];
         }
    for(var memberdata in dataarray)
    {
      dashboard_memberitem listdata=dashboard_memberitem(memberdata['id'],memberdata['name'],memberdata['join_date'],memberdata['exp_date'],memberdata['balance'],memberdata['contact'],memberdata['total'],memberdata['paid']);
      data_details.add(listdata);
    }
    c.state_change=RxInt(0);
    return data_details;
  }

  Future _getFilterData_month() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'membersMonthRevfilter','branch_id':sharedPreferences.getString("Branch_id"),'from':filter_from_date}
    );
    var data = jsonDecode(response.body);
    setState(() {
      if(data['data']!=null)
      {
        month_rev=data['month_revenue'];
        month_paid=data['month_paid'];
        month_bal=data['month_bal'];
        month=data['month'];
        count=data['count'];
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shareprefs_dec();
    _gettopdata();
    searchcontroller.addListener(() {
      filter_memberlist();
    });
  }


  @override
  Widget build(BuildContext context) {
    bool issearching=searchcontroller.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Member List',style: TextStyle(fontFamily: 'Oswald'),),
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
      floatingActionButton:floating_change==true? FloatingActionButton(
        onPressed: (){
          // writeOnPdf();
          // await savePdf();
          //CircularProgressIndicator();
          createPDF();
        },
        child: Icon(Icons.save),
      ):null,
      bottomSheet: state==true? dashboard_bottom_sheet(
          title:()
          {
            Fluttertoast.showToast(
              msg: "Select month and year",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.white,
              textColor: Colors.black.withOpacity(0.8),
              fontSize: 14.0,
            );
          },
        close:(){
          setState(() {
            state=false;
            floating_change=true;
          });
        },
        submit:(){
          setState(() {
            data_details.clear();
            state=false;
            data_filter=true;
            filter_from_date=dashboard_bottom_sheet.from_date;
            _getFilterData_month();
            c.state_change=RxInt(1);
            floating_change=true;
            //print(data_details);
          });
        },
      ):null,
      body: Container(
        child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  color: HexColor("#222222"),
                  child: Padding(padding: EdgeInsets.all(15),
                  child: Column(
                    children:<Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap:()=>{
                              //filter_memberlist()
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Revenue for '+month.toString(),
                            style: TextStyle(
                              fontFamily: 'Titilliumweb',
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            count.toString()+' Members',
                            style: TextStyle(
                              fontFamily: 'Titilliumweb',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),

                        ],
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Total: ',
                                  style: TextStyle(
                                    fontFamily: 'Titilliumweb',
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '₹'+month_rev.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Titilliumweb',
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Paid: ',
                                  style: TextStyle(
                                    fontFamily: 'Titilliumweb',
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '₹'+month_paid.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Titilliumweb',
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Bal: ',
                                  style: TextStyle(
                                    fontFamily: 'Titilliumweb',
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '₹'+month_bal.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Titilliumweb',
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                  ),
                ),
                Expanded(
                  child: Container(
                      color: Colors.black,
                      child:FutureBuilder(
                        future:data_filter==true?_getFilterData():_getData(),
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
                            if(data_details.length!=0)
                            {
                              return ListView.builder(itemCount: issearching==true?contain_filter.length:data_details.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (context,index){
                                    dashboard_memberitem member_data=issearching==true?contain_filter[index]:data_details[index];
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
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap:()=>{
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
                                                          SizedBox(height: 5,),
                                                          Padding(padding: EdgeInsets.only(top:15),
                                                            child: Container(
                                                              padding: EdgeInsets.only(top:4,left:10,bottom: 4),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children:<Widget>[
                                                                  Text('Total: ₹'+member_data.total,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 12,color: Colors.white),),
                                                                  Text('Paid: ₹'+member_data.paid,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 12,color: Colors.white),),
                                                                  member_data.balance!="0"?Container(
                                                                    alignment: Alignment.topLeft,
                                                                    padding: EdgeInsets.all(5),
                                                                    decoration: BoxDecoration(
                                                                      color: HexColor("#81791D"),
                                                                      borderRadius: BorderRadius.circular(4),
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
                                                                      borderRadius: BorderRadius.circular(4),
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
                                                            ),
                                                          ),
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


