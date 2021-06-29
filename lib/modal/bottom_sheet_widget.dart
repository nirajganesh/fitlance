import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


void main()
{
  runApp(new MaterialApp(
      home: new bottom_sheet_widget()
  ));
}
class bottom_sheet_widget extends StatefulWidget {
  final String title;
  final VoidCallback close;
  static var from_date;
  static var to_date_value;
  static var type_date_value='joining_date';
  final VoidCallback submit;

  bottom_sheet_widget({
    this.title,
    this.close,
    this.submit,
    Key key,
  }):super(key:key);

  @override
  _bottom_sheet_widgetState createState() => _bottom_sheet_widgetState();
}

class _bottom_sheet_widgetState extends State<bottom_sheet_widget> {
  static final  List<String> listitem=<String>['Joining date','Expiry date'];
  String valuechoose=listitem.first;
  DateTime selectedDate = DateTime.now();
  DateTime to_date = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        bottom_sheet_widget.from_date=picked.day.toString()+"-"+picked.month.toString()+"-"+picked.year.toString();
        selectedDate=picked;
      });

  }
  Future<void> _toDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: to_date,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != to_date)
        to_date =picked;
        bottom_sheet_widget.to_date_value=picked.day.toString()+"-"+picked.month.toString()+"-"+picked.year.toString();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Filter by:',style: TextStyle(fontSize: 12,color: Colors.white.withOpacity(0.7)),),
                  Text('From:',style: TextStyle(fontSize: 12,color: Colors.white.withOpacity(0.7)),),
                  Text('To:',style: TextStyle(fontSize: 12,color: Colors.white.withOpacity(0.7)),),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 0,bottom: 0,left: 4,right: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:DropdownButton(
                      value: valuechoose,
                      onChanged: (newvalue){
                          valuechoose=newvalue;
                          if(newvalue=='Joining date')
                            {
                              bottom_sheet_widget.type_date_value='joining_date';
                            }
                          else
                            {
                              bottom_sheet_widget.type_date_value='exp_date';
                            }

                      },
                      underline: SizedBox(),
                      dropdownColor: Colors.black87,
                      hint:Text(valuechoose.toString(),style: TextStyle(color: Colors.white,fontSize: 15),),
                      items:listitem.map((valueitem) {
                        return DropdownMenuItem(
                            value: valueitem,
                            child:Text(valueitem.toString(),style: TextStyle(color: Colors.white,fontSize: 15),)
                        );
                      }).toList(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>{
                      _selectDate(context),
                    },
                    child:Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white,width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text("${selectedDate.toLocal()}".split(' ')[0],style: TextStyle(color: Colors.white),),
                      // child: Text("${c.count}",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  GestureDetector(
                    onTap: ()=>{
                      _toDate(context),
                    },
                    child:Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white,width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text("${to_date.toLocal()}".split(' ')[0],style: TextStyle(color: Colors.white),),
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
                      onPressed:
                        widget.submit,
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
