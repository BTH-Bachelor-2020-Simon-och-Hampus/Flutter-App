import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:bachelor_app/views/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
String db;

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() =>_StartScreenState();
}
class _StartScreenState extends State<StartScreen> with TickerProviderStateMixin {
  Future<String> getDb() async {
    return await rootBundle.loadString("dbIp.json");
  }

  @override
  void initState(){
    super.initState();
    this.getDeviceId();
  }

  void getDeviceId() async {
    getDb().then((data) async {
      var ip = json.decode(data);
      final response = await http.get("http://" + ip['ip'] + "/_db/Bachelor/user_crud/users");
      if(response.statusCode == 200) {
        var data = json.decode(response.body);
        _getId().then((id) {
          for(var i = 0; i < data.length; i++){
            if(data[i]['_key'] == id){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Homepage(deviceId: id)),
                ModalRoute.withName("/"),
              );
            } else {
              http.post("http://" + ip['ip'] + "/_db/Bachelor/user_crud/users",
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  '_key': id
                }),
              );
            }
          }
        });
      } else {
        throw Exception('Failed to load device id');
      }
    });
  }

  Future<String> _getId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'StartScreen',
      home: new Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Text(
                "Loading",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                )
            )
        ),
      ),
    );
  }
}