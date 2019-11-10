import 'package:flutter/material.dart';
import 'package:flutter_flux_rss/models/date_convert.dart';
import 'package:flutter_flux_rss/widgets/card_item.dart';
import 'package:webfeed/domain/atom_feed.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:webfeed/domain/rss_item.dart';
import 'package:flutter_flux_rss/models/date_convert.dart';
import 'package:intl/intl.dart';

class CustomListView extends StatefulWidget {

  List<Map> feed;

  CustomListView(this.feed);

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {

  var convertedDateList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    convertDate(widget.feed);
  }

  @override
  Widget build(BuildContext context) {
    List l = widget.feed;
    return ListView.builder(
        itemCount: l.length,
        itemBuilder: (context, i) {
          Map each = l[i];
          return Container(
            height: 200.0,
            child: CardItem(each['author'], each['date'], "", each['title']),
          );
        }
    );

  }
  convertDate(List<Map> l) async{
    var response = await DateConvert().formattingDate(l);
    if(response!=null) {
      widget.feed = response;
    }
  }
}