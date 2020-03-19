import 'package:flutter/material.dart';
import 'package:bachelor_app/views/StopwatchScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
String db;

class Homepage extends StatefulWidget {
  final String deviceId;
  final List<Map<String, dynamic>> activities;
  Homepage({Key key, @required this.deviceId, this.activities}) : super(key: key);

  @override
  _HomepageState createState() =>_HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  Future<String> getDb() async {
    return await rootBundle.loadString("dbIp.json");
  }

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
  }

  List<Map<String, dynamic>> activities = [];
  void fetchActivities() async {
    await getDb().then((data) async {
      var ip = json.decode(data);
      final response = await http.get(
          "http://" + ip['ip'] + "/_db/Bachelor/activities_crud/activities");
      if (response.statusCode == 200) {
        activities = [];
        var data = json.decode(response.body);
        for (var i = 0; i < data.length; i++) {
          if (data[i]['user'] == widget.deviceId) {
            activities.add(data[i]);
          }
        }
        setState((){});
      }
    });
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
                  child: new Center(
                    child: new Container(
                      width: 325,
                      child: new TextField(
                        decoration: InputDecoration(
                        border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide()
                      ),
                        fillColor: Colors.white,
                        hintText: "Enter activity name",
                      ),
                        onChanged: (text){
                        activityInput = text;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          RaisedButton(
              onPressed: (){
                if(activityInput != ""){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StopwatchPage(activityName: activityInput, deviceId: deviceId, activities: this.activities,)),
                    ModalRoute.withName("Homepage"),
                  );
                } else {
                  this._neverSatisfied();
                }
              },
              color: Colors.green,
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

  void removeActivity(key) async {
    await getDb().then((data) async {
      var ip = json.decode(data);
      final response = await http.delete("http://" + ip['ip'] + "/_db/Bachelor/activities_crud/activities/" + key);
      if (response.statusCode == 204) {
        this.fetchActivities();
      }
    });
  }

  void showMap(lat, long){
    print(long + " " + lat);
  }

  Widget allActivities(){
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: activities.length,
      itemBuilder: (context, index){
        return new Card(
          child: ListTile(
            leading: IconButton(
                icon: Icon(
                    Icons.public, size: 30, color: Colors.greenAccent),
                    onPressed: (){showMap(activities[index]['long'], activities[index]['lat']);},
            ),
            trailing: IconButton(
                icon: Icon(
                  Icons.remove_circle,size: 30, color: Colors.red),
                  onPressed: (){removeActivity(activities[index]['_key']);}
            ),
            title: Text(activities[index]['activity']),
            subtitle: Text(activities[index]['time']),
          ),
        );
      },
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
              "New activity",
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
          allActivities()
        ],
        controller: tb,
      ),
    );
  }
}