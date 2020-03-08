import 'package:flutter/material.dart';
import 'package:bachelor_app/views/StopwatchScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Homepage extends StatefulWidget {
  final String deviceId;
  final List<Map<String, dynamic>> activities;
  Homepage({Key key, @required this.deviceId, this.activities}) : super(key: key);

  @override
  _HomepageState createState() =>_HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  TabController tb;
  @override
  void initState(){
    tb = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
    if(widget.activities != null){
      this.activities = widget.activities;
    }
    this.fetchActivities();
    print(activities);
  }

  List<Map<String, dynamic>> activities = [];
  void fetchActivities() async {
    final response = await http.get("http://192.168.0.181:8529/_db/Bachelor/activities_crud/activities");
    if(response.statusCode == 200){
      activities = [];
      var data = json.decode(response.body);
      for(var i = 0; i < data.length; i++){
        if(data[i]['user'] == widget.deviceId){
          activities.add(data[i]);
        }
      }
    }
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You need to enter a name for your activity.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget activity(){
    String deviceId = widget.deviceId;
    String activityInput = "";
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter activity name",

                  ),
                  onChanged: (text){
                    activityInput = text;
                  },
                ),
              ),
            ],
          ),
          RaisedButton(
              onPressed: (){
                if(activityInput != ""){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StopwatchPage(activityName: activityInput, deviceId: deviceId, activities: this.activities,)),
                  );
                } else {
                  this._neverSatisfied();
                }
              },
              color: Colors.blue,
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 15.0,
              ),
              child: Text(
                  "Add activity",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  )
              )
          ),
        ],
      ),
    );
  }

  Widget allActivities(){
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: activities.length,
        itemBuilder: (BuildContext ctxt, int index){
          return new Text(activities[index]['activity']);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Bachelor",
        ),
        centerTitle: true,
        bottom: TabBar(
          tabs: <Widget>[
            Text(
              "Activity",
            ),
            Text(
              "All activities",
            ),
          ],
          labelPadding: EdgeInsets.only(
            bottom: 10.0,
          ),
          labelStyle: TextStyle(
            fontSize: 18.0,
          ),
          unselectedLabelColor: Colors.white60,
          controller: tb,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          activity(),
          allActivities(),
        ],
        controller: tb,
      ),
    );
  }
}