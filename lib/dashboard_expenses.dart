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
import 'package:webproject/memberdetails.dart';
import 'package:webproject/modal/bottom_sheet_widget.dart';
import 'package:webproject/modal/expances_item.dart';
import 'package:webproject/modal/getcontroller.dart';
import 'package:webproject/modal/memberitem.dart';
import 'package:webproject/modal/personal_trainer_item.dart';

import 'modal/pdfile.dart';

class dashboard_expenses extends StatefulWidget {

  @override
  _dashboard_expensesState createState() => _dashboard_expensesState();
}

class _dashboard_expensesState extends State<dashboard_expenses> {

  List<expances_item> data_details2=[];
  List<expances_item> member_list2=[];
  List<expances_item> contain_filter=[];
  DateTime selectedDate = DateTime.now();
  bool state=true;
  String gyn_data;
  String name;
  SharedPreferences prefs;
  TextEditingController searchcontroller=TextEditingController();


  final scaffoldState = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  Future _getData() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'expensesMonth','branch_id':sharedPreferences.getString("Branch_id")}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    data_details2.clear();
    for(var memberdata in dataarray)
    {
      expances_item listdata=expances_item(memberdata['cost'],memberdata['item'],memberdata['date']);
      data_details2.add(listdata);
    }
    return data_details2;
  }

  filter_memberlist()
  {
    List<expances_item> _details=[];
    _details.addAll(data_details2);
    if(searchcontroller.text.isNotEmpty)
    {
      _details.retainWhere((data_details){
        String searchterm=searchcontroller.text.toLowerCase();
        String name=data_details.item.toLowerCase();
        String cost=data_details.cost.toLowerCase();
        String pdate=data_details.date.toLowerCase();
        return name.contains(searchterm)||cost.contains(searchterm)||pdate.contains(searchterm);
      });
      setState(() {
        contain_filter.clear();
        contain_filter=_details;
      });
    }
    else
    {
      setState(() {
        _details.clear();
        _details.addAll(data_details2);
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

  Future<void> createPDF() async
  {
    if(data_details2.length!=0)
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
          //bounds: const Rect.fromLTWH(0, 15, 200, 20)
        );
//Add the header element to the document.
        document.template.top = headerTemplate;


        PdfGridRow header=grid.headers[0];
        header.cells[0].value='Date';
        header.cells[1].value='Name';
        header.cells[2].value='Cost';

        PdfGridRow row=grid.rows.add();
        for(var alldata in data_details2)
        {
          row=grid.rows.add();
          row.cells[0].value=alldata.date;
          row.cells[1].value=alldata.item;
          row.cells[2].value=alldata.cost;
        }

        grid.draw(page:document.pages.add(),bounds:const Rect.fromLTWH(0, 0, 0,0));
        List<int> bytes=document.save();
        document.dispose();
        saveAndlaunchfile(bytes, (DateTime.now().toString()+'_'+gyn_data+'_'+'expenses'+'_'+'.pdf').toString());
        print("file saved");
      }
    else
      {
        Fluttertoast.showToast(
          msg: "Not expancess available",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black.withOpacity(0.8),
          fontSize: 14.0,
        );
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
  Widget build(BuildContext context) {
    bool issearching=searchcontroller.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // writeOnPdf();
          // await savePdf();
          //CircularProgressIndicator();
          createPDF();
        },
        child: Icon(Icons.save),
      ),
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
                      ],
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                    color: Colors.black,
                    child:FutureBuilder(
                      future:_getData(),
                      builder:(context,snapshot)
                      {
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
                          if(data_details2.length.toString()!="0")
                          {
                            return ListView.builder(itemCount:issearching==true?contain_filter.length:data_details2.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (context,index){
                                  expances_item expences_data=issearching==true?contain_filter[index]:data_details2[index];
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
                                              mainAxisAlignment:MainAxisAlignment.end,
                                              children: <Widget>[
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  padding: EdgeInsets.only(top:2,left:5,right:5,bottom: 2),
                                                  decoration: BoxDecoration(
                                                    color: HexColor("#666666"),
                                                    borderRadius: BorderRadius.only(topLeft:Radius.circular(2),topRight:Radius.circular(15) ,bottomLeft: Radius.circular(2),bottomRight: Radius.circular(0)),
                                                  ),
                                                  child:Text(
                                                    //    'Member id:'+snapshot.data[index].id,
                                                    'Cost: ₹'+expences_data.cost,
                                                    //'Member id:',
                                                    style: TextStyle(
                                                      fontFamily: 'Titilliumweb',
                                                      color: Colors.white,
                                                      fontSize: 12,
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
                                                          padding: EdgeInsets.only(top: 0,left: 5,bottom: 5,right: 10),
                                                          child: Container(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: <Widget>[
                                                                    Text(
                                                                      //snapshot.data[index].name,
                                                                      'Date: ',
                                                                      style: TextStyle(
                                                                          fontFamily: 'Titilliumweb',
                                                                          color: Colors.white.withOpacity(0.7),
                                                                          fontSize: 14
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      //snapshot.data[index].name,
                                                                      expences_data.date,
                                                                      style: TextStyle(
                                                                          fontFamily: 'Titilliumweb',
                                                                          color: Colors.white,
                                                                          fontSize: 14
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children:<Widget> [
                                                                    Row(
                                                                      children: <Widget>[
                                                                        Text(expences_data.item,
                                                                          style: TextStyle(
                                                                            fontFamily: 'Titilliumweb',
                                                                            color: Colors.white.withOpacity(0.9),
                                                                            fontSize: 14,
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
