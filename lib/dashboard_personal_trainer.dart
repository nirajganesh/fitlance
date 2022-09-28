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
import 'package:webproject/modal/dashboard_bottom_sheet.dart';
import 'package:webproject/modal/dashboard_personal_traineritem.dart';
import 'package:webproject/modal/getcontroller.dart';
import 'modal/pdfile.dart';



void main() {
  runApp(new MaterialApp(
      home: new dashboard_personal_trainer()
  ));
}
class dashboard_personal_trainer extends StatefulWidget {


  @override
  _dashboard_personal_trainerState createState() => _dashboard_personal_trainerState();
}

class _dashboard_personal_trainerState extends State<dashboard_personal_trainer> {

  List<dashboard_personal_traineritem> data_details1=[];
  List<dashboard_personal_traineritem> member_list1=[];
  List<dashboard_personal_traineritem> contain_filter=[];
  var from_datevalue='From';
  var to_datevalue='to';
  bool state=false;
  FocusScopeNode currentFocus;
  bool data_filter=false;

  String filter_from_date='';
  var filter_to_date;
  var filter_type_date;
  String valuechoose;
  List listitem=['Joining date','Expiry date'];
  DateTime selectedDate = DateTime.now();
  String gyn_data;
  String name;
  SharedPreferences prefs;
  TextEditingController searchcontroller=TextEditingController();
  TextEditingController statuscontroller=TextEditingController();
  var filter_value;
  int month_rev,month_paid,month_bal,count;
  String month;
  bool floationg_change=true;


  final scaffoldState = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final getcontroller c=Get.put(getcontroller());

  Future _getData() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'trainersMonthRev','branch_id':sharedPreferences.getString("Branch_id")}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    data_details1.clear();
    //setState(() {
      if(data['data']!=null) {
        month_rev = data['month_revenue_pt'];
        month_paid = data['month_paid_pt'];
        month_bal = data['month_bal_pt'];
        month = data['month'];
        count = data['count'];
       }
  //  });
    for(var memberdata in dataarray)
    {
      dashboard_personal_traineritem listdata=dashboard_personal_traineritem(memberdata['mem_id'],memberdata['mem_name'],memberdata['join_date'],memberdata['exp_date'],memberdata['balance'],memberdata['pt_name'],memberdata['total'],memberdata['paid']);
      data_details1.add(listdata);
    }
    return data_details1;
  }



  Future _getData_month() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'trainersMonthRev','branch_id':sharedPreferences.getString("Branch_id")}
    );
    var data = jsonDecode(response.body);
    setState(() {
      if(data['data']!=null) {
        month_rev = data['month_revenue_pt'];
        month_paid = data['month_paid_pt'];
        month_bal = data['month_bal_pt'];
        month = data['month'];
        count = data['count'];
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

  Future _getFilterData() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'trainersMonthRevfilter','branch_id':sharedPreferences.getString("Branch_id"),'from':filter_from_date}
    );
    var data = jsonDecode(response.body);
    var dataarray=data['data'];
    print(dataarray);
   // setState(() {
      data_details1.clear();
      if(data['data']!=null)
      {
        month_rev=data['month_revenue_pt'];
        month_paid=data['month_paid_pt'];
        month_bal=data['month_bal_pt'];
        month=data['month'];
        count=data['count'];
      }
   // });
    for(var memberdata in dataarray)
    {
      dashboard_personal_traineritem listdata=dashboard_personal_traineritem(memberdata['mem_id'],memberdata['mem_name'],memberdata['join_date'],memberdata['exp_date'],memberdata['balance'],memberdata['pt_name'],memberdata['total'],memberdata['paid']);
      data_details1.add(listdata);
    }
    c.state_change=RxInt(0);
    return data_details1;
  }

  Future _getFilterData_month() async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("https://aimfitness.thedigitalox.com/api/index.php"),
        body: {'username': sharedPreferences.getString("Login_id"), 'pwd': sharedPreferences.getString("Password"),'func':'trainersMonthRevfilter','branch_id':sharedPreferences.getString("Branch_id"),'from':filter_from_date}
    );
    var data = jsonDecode(response.body);
    setState(() {
      if(data['data']!=null)
      {
        month_rev=data['month_revenue_pt'];
        month_paid=data['month_paid_pt'];
        month_bal=data['month_bal_pt'];
        month=data['month'];
        count=data['count'];
      }
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

  filter_memberlist()
  {
    List<dashboard_personal_traineritem> _details=[];
    _details.addAll(data_details1);
    if(searchcontroller.text.isNotEmpty)
    {
      _details.retainWhere((data_details){
        String searchterm=searchcontroller.text.toLowerCase();
        String name=data_details.mem_name.toLowerCase();
        String mem_id=data_details.mem_id.toLowerCase();
        String join_Date=data_details.join_date.toLowerCase();
        String pt_name=data_details.pt_name.toLowerCase();
        String exp_Date=data_details.exp_date.toLowerCase();
        String total=data_details.total.toLowerCase();
        String paid=data_details.mem_id.toLowerCase();
        return name.contains(searchterm) || mem_id.contains(searchterm) || join_Date.contains(searchterm) || exp_Date.contains(searchterm) || pt_name.contains(searchterm) || total.contains(searchterm) || paid.contains(searchterm);
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
          _details.addAll(data_details1);
        });
      }
    }
  }

  Future<void> createPDF() async
  {
    if(data_details1.length!=0)
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
        header.cells[0].value='id';
        header.cells[1].value='Mem_name';
        header.cells[2].value='Pt_name';
        header.cells[3].value='Join_date';
        header.cells[4].value='Exp_date';
        header.cells[5].value='Balance';

        PdfGridRow row=grid.rows.add();
        for(var alldata in data_details1)
        {
          row=grid.rows.add();
          row.cells[0].value=alldata.mem_id;
          row.cells[1].value=alldata.mem_name;
          row.cells[2].value=alldata.pt_name;
          row.cells[3].value=alldata.join_date;
          row.cells[4].value=alldata.exp_date;
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
        saveAndlaunchfile(bytes, (DateTime.now().toString()+'_'+gyn_data+'_'+'personal_trainer'+'_'+month+'.pdf').toString());
        print("file saved");
      }
    else
      {
        Fluttertoast.showToast(
          msg: "Not trainer available",
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
        title: Text('Personal Trainer',style: TextStyle(fontFamily: 'Titilliumweb'),),
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
            data_details1.clear();
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
                          if(data_details1.length!=0)
                          {
                            return ListView.builder(itemCount: issearching==true?contain_filter.length:data_details1.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (context,index){
                                  dashboard_personal_traineritem personal_data=issearching==true?contain_filter[index]:data_details1[index];
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
                                                    'Member id:'+personal_data.mem_id,
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
                                                                      personal_data.mem_name,
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
                                                                        Text('PT: ',
                                                                          style: TextStyle(
                                                                            color: Colors.white70,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                        Text(personal_data.pt_name,
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
                                                                        Text(personal_data.join_date,
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
                                                                    Text(personal_data.exp_date,
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
                                                        Padding(padding: EdgeInsets.only(top:15),
                                                          child: Container(
                                                            padding: EdgeInsets.only(top:4,left:10,bottom: 4),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children:<Widget>[
                                                                Text('Total: ₹'+personal_data.total,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 12,color: Colors.white),),
                                                                Text('Paid: ₹'+personal_data.paid,style: TextStyle(fontFamily: 'Titilliumweb',fontSize: 12,color: Colors.white),),
                                                                personal_data.balance!="0"?Container(
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
                                                                        '₹'+personal_data.balance,
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
