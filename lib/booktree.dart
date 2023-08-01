import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl = "http://localhost:8080";

final defaultTextStyle = TextStyle(
  fontFamily: 'mainfont',
  fontSize: 16,
);

class userBook {
  final int bookId;
  final int userId;
  final String bookName;
  final String bookImg;
  final DateTime readingStart;
  final DateTime readingEnd;
  final String review;
  final int rating;
  final int total;

  userBook({required this.bookId,
    required this.userId,
    required this.bookName,
    required this.bookImg,
    required this.readingStart,
    required this.readingEnd,
    required this.review,
    required this.rating,
    required this.total
  });

  factory userBook.fromJson(Map<String, dynamic> json) {
    return userBook(
      bookId: json['accountId'],
      userId: json['userId'],
      bookName: json['bookName'],
      bookImg: json['bookImg'],
      readingStart: json['readingStart'],
      readingEnd: json['readingEnd'],
      review: json['review'],
      rating: json['rating'],
      total: json['total']
    );
  }
}

class booktree extends StatefulWidget{
  booktree({super.key});

  @override
  State<booktree> createState() => _booktreeState();
}

class _booktreeState extends State<booktree>{

  Future<List<userBook>> getUserBookList() async{
    final request = Uri.parse("$baseUrl/userBook_list");

    final jwtToken = await getJwtToken();
    print("이거 뭔데 씨ㅏ $jwtToken\n");

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken'
    };
    var response = await http.get(request, headers:headers);
    var json = jsonDecode(response.body);

    List<userBook> booklist = [];
    for(var bookJson in json)
    {
      booklist.add(userBook.fromJson(bookJson));
    }
    return booklist;
  }

  Future<String?> getJwtToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<String?> getUsernameWithToken() async
  {
    final request  = Uri.parse("$baseUrl/get_username_with_token");
    final jwtToken = await getJwtToken();
    print("이거 이룸 $jwtToken\n");

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken'
    };

    var response = await http.get(request, headers:headers);
    return response.body;
  }

  Future<void> readingBookAdd(BuildContext context) async {
    final request = Uri.parse("$baseUrl/reading_book_add");
    final jwtToken = await getJwtToken();
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken'
    };
    var response = await http.get(request, headers:headers);
    if(response.statusCode == 200)
    {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("책 추가 완료!"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => booktree()));
                    },
                    child:  Text("OK"),
                  )
              ),
            ],
          );

        },
      );
    }
    else
    {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("책 추가 실패 ㅜㅜ"),
            actions: [
              TextButton(
                onPressed: () {
                  // Dismiss the dialog
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Stacked Container ListView'),
      ),
      body: FutureBuilder<String?>(
        future: getUsernameWithToken(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot){
          String? username = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return ListView(
              children:[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/mainpage.gif',
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Text("안녕하세요 $username님!",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1.0,
                        height: 1.0,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, height *0.02, 0, height *0.02),
                          child: Text(
                            "나의 입출금 통장 😽",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder<List<userBook>>(
                          future: getUserBookList(),
                          builder: (BuildContext context, AsyncSnapshot<List<userBook>> snapshot) {
                            if(snapshot.hasData) {
                              List<userBook> userBooks = snapshot.data!;
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                //   crossAxisCount: 1,
                                //   childAspectRatio: 2.75,
                                // ),
                                itemCount: userBooks.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final item = userBooks[index];
                                  return GestureDetector(
                                    onTap: ()  {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (context) => MyTransactionScreen(item)),
                                      // );
                                    },

                                    child: Container(
                                      width: width*0.9,
                                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFFE0E0E0)),
                                        borderRadius: BorderRadius.circular(8.0),
                                        // image: DecorationImage(
                                        //   image: AssetImage('assets/images/beforeselect.jpg'),
                                        //   fit: BoxFit.cover,
                                        // ),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start, // Adjust crossAxisAlignment
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 0, 15 ,0),
                                                // child: ClipOval(
                                                //   child: Image.asset(
                                                //     'assets/images/banklogo.png',
                                                //     height: width * 0.15,
                                                //     width: width * 0.15,
                                                //     fit: BoxFit.cover,
                                                //   ),
                                                // ),
                                              ),
                                              Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Text(
                                                    //   "매드뱅크",
                                                    //   style: Theme.of(context).textTheme.caption,
                                                    // ),
                                                    SizedBox(height: height * 0.005),
                                                    Text(
                                                      "${item.bookName}",
                                                      style: const TextStyle(
                                                        // fontWeight: FontWeight.bold,
                                                          fontSize: 16
                                                      ),
                                                    ),
                                                    SizedBox(height: height * 0.005),
                                                    Text(
                                                      "${DateTime.now()}에 갱신됨",
                                                      style: Theme.of(context).textTheme.caption,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return CircularProgressIndicator();
                            }
                          }
                      ),
                      Container(
                        width: width*0.9,
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.amberAccent
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(13.0),
                                    child: GestureDetector(
                                      child: Text(
                                        "계좌 개설하기!",
                                        style: TextStyle(
                                          fontFamily: "mainfont",
                                          color: Colors.black87,
                                          fontSize: 18,
                                        ),
                                      ),
                                      onTap: () async {
                                        await readingBookAdd(context);
                                      },
                                    )
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "새 계좌가 필요하신가요?",
                                    style: TextStyle(
                                      fontFamily: "mainfont",
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

            );
          }else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        }
      )
    );
  }
}