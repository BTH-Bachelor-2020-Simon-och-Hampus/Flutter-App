import 'package:flutter/material.dart';
import 'dart:async';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bachelor",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() =>_HomepageState();
}

class StopwatchPage extends StatefulWidget {
  @override
  _Stopwatch createState() => _Stopwatch();
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
  }

  Widget activity(){

    String bla = "Acti";

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                child: TextField(
                 decoration: InputDecoration(
                   border: InputBorder.none,
                   hintText: "Enter activity name",
                ),
               ),
              ),
            ],
          ),
          RaisedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StopwatchPage()),
                );
              },
              color: Colors.blue,
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 15.0,
              ),
              child: Text(
                  "Next Page",
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

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      onPressed: startIsPressed ? startStopwatch: null ,
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