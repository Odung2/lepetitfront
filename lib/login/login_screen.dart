import 'dart:convert';

import 'package:animated_login/animated_login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_application_1/flex_screen.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:lepetitfront/booktree.dart';
import 'package:lepetitfront/login/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl = "http://localhost:8080";


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController signupIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Future<void> storeJwtToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('jwtToken', token);
  }
  void _login() async {
    final String Url = '$baseUrl/login'; // 서버의 로그인 API 주소로 변경
    final request = Uri.parse(Url);
    var headers = <String, String> {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var body = {
    'signupId': signupIdController.text,
    'password': passwordController.text,
    };
    final response = await http.post(
      request,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      // 로그인 성공 처리
      storeJwtToken(response.body);
      Navigator.push(context, MaterialPageRoute(builder: (context) => booktree()));

      print('로그인 성공');
    } else {
      // 로그인 실패 처리
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      print('로그인 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Page')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: signupIdController,
              decoration: InputDecoration(
                labelText: 'Signup ID',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _login(); // 로그인 버튼 클릭 시 HTTP POST 요청 전송
              },
              child: Text('Login'),
            ),
            TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
                },
                child: Text(
                  "계정이 없으면 눌르라",
                  style: TextStyle(

                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}