import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bachelor_app/views/HomeScreen.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
String db;

class StopwatchPage extends StatefulWidget {
  final String activityName, deviceId;
  final List<Map<String, dynamic>> activities;
  StopwatchPage({Key key, @required this.activityName, this.deviceId, this.activities}) : super(key: key);

  @override
  _Stopwatch createState() => _Stopwatch();
}

class _Stopwatch extends State<StopwatchPage> with TickerProviderStateMixin {
  Future<String> getDb() async {
    return await rootBundle.loadString("dbIp.json");
  }

  TabController tb;
  @override
  void initState() {
    tb = TabController(
      length: 1,
      vsync: this,
    );
    super.initState();
  }

  List<Map<String, dynamic>> activities = [];
  void addActivity() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    getDb().then((data) async {
      var ip = json.decode(data);
        final response = await http.post("http://" + ip['ip'] + "/_db/Bachelor/activities_crud/activities",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
            body: jsonEncode(<String, String>{
            'user': widget.deviceId,
            'activity': widget.activityName,
            'time': stopTimeToDisplay,
            'date': DateTime.now().toString(),
            'lat': position.latitude.toString(),
            'long': position.longitude.toString(),
          })
        );
        if(response.statusCode == 201){
          final response = await http.get("http://" + ip['ip'] + "/_db/Bachelor/activities_crud/activities");
          if(response.statusCode == 200){
            activities = [];
            var data = json.decode(response.body);
            for(var i = 0; i < data.length; i++){
              if(data[i]['user'] == widget.deviceId){
                activities.add(data[i]);
              }
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Homepage(deviceId: widget.deviceId, activities: this.activities)),
            );
          }
        } else {
          print(response.body);
          //throw Exception('Failed to add activity');
        }
    });
  }

  // STOPWATCH WIDGET
  bool startIsPressed = true;
  bool stopIsPressed = true;
  bool resetIsPressed = true;
  String stopTimeToDisplay = "00:00:00";
  var swatch = Stopwatch();
  final dur = const Duration(seconds: 1);

  void startTimer(){
    Timer(dur, keepRunning);
  }

  void keepRunning(){
    if(swatch.isRunning){
      startTimer();
    }
    setState(() {
      stopTimeToDisplay = swatch.elapsed.inHours.toString().padLeft(2, "0") + ":"
          + (swatch.elapsed.inMinutes%60).toString().padLeft(2, "0") + ":"
          + (swatch.elapsed.inSeconds%60).toString().padLeft(2, "0");
    });
  }

  void startStopwatch(){
    setState(() {
      stopIsPressed = false;
      startIsPressed = false;
      resetIsPressed = true;
    });
    swatch.start();
    startTimer();
  }

  void stopStopwatch(){
    setState(() {
      stopIsPressed = true;
      resetIsPressed = false;
      startIsPressed = true;
    });
    swatch.stop();
  }

  void resetStopwatch(){
    setState(() {
      startIsPressed = true;
      resetIsPressed = true;
    });
    swatch.reset();
    stopTimeToDisplay = "00:00:00";
  }

  Widget stopwatch(){
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: (){
                          this.addActivity();
                        },
                        color: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          "Finish",
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.white
                          ),
                        ),
                      ),
                      RaisedButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Homepage(deviceId: widget.deviceId, activities: widget.activities)),
                          );
                        },
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.white
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                stopTimeToDisplay,
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: stopIsPressed ? null : stopStopwatch,
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 15.0,
                        ),
                        child: Text(
                          "Stop",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      RaisedButton(
                          onPressed: resetIsPressed ? null : resetStopwatch,
                          color: Colors.teal,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 15.0,
                          ),
                          child: Text(
                              "Reset",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                              )
                          )
                      )
                    ],
                  ),
                  RaisedButton(
                      onPressed: (){
                        startIsPressed ? startStopwatch(): null;
                      },
                      color: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 80.0,
                        vertical: 25.0,
                      ),
                      child: Text(
                          "Start",
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.white,
                          )
                      )
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Stopwatch"),
        ),
        body: TabBarView(
          children: <Widget>[
            stopwatch(),
          ],
          controller: tb,
        )
    );
  }
}