import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';


void main()
{
  runApp(new MaterialApp(
      home: new dashboard_bottom_sheet()
  ));
}
class dashboard_bottom_sheet extends StatefulWidget {
  final VoidCallback title;
  final VoidCallback close;
  static var from_date;
  static var to_date_value;
  static var type_date_value='joining_date';
  final VoidCallback submit;
  final VoidCallback nothing;

  dashboard_bottom_sheet({
    this.title,
    this.close,
    this.submit,
    this.nothing,
    Key key,
  }):super(key:key);

  @override
  _dashboard_bottom_sheetState createState() => _dashboard_bottom_sheetState();
}

class _dashboard_bottom_sheetState extends State<dashboard_bottom_sheet> {
  String selectedDate='Select month and year';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showMonthPicker(
        context: context,
        initialDate:DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        dashboard_bottom_sheet.from_date=picked.month.toString()+"-"+picked.year.toString();
        selectedDate=picked.month.toString()+"-"+picked.year.toString();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      color: Colors.black,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child:Align(
        alignment: Alignment.center,
        child:Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(onPressed: widget.close,color: Colors.black,
                    child: Icon(Icons.clear,color: Colors.white,),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () =>{
                      _selectDate(context),
                    },
                    child:Container(
                      width: 280,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white,width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(selectedDate,style: TextStyle(color: Colors.white.withOpacity(0.8)),),
                      // child: Text("${c.count}",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 280,
                    child:  RaisedButton(
                      padding: EdgeInsets.only(top: 12, bottom:12),
                      elevation: 5,
                      // onPressed:(){
                      //
                      //   if(selectedDate=="Select month and year")
                      //     {
                      //       Fluttertoast.showToast(
                      //         msg: "Select month and year",
                      //         toastLength: Toast.LENGTH_LONG,
                      //         gravity: ToastGravity.BOTTOM,
                      //         backgroundColor: Colors.white,
                      //         textColor: Colors.black.withOpacity(0.8),
                      //         fontSize: 14.0,
                      //       );
                      //     }
                      //   else
                      //     {
                      //       print(selectedDate);
                      //       widget.submit;
                      //     }
                      // },
                      onPressed:selectedDate=="Select month and year"?widget.title:widget.submit,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.yellow,
                      child: Text(
                        'SUBMIT',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
