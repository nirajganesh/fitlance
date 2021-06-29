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
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:webproject/modal/bottom_sheet_widget_commission.dart';
import 'package:webproject/modal/commision_item.dart';
import 'package:webproject/modal/dashboard_bottom_sheet.dart';
import 'package:webproject/modal/getcontroller.dart';
import 'package:webproject/modal/memberitem.dart';

import 'modal/pdfile.dart';

class dashboard_commission extends StatefulWidget {

  @override
  _dashboard_commissionState createState() => _dashboard_commissionState();
}

class _dashboard_commissionState extends State<dashboard_commission> {

  List<commision_item> data_details3=[];
  List<commision_item> member_list3=[];
  List<commision_item> contain_filter=[];
  DateTime selectedDate = DateTime.now();
  bool state=false;
  String gyn_data;
  String name;
  TextEditingController searchcontroller=TextEditingController();
  SharedPreferences prefs;

  FocusScopeNode currentFocus;
  bool data_filter=false;

  var filter_from_date;
  var filter_to_date;
  var filter_type_date;

  int total,count;
  String month='';

  final scaffoldState = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final getcontroller c=Get.put(getcontroller());
  bool floationg_change=true;

  Future _getData() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'commissionMonth','branch_id':sharedPreferences.getString("Branch_id")}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    data_details3.clear();
    //setState(() {
      if(data['data']!=null)
        {
          total=data['total_comission'];
          count=data['count'];
          month=data['month'];
        }
   // });
    for(var memberdata in dataarray)
    {
      commision_item listdata=commision_item(memberdata['id'],memberdata['pt_id'],memberdata['pt_name'],memberdata['paid'],memberdata['pay_date'],memberdata['mem_name']);
      data_details3.add(listdata);
    }
    return data_details3;
  }


  Future _getData_month() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'commissionMonth','branch_id':sharedPreferences.getString("Branch_id")}
    );
    var data = jsonDecode(response.body);
    setState(() {
      if(data['data']!=null)
      {
        total=data['total_comission'];
        count=data['count'];
        month=data['month'];
      }
    });
  }



  Future _getFilterData() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'commissionMonthfilter','branch_id':sharedPreferences.getString("Branch_id"),'from':filter_from_date}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    print(filter_from_date);
   // setState(() {
      data_details3.clear();
      if(data['data']!=null)
      {
        total=data['total_comission'];
        count=data['count'];
        month=data['month'];
      }
  //  });
    for(var memberdata in dataarray)
    {
      commision_item listdata=commision_item(memberdata['id'],memberdata['pt_id'],memberdata['pt_name'],memberdata['paid'],memberdata['pay_date'],memberdata['mem_name']);
      data_details3.add(listdata);
    }
    c.state_change=RxInt(0);
    return data_details3;
  }

  Future _getFilterData_month() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'commissionMonthfilter','branch_id':sharedPreferences.getString("Branch_id"),'from':filter_from_date}
    );
    var data = jsonDecode(response.body);
    print(filter_from_date);
     setState(() {
    if(data['data']!=null)
    {
      total=data['total_comission'];
      count=data['count'];
      month=data['month'];
    }
      });
  }

  Future shareprefs_dec() async {
    prefs=await SharedPreferences.getInstance();
    setState(() {
      gyn_data=prefs.getString("gym_name");
      name=prefs.getString("Login_id");
      print(gyn_data);
    });
  }

  bottom_open()
  {
    setState(() {
      state=true;
      floationg_change=false;
    });
  }
  bottom_close()
  {
    setState(() {
      state=false;
      floationg_change=true;
    });
  }

  Future<void> createPDF() async
  {
    if(data_details3.length!=0)
      {
        Fluttertoast.showToast(
          msg: "Please wait..",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black.withOpacity(0.8),
          fontSize: 14.0,
        );

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
        grid.headers.add(2);

        final PdfPageTemplateElement headerTemplate =
        PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50));
//Draw text in the header.
        headerTemplate.graphics.drawString(
          'Month report revenue of Memberlist June-2021', PdfStandardFont(PdfFontFamily.helvetica, 12),
          // bounds: const Rect.fromLTWH(0, 15, 200, 20)
        );
//Add the header element to the document.
        document.template.top = headerTemplate;

        PdfGridRow header=grid.headers[0];
        header.cells[0].value='id';
        header.cells[1].value='Pt_name';
        header.cells[2].value='Mem_name';
        header.cells[3].value='Pay_date';
        header.cells[4].value='Paid';

        PdfGridRow row=grid.rows.add();
        for(var alldata in data_details3)
        {
          row=grid.rows.add();
          row.cells[0].value=alldata.pt_id;
          row.cells[1].value=alldata.pt_name;
          row.cells[2].value=alldata.name;
          row.cells[3].value=alldata.pay_date;
          row.cells[4].value=alldata.paid;
        }

        row=grid.rows.add();
        row.cells[0].value='';
        row.cells[1].value='';
        row.cells[2].value='';
        row.cells[3].value='';
        row.cells[4].value='';


        row=grid.rows.add();
        row.cells[0].value='';
        row.cells[1].value='';
        row.cells[2].value='';
        row.cells[3].value='';
        row.cells[4].value='';


        row=grid.rows.add();
        row.cells[0].value='TOTAL';
        row.cells[1].value=total.toString();
        row.cells[4].value='Balance';
        row.cells[5].value=month.toString();
        grid.draw(page:document.pages.add(),bounds:const Rect.fromLTWH(0, 0, 0,0));
        List<int> bytes=document.save();
        document.dispose();
        saveAndlaunchfile(bytes, (DateTime.now().toString()+'_'+gyn_data+'_'+'commission'+'_'+month+'.pdf').toString());
        print("File saved");
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

  filter_memberlist()
  {
    List<commision_item> _details=[];
    _details.addAll(data_details3);
    if(searchcontroller.text.isNotEmpty)
    {
      _details.retainWhere((data_details){
        String searchterm=searchcontroller.text.toLowerCase();
        String name=data_details.pt_name.toLowerCase();
        String pdate=data_details.pay_date.toLowerCase();
        String pid=data_details.pt_id.toLowerCase();
        String mem_name=data_details.name.toLowerCase();
        return name.contains(searchterm) ||pdate.contains(searchterm) ||pid.contains(searchterm) ||mem_name.contains(searchterm);
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
          _details.clear();
          _details.addAll(data_details3);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shareprefs_dec();
    _getData_month();
    searchcontroller.addListener(() {
      filter_memberlist();
    });
  }
  @override
  Widget build(BuildContext context) {
    bool issearching=searchcontroller.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Commission',style: TextStyle(fontFamily: 'Titilliumweb'),),
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
      floatingActionButton:floationg_change==true? FloatingActionButton(
        onPressed: (){
          // writeOnPdf();
          // await savePdf();
          //CircularProgressIndicator();
          createPDF();
        },
        child: Icon(Icons.save),
      ):null,
      bottomSheet: state==true?dashboard_bottom_sheet(
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
            floationg_change=true;
          });
        },
        submit:(){
          setState(() {
            data_details3.clear();
            state=false;
            data_filter=true;
            filter_from_date=dashboard_bottom_sheet.from_date;
            _getFilterData_month();
            c.state_change=RxInt(1);
            print(filter_from_date);
            floationg_change=true;
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
                    Row(
                      children: <Widget>[
                        if (data_filter==false) Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('',style: TextStyle(fontSize: 12,fontFamily: 'Titilliumweb',color: Colors.white.withOpacity(0.7)),),
                                Text('',style: TextStyle(fontSize: 12,fontFamily: 'Titilliumweb',color: Colors.white.withOpacity(0.7)),)
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text('',style: TextStyle(fontSize: 12,fontFamily: 'Titilliumweb',color: Colors.white.withOpacity(0.8)),),
                              ],
                            )
                          ],
                        ) else Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Commission for '+month.toString(),style: TextStyle(fontSize: 12,fontFamily: 'Titilliumweb',color: Colors.white.withOpacity(0.7)),),
                              ],
                            ),
                            Row(
                              children: [
                                Text(count.toString()+' record found',style: TextStyle(fontSize: 12,fontFamily: 'Titilliumweb',color: Colors.white.withOpacity(0.7)),)
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text('Total commission paid:'+total.toString(),style: TextStyle(fontSize: 12,fontFamily: 'Titilliumweb',color: Colors.white.withOpacity(0.8)),),
                              ],
                            )
                          ],
                        )
                      ],
                    ),

                  ],
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        else
                        {
                          if(data_details3.length!=0)
                          {
                            return ListView.builder(itemCount:issearching==true?contain_filter.length:data_details3.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (context,index){
                                  commision_item commsion_data=issearching==true?contain_filter[index]:data_details3[index];
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
                                                    'PT id:'+commsion_data.pt_id,
                                                    //'Member id:',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 35/MediaQuery.of(context).devicePixelRatio,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: HexColor("#666666"),
                                                    borderRadius: BorderRadius.only(topLeft:Radius.circular(0),topRight:Radius.circular(15) ,bottomLeft: Radius.circular(0),bottomRight: Radius.circular(0)),
                                                  ),
                                                  child:Row(
                                                    children: <Widget>[
                                                      Text('Paid:',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(//'₹'+snapshot.data[index].balance,
                                                        '₹'+commsion_data.paid,
                                                        //"member_data",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                )
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
                                                                      commsion_data.pt_name,
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
                                                                        commsion_data.name!=null?
                                                                        Row(
                                                                          children: <Widget>[
                                                                            Text('Mem name: ',
                                                                              style: TextStyle(
                                                                                color: Colors.white70,
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                            Text(commsion_data.name,
                                                                              style: TextStyle(
                                                                                color: Colors.white.withOpacity(0.9),
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ): Row(
                                                                          children: <Widget>[
                                                                            Text('No Member name:',
                                                                              style: TextStyle(
                                                                                color: Colors.white70,
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
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
                                                                        Text('Pay. date:',
                                                                          style: TextStyle(
                                                                            color: Colors.white70,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                        Text(commsion_data.pay_date,
                                                                          style: TextStyle(
                                                                            color: Colors.white.withOpacity(0.9),
                                                                            fontSize: 12,
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
