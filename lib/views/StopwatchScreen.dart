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
String currentTime = "00:00:00";
int currentTimeMinutes = 0, currentTimeHours = 0;
String currentKey = "";
var swatch = Stopwatch();
final dur = const Duration(seconds: 1);

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    print("Background called yo");
    return Future.value(true);
  });
}

class StopwatchPage extends StatefulWidget {
  final String activityName, deviceId, activityKey, activityTime, activityStatus, activityDate;
  StopwatchPage({Key key, @required this.activityName, this.deviceId, this.activityKey, this.activityTime, this.activityStatus, this.activityDate}) : super(key: key);

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
      currentTime = widget.activityTime;
      currentKey = widget.activityKey;
      if(widget.activityStatus == "started"){
        currentTime = "0" + ((DateTime.now().difference(DateTime.parse(widget.activityDate))).toString()).substring(0,7);
        currentTimeMinutes = int.parse(currentTime.substring(3,5));
        currentTimeHours = int.parse(currentTime.substring(0,2));
        this.startStopwatch();
      }
    }
    if(WidgetsBinding.instance == null)
      WidgetsFlutterBinding();
    Workmanager.initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
    super.initState();
  }

  void addActivity(status) async {
    getDb().then((data) async {
      var ip = json.decode(data);
      if(widget.activityKey == null && currentKey == "") {
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
        currentKey = json.decode(response.body)['_key'];
      } else if(status != "finished") {
        this.updateActivity(status);
      }
      if(status == "finished"){
        this.resetStopwatch();
        currentKey = "";
        Workmanager.cancelAll();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Homepage(deviceId: widget.deviceId)),
        );
      }
    });
  }

  void updateActivity(status) async {
    getDb().then((data) async {
      var ip = json.decode(data);
      if(status != "reset" && status != "finished"){
        final response = await http.patch("http://" + ip['ip'] + "/_db/Bachelor/activities_crud/activities/" + currentKey,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'status': status,
              'time': stopTimeToDisplay
            })
        );
        if(response.statusCode != 200){
          print("Error updating activity");
        }
      } else if(status == "reset"){
        final response = await http.patch("http://" + ip['ip'] + "/_db/Bachelor/activities_crud/activities/" + currentKey,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'status': "stopped",
              'time': "00:00:00"
            })
        );
        currentTime = "00:00:00";
        if(response.statusCode != 200){
          print("Error updating activity");
        }
      } else if(status == "finished"){
        final response = await http.patch("http://" + ip['ip'] + "/_db/Bachelor/activities_crud/activities/" + currentKey,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'status': status,
              'time': stopTimeToDisplay
            })
        );
        if(response.statusCode == 200){
          this.addActivity("finished");
        }
      }
    });
  }

  void removeActivity() async {
    getDb().then((data) async {
      var ip = json.decode(data);
      print(currentKey);
      final response = await http.delete("http://" + ip['ip'] + "/_db/Bachelor/activities_crud/activities/" + currentKey);
        if(response.statusCode != 204){
          print("Error deleting activity");
        } else {
          this.resetStopwatch();
          currentKey = "";
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Homepage(deviceId: widget.deviceId)),
          );
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
    if(widget.activityTime != null){
      if(swatch.elapsed.inSeconds+int.parse(currentTime.substring(6,8)) == 60){
        print("Hello");
        currentTimeMinutes++;
      }
      if(currentTimeMinutes == 60){
        currentTimeHours++;
      }
      setState(() {
        stopTimeToDisplay = (currentTimeHours).toString().padLeft(2, "0") + ":"
            + (currentTimeMinutes).toString().padLeft(2, "0") + ":"
            + ((swatch.elapsed.inSeconds+int.parse(currentTime.substring(6,8)))%60).toString().padLeft(2, "0");
      });
    } else {
      setState(() {
        stopTimeToDisplay = (swatch.elapsed.inHours).toString().padLeft(2, "0") + ":"
            + ((swatch.elapsed.inMinutes%60)).toString().padLeft(2, "0") + ":"
            + ((swatch.elapsed.inSeconds%60)).toString().padLeft(2, "0");
      });
    }
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
    currentTime = "00:00:00";
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
                            Workmanager.cancelAll();
                            this.stopStopwatch();
                            this.updateActivity("finished");
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
                            this.stopStopwatch();
                            this.removeActivity();
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
                            onPressed: (){
                              resetIsPressed ? null : resetStopwatch();
                              this.updateActivity("reset");
                            },
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
                          Workmanager.registerPeriodicTask(
                            "1",
                            "Duration",
                            frequency: Duration(minutes: 15),
                          );
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