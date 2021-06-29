
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webproject/select_gym.dart';

class admin_login extends StatefulWidget {

  @override
  _admin_loginState createState() => _admin_loginState();
}

class _admin_loginState extends State<admin_login> {

  bool isRemeberme = false;
  var url;
  var res;
  var msg;
  String email;
  String password;
  String login="login";
  var response;
  bool hiddenpassword=true;
  bool loading=false;
  http.Response respo;
  Map<String,String> headers;
  final TextEditingController emailEditingController=TextEditingController();
  final TextEditingController passwordEditingcontroller= TextEditingController();
  bool visibles=true;
  SharedPreferences sharedpreferenced;


  @override
  Widget build(BuildContext context) {

    Widget buildusername()
    {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: Offset(0,2),
                  )
                ]
            ),
            height: 40,
            child: TextField(
              controller: emailEditingController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.black87,

              ),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black38,
                  ),
                  hintText: 'User name',
                  hintStyle: TextStyle(
                      color: Colors.black38
                  )
              ),
            ),
          )
        ],
      );
    }

    Widget buildPassword()
    {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: Offset(0,2),
                  )
                ]
            ),
            height: 40,
            child: TextField(
              controller: passwordEditingcontroller,
              obscureText: hiddenpassword,
              style: TextStyle(
                color: Colors.black87,

              ),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.lock, color: Colors.black38,),
                  suffixIcon: IconButton(
                   icon:Icon(hiddenpassword ?Icons.visibility_off :Icons.visibility),
                    onPressed: (){
                      setState(() {
                        hiddenpassword=!hiddenpassword;
                      });
                    },
                  ),
                  hintText: 'Password',
                  hintStyle: TextStyle(
                      color: Colors.black38
                  )
              ),
            ),
          ),

        ],
      );
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            child: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.black,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 120
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('images/aim_fitness_logo.png',height: 100.0,),
                        SizedBox(height: 20,),
                        Text(
                          'Admin login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(height: 50,),
                        buildusername(),
                        SizedBox(height: 20,),
                        buildPassword(),
                        SizedBox(height: 20,),
                        ArgonButton(
                          height: 42,
                          width: 350,
                          borderRadius: 5.0,
                          color: Color(0xFFFEE566),
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                          loader: Container(
                            padding: EdgeInsets.all(10),
                            child: SpinKitRotatingCircle(
                              color: Colors.white,
                              // size: loaderWidth ,
                            ),
                          ),
                          onTap: (startLoading, stopLoading, btnState) async {
                            if(btnState == ButtonState.Idle){
                              startLoading();
                              sharedpreferenced=await SharedPreferences.getInstance();
                              try
                              {
                                url= Uri.parse('https://aimfitness.thedigitalox.com/api/index.php');
                                http.post(url, body: {'username': emailEditingController.text, 'pwd': passwordEditingcontroller.text,'func':'login'}
                                ).then((res){
                                  var jsondata=json.decode(res.body);
                                  if(jsondata['status']=="success")
                                  {
                                    stopLoading();
                                    Fluttertoast.showToast(
                                        msg: "Successfully login",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.white,
                                        textColor: Colors.black,
                                        fontSize: 16.0
                                    );
                                    sharedpreferenced.setString("Branch_id",jsondata['data']['branch_id']);
                                    sharedpreferenced.setString("Name",jsondata['data']['name']);
                                    sharedpreferenced.setString("Password",jsondata['data']['pass_key']);
                                    sharedpreferenced.setString("Login_id", jsondata['data']['login_id']);
                                    sharedpreferenced.commit();
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) =>
                                        select_gym(data:"no",gym:"no")), (Route<dynamic> route) => false);
                                  }
                                  else
                                  {
                                    stopLoading();
                                    Fluttertoast.showToast(
                                        msg: "Invalid username or password.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.white,
                                        textColor: Colors.black,
                                        fontSize: 16.0
                                    );
                                  }
                                });
                              }catch(e)
                              {
                                Fluttertoast.showToast(
                                    msg: e,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.black38,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }
                            }
                          },
                        )

                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}



