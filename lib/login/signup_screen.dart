import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lepetitfront/booktree.dart';
import 'package:lepetitfront/login/login_screen.dart';

String baseUrl = "http://localhost:8080";


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController signupIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();

  void _signup() async {
    final String Url = '$baseUrl/signup'; // 서버의 회원가입 API 주소로 변경
    final request = Uri.parse(Url);
    var headers = <String, String> {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var body = {
      'userId': 0,
      'signupId': signupIdController.text,
      'password': passwordController.text,
      'nickname': nicknameController.text,
    };
    final response = await http.post(
      request,
      headers: headers,
      body: json.encode(body)
    );

    if (response.statusCode == 200) {
      // 회원가입 성공 처리
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      print('회원가입 성공');
    } else {
      // 회원가입 실패 처리
      print('회원가입 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup Page')),
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
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                labelText: 'Nickname',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _signup(); // 회원가입 버튼 클릭 시 HTTP POST 요청 전송
              },
              child: Text('Sign Up'),
            ),
            TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text(
                  "계정이 있으면 눌르라",
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