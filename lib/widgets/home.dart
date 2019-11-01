import 'dart:math';

import 'package:barbarian/barbarian.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux_rss/models/database.dart';
import 'package:flutter_flux_rss/models/parser.dart';
import 'dart:async';
import 'package:flutter_flux_rss/widgets/custom_list_view.dart';
import 'package:flutter_flux_rss/widgets/custom_text.dart';
import 'package:flutter_flux_rss/widgets/flux.dart';
import 'package:flutter_flux_rss/widgets/flux_manager.dart';
import 'package:webfeed/webfeed.dart';
import 'card_item.dart';
import 'loading_screen.dart';



class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  AtomFeed feed;

  List<Future<dynamic>>listOfFeeds;

  CardItem cardItem;

  Map data = {
    "1" : 1,
    "2" : 2,
  };

  Map map = {
    "1": {
      "title" : {
        "format" : "true"
      }
    }
  };
  List<CardItem> dataList;

  List getListOfFeeds;

  var db;
  var listKeys;
  var listEntries;
  var editingName;
  var editingUrl;

  var testL = ["0", "1"];

  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbConnect();
    parsing();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: displayBodyContent()
    );
  }


  Widget headerButton(String title, Color buttonColor, Function func, {double width, double height, Color textColor, double fontSize}) {
    return Container(
      width: width?? 100.00,
      height: height?? 20.0,
      child: RaisedButton(
        elevation: 10.0,
        onPressed: () {
          func();
        },
        child: CustomText(title, color: textColor?? Colors.white, fontSize: fontSize?? 10.0,),
        color: buttonColor,
      ),
    );
  }

  Widget displayBodyContent() {
    if(listKeys == null) {
      return LoadingScreen();
    } else {
      Orientation orientation = MediaQuery.of(context).orientation;
      if(orientation==Orientation.portrait){
        // list
        return Center(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(10.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    headerButton("ADD", Colors.lightGreen ,() {
                      return showDialog(
                          context: context,
                        builder: (BuildContext context) {
                            return SimpleDialog(
                              elevation: 10.0,
                              title: CustomText("New".toUpperCase(), color: Colors.green,),
                              children: <Widget>[
                                Divider(),
                                Container(
                                  padding: EdgeInsets.all(40.0),
                                  child: Column(
                                    children: <Widget>[
                                      TextField(

                                        obscureText: false,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Name",
                                          hintText: "Enter a name",
                                        ),
                                        onChanged: (String s) {
                                          editingName = s;
                                          print(editingName);
                                        },
                                      ),
                                      Padding(padding: EdgeInsets.all(10.0)),
                                      TextField(
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'URL',
                                          hintText: "Enter an URL",
                                        ),
                                        onChanged: (String s) {
                                          editingUrl = s;
                                          print(editingUrl);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                Padding(padding: EdgeInsets.all(3.0)),
                                SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      db.add((editingName!=null? editingName : null), (editingUrl!=null?editingUrl : null));
                                      dbConnect();
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: CustomText("Add", color: Colors.indigo,),
                                ),
                              ],
                            );
                        }
                      );
                    }, width: 145.0,),
                    headerButton("RESET", Colors.grey ,() {
                      db.reset();
                      setState(() {
                        dbConnect();
                      });
                    }, width: 145.0),
                  ],
                ),
                Container(
                  height: 200.00,
                  padding: EdgeInsets.all(20.0),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: listKeys.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onLongPress: () {
                          Future.sync(() => {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    elevation: 10.0,
                                    title: CustomText("Information".toUpperCase(), color: Colors.black,),
                                    children: <Widget>[
                                      Divider(),
                                      Container(
                                        padding: EdgeInsets.all(40.0),
                                        child: Column(
                                          children: <Widget>[
                                            TextField(
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "Name",
                                                hintText: listKeys[index],
                                              ),
                                              onChanged: (String s) {
                                                editingName = s;
                                                print(editingName);
                                              },
                                            ),
                                            Padding(padding: EdgeInsets.all(10.0)),
                                            TextField(
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'URL',
                                                hintText: listEntries[index]['url'],
                                              ),
                                              onChanged: (String s) {
                                                editingUrl = s;
                                                print(editingUrl);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      RaisedButton(
                                        color : Colors.indigo,
                                        onPressed: () {
                                          setState(() {
                                            db.delete(listKeys[index]);
                                            db.add((editingName!=null? editingName : listKeys[index]), (editingUrl!=null?editingUrl : listEntries[index]['url']));
                                            dbConnect();
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Container(
                                            padding : EdgeInsets.all(15.00),
                                            child: CustomText("Ok", color: Colors.white,)),
                                      ),
                                      Padding(padding: EdgeInsets.all(5.0)),
                                      SimpleDialogOption(
                                        onPressed: () {
                                          setState(() {
                                            db.delete(listKeys[index]);
                                            dbConnect();
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: CustomText("Delete", color: Colors.red,),
                                      ),
                                    ],
                                  );
                                }
                            )
                          });
                        },
                        child:  Container(
                            height: 30,
                            child: Center(child: CustomText('${listKeys[index].toString().toUpperCase()}', color: Colors.indigo, fontStyle: FontStyle.italic, fontSize: 15.0,))
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
                ),
//                SizedBox(
//                  height: MediaQuery.of(context).size.height*0.59,
//                  child: (feed!=null? CustomListView(feed) : CustomText("en cours")),
//                )
              ],
            ),
        );
      } else {
        // grid
      }
    }
  }



  void dbConnect() async{
    db = await Database();
    Future.delayed(Duration(seconds: 1), () {
      if (db!=null) {
        print("...DATA RECEIVED...");
        setState(() {
          listKeys = db.getActualKeys();
          listEntries = db.getActualEntries();
        });
        print(listKeys);
        print(listEntries);
      }
    });

  }

  Future<Null> parsing() async{


    final resp = await Parser().loadRSS("${listEntries[0]['url']}");
    if (resp!=null) {
      print("...DATA RECEIVED...");
      setState(() {
        feed = resp;
      });
    }
  }
}
