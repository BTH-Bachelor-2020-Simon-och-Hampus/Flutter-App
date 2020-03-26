import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bachelor_app/views/HomeScreen.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
String db;
String activityKey;
bool startIsPressed = true;
bool stopIsPressed = true;
bool resetIsPressed = true;
String stopTimeToDisplay = "00:00:00";
var swatch = Stopwatch();
final dur = const Duration(seconds: 1);

//void callbackDispatcher() {
//  Workmanager.executeTask((task, inputData) {
//    print("Notice activated");
//    return null;
//  });
//}

class StopwatchPage extends StatefulWidget {
  final String activityName, deviceId, activityKey, activityTime;
  final List<Map<String, dynamic>> activities;
  StopwatchPage({Key key, @required this.activityName, this.deviceId, this.activities, this.activityKey, this.activityTime}) : super(key: key);

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
    if(widget.activityTime != null){
      stopTimeToDisplay = widget.activityTime;

    }
//    if(WidgetsBinding.instance == null)
//      WidgetsFlutterBinding();
//    Workmanager.initialize(
//        callbackDispatcher, // The top level function, aka callbackDispatcher
//        isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
//    );
    super.initState();
  }

  List<Map<String, dynamic>> activities = [];
  void addActivity(status) async {
    getDb().then((data) async {
      var ip = json.decode(data);
      if(widget.activityKey == null) {
        Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
              'status': status
            })
        );
        if(response.statusCode == 201 && status == "finished"){
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
        }
      } else {
        this.updateActivity(status);
      }
    });
  }

  void updateActivity(status) async {
    getDb().then((data) async {
      var ip = json.decode(data);
      final response = await http.patch("http://" + ip['ip'] + "/_db/Bachelor/activities_crud/activities/" + widget.activityKey,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'status': status,
            'time': stopTimeToDisplay
          })
      );
      if(response.statusCode != 201){
        print("Error updating activity");
      }
    });
  }

  // STOPWATCH WIDGET
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
    return new Scaffold(
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Expanded(
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
                            this.addActivity("finised");
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
                            Workmanager.cancelAll();
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
            new Expanded(
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
            new Expanded(
              flex: 8,
              child: new Container(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: (){
                            this.updateActivity("stopped");
                            stopIsPressed ? null : stopStopwatch();
                          },
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
                          this.addActivity("started");
                          startIsPressed ? startStopwatch() : null;
//                          Workmanager.registerPeriodicTask(
//                            "1",
//                            "Duration",
//                            initialDelay: Duration(seconds: 10),
//                            frequency: Duration(minutes: 15),
//                          );
                        },
                        color: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 50.0,
                          vertical: 15.0,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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