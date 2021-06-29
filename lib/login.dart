
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatelessWidget {
  bool isRemeberme = false;
  var url;
  var res;
  var msg;
  String email;
  String password;
  String login="login";
  var response;
  http.Response respo;
  Map<String,String> headers;
  final TextEditingController emailEditingController=TextEditingController();
  final TextEditingController passwordEditingcontroller= TextEditingController();

  Widget buildEmail()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: 10,),
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
                contentPadding: EdgeInsets.only(top:14),
                prefixIcon: Icon(
                  Icons.email,
                  color: Color(0xff5ac18e),
                ),
                hintText: 'Enter the email..',
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
        Text(
          'Password',
          style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: 10,),
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
            obscureText: true,
            style: TextStyle(
              color: Colors.black87,

            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top:14),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Color(0xff5ac18e),
                ),
                suffixIcon:Icon(
                  Icons.panorama_fish_eye,
                  color: Color(0xff5ac18e),
                ) ,
                hintText: 'Enter the password..',
                hintStyle: TextStyle(
                    color: Colors.black38
                )
            ),
          ),
        )
      ],
    );
  }

  Widget buildForgetpassword()
  {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print("Forgot password"),
        padding: EdgeInsets.only(right: 0),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildRemembercb()
  {
    return Container(
      height: 20,
      child: Row(
        children: [
          Theme(data: ThemeData(unselectedWidgetColor: Colors.white),
              child: Checkbox(
                value: isRemeberme,
                checkColor: Colors.green,
                activeColor: Colors.white,
                onChanged: (value){

                },
              )
          ),
          Text(
            'Remember me',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget  buildLoginbtn()
  {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: RaisedButton(
        padding: EdgeInsets.only(top: 20, bottom:20),
        elevation: 5,
        onPressed: () async => {
             login_url()
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Color(0xff5a94c1),
        child: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  Widget login_url()
  {
     try{
       print("enter");
       url= Uri.parse('https://aimfitness.thedigitalox.com/api/index.php');
       http.post(url,
       body: {'username': emailEditingController.text, 'pwd': passwordEditingcontroller.text,'func':'login'}
       ).then((res){
       print(res.body);
       });
     }catch(e)
     {
       Fluttertoast.showToast(
           msg:e,
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.CENTER,
           timeInSecForIosWeb: 1,
           backgroundColor: Colors.red,
           textColor: Colors.white,
           fontSize: 16.0
       );
     }
  }
  void senddata() async {
      email=emailEditingController.text.toString();
      password=passwordEditingcontroller.text.toString();
      url= Uri.parse("https://aimfitness.thedigitalox.com/api/index.php?username=$email&pwd=$password&func=$login");
      var response=await http.post(url);
      print(response);
  }
  Widget buildSignUpBtn()
  {
    return GestureDetector(
      onTap: () => print("Sign Up Pressed"),
      child: RichText(
        text: TextSpan(
            children: [
              TextSpan(
                  text: 'Do not have an account?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )
              ),
              TextSpan(
                  text: 'Sign up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )
              )
            ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xff5ac18e),
                            Color(0x995ac18e),
                            Color(0xcc5ac18e),
                            Color(0xff5ac18e),
                          ]
                      )
                  ),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 120
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(height: 50,),
                        buildEmail(),
                        SizedBox(height: 20,),
                        buildPassword(),
                        buildForgetpassword(),
                        buildRemembercb(),
                        buildLoginbtn(),
                        buildSignUpBtn(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      // body: Container(
      //   child: Column(
      //     children: [
      //       SizedBox(height: 65.0,),
      //       Image(
      //         image: new AssetImage("images/love.png"),
      //         width: 120.0,
      //         height: 120.0,
      //         alignment: Alignment.topLeft,
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
