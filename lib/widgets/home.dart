import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_flux_rss/models/parser.dart';
import 'package:flutter_flux_rss/widgets/custom_grid_view.dart';
import 'package:flutter_flux_rss/widgets/custom_list_view.dart';
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

  RssFeed feed;
  RssItem item;

  CardItem cardItem;

  Map data;
  List<CardItem> dataList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parsing();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: displayBodyContent(),
      )
    );
  }

  Widget displayBodyContent() {
    if(feed == null) {
      return LoadingScreen();
    } else {
      Orientation orientation = MediaQuery.of(context).orientation;
      if(orientation==Orientation.portrait){
        // list
        return CustomListView(feed);
      } else {
        // grid
        return CustomGridView(feed);
      }
    }
  }


  Future<Null> parsing() async {
    RssFeed response = await Parser().loadRSS();
    print(response);
    if(response!=null) {
      setState(() {
        feed = response;
      });
    } else {
      print("request didn't succeed");
    }
  }

}