import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {

  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(new CSUBUFlutterApp());

}

class CSUBUFlutterApp extends StatelessWidget {

  final appTitle = 'CSUBU App Page';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //fontFamily: 'Roboto'
      ),
      home: AppHomePage(title: appTitle),
    );
  }

}

class AppHomePage extends StatefulWidget {

  AppHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppHomePageState createState() => _AppHomePageState();

}

class _AppHomePageState extends State<AppHomePage> {

  int _counter = 0;
  var _courses = <dynamic>[ ];
  // Future<dynamic> _students;
  var _students = [];
  var _loading = true;
  var _page = 0;

  _getStudents() async {
    var url = 'http://cs.sci.ubu.ac.th:7512/topic-1/Toranit_60114440136/_search?from=${_page*10}&size=10';
    const headers = { 'Content-Type': 'application/json; charset=utf-8' };
    const query = { 'query': { 'match_all': {} } };
    final response = await http.post(url, headers: headers, body: json.encode(query));
    _students = [];
    if (response.statusCode == 200) {
      var result = jsonDecode(utf8.decode(response.bodyBytes))['result']['hits'];
      result.forEach((item) {
        if (item.containsKey('_source')) {
          var source = item['_source'];
          if (source.containsKey('name') && source.containsKey('detail')) {
            _students.add(item['_source']);
          }
        }
      });
    }
    setState(() {
      _page = (_page+1)%3;
      _loading = false;
    });
  }

  void _incrementCounter() {
    setState(() { _loading = true; });
    _getStudents();
  }

  Widget studentWidgets(BuildContext context) {
    return ListView.separated(
        itemCount: _students.length,
        padding: const EdgeInsets.all(8.0),
        separatorBuilder: (context, i) => const Divider(),
        itemBuilder: (context, i) {
          final student = _students[i];
          var sum = 0;
          student['detail'].runes.forEach((c) { sum += c; });
          return ListTile(
            title: Row(
                  children: <Widget>[
                    // Image.asset('assets/images/csubu-bw.png', width: 48, height: 48),
                    CircleAvatar(backgroundImage: NetworkImage('${student["img"]}')),
                    Expanded(child: Text(student["name"])),
                      
                  ]

                ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Price: ${student["price"]}'),
                Text('Detail: ${student["detail"]}'),
                Icon(Icons.share, color: Colors.black26),
                Icon(Icons.thumb_up, color: Colors.lightBlue),
                Icon(Icons.favorite, color: Colors.pink),

              ]
             )
          );
        }
      );
  }

  Widget loadingWidget(BuildContext context) {
    return Column(children: <Widget>[Text('loading....'), CircularProgressIndicator(), Text('Click the button')]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title) ,
      ),
      body: Center(
        child: (_loading)? loadingWidget(context) : studentWidgets(context),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(height: 50.0,),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Text('$_page'), // Icon(Icons.add),
      )
    );
  }
}
