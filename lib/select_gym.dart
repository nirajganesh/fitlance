import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webproject/home.dart';


class select_gym extends StatefulWidget {
  final String data;
  final String gym;
  const select_gym({Key key,this.data,this.gym}):super(key: key);

  @override
  _select_gymState createState() => _select_gymState();
}

class _select_gymState extends State<select_gym> {
  SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 100,
            ),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:<Widget> [
                Text(
                  'Choose your gym',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40,),
                GestureDetector(
                  onTap: () async {
                    sharedPreferences=await SharedPreferences.getInstance();
                    sharedPreferences.setString("gym_name", 'Aim fitness');
                    sharedPreferences.setString("Branch_id",'1');
                    sharedPreferences.commit();
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) =>
                        Home()), (Route<dynamic> route) => false);
                  },
                  child: "${widget.data}"=="yes" && "${widget.gym}"=="Aim fitness" ? Container(
                    width: 180,
                    height: 180,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white,width: 3),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Column(
                      children:<Widget> [
                        Container(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.check_circle,color: Colors.white,),
                        ),
                       Container(
                         child: Image.asset('images/aim_fitness_logo.png',height: 70,),
                       ),

                      ],
                    ),
                  ) :Container(
                    width: 180,
                    height: 180,
                    padding: EdgeInsets.all(50),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white,width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Image.asset('images/aim_fitness_logo.png',height: 30,),
                  ),
                ),
                SizedBox(height: 40,),
                GestureDetector(
                  onTap: () async {
                    sharedPreferences=await SharedPreferences.getInstance();
                    sharedPreferences.setString("gym_name", 'The strong room');
                    sharedPreferences.setString("Branch_id",'2');
                    sharedPreferences.commit();
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) =>
                        Home()), (Route<dynamic> route) => false);
                  },
                  child:"${widget.data}"=="yes" && "${widget.gym}"=="The strong room" ? Container(
                    width: 180,
                    height: 180,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white,width: 3),
                      borderRadius: BorderRadius.circular(7),
                    ),
                      child: Column(
                        children:<Widget> [
                          Container(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.check_circle,color: Colors.white,),
                          ),
                          Container(
                            child: Image.asset('images/strong_room_logo.png',height: 70,),
                          ),
                        ],
                      ),
                  ):Container(
                    width: 180,
                    height: 180,
                    padding: EdgeInsets.all(50),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white,width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Image.asset('images/strong_room_logo.png',height: 30,),
                  )
                ),
                SizedBox(height: 60,),
                Text(
                  'Note: You can change your gym later form the dashboard',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
      ),
    );

  }
}


