import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bachelor_app/views/HomeScreen.dart';

class StopwatchPage extends StatefulWidget {
  final String activityName, deviceId;
  StopwatchPage({Key key, @required this.activityName, this.deviceId}) : super(key: key);

  @override
  _Stopwatch createState() => _Stopwatch();
}

class _Stopwatch extends State<StopwatchPage> with TickerProviderStateMixin {

  TabController tb;
  @override
  void initState() {
    tb = TabController(
      length: 1,
      vsync: this,
    );
    super.initState();
  }

  void addActivity() async {
    final response = await http.post("http://192.168.0.181:8529/_db/Bachelor/activities_crud/activities",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
        body: jsonEncode(<String, String>{
        'user': widget.deviceId,
        'activity': widget.activityName,
        'time': stopTimeToDisplay,
        'date': DateTime.now().toString(),
        'lat': "Hmm",
        'long': "HMM"
      })
    );
    if(response.statusCode == 200){

    } else {
      print(response.body);
      //throw Exception('Failed to add activity');
    }
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

  void test(){
    print("Ha");
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Homepage(deviceId: widget.deviceId,)),
                          );
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
                            MaterialPageRoute(builder: (context) => Homepage(deviceId: widget.deviceId,)),
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
                        test();
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