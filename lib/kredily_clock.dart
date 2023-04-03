import 'dart:async';
import 'dart:convert';

import 'package:flutter_gsheet/my_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
class KredilyClock{
  var client = http.Client();
  MyController myController=Get.put(MyController());
  getKredily() async {
    String url="https://scaleupallyio.kredily.com";
    var response=await client.get(Uri.parse(url));
    print(response.statusCode);
    if(response.statusCode==200){
      // print(response.headers);
      String rawCookie = response.headers['set-cookie']!;
      var splt=rawCookie.split(";");
      for(var x in splt){
        if(x.contains("csrftoken")){
          var csrfToken=x.split("=")[1];
          loginKredily(csrfToken);
          break;
        }
      }

    }else{
      Fluttertoast.showToast(msg: "Error! please try again");
    }

  }
  loginKredily(String token) async {
    var header={
      "X-CSRFToken":token,
      'Content-Type': 'application/json'
    };
    var data=jsonEncode({
      "email":sharedPreference.get("email"),
      "password":sharedPreference.get("pass")
    });
    print(data);
    var response=await client.post(Uri.parse('https://scaleupallyio.kredily.com/login/'),headers: header,body: data);
    print(response.statusCode);
    print(response.body);
    if(response.statusCode==200) {
      try{
        var json=jsonDecode(response.body);
        if(json['message']['status']=="error"){
          Fluttertoast.showToast(msg: json['message']['validation']);
          myController.loginLoading.value=false;
          return;
        }

        sharedPreference.setString("verified", "true");

        String rawCookie = response.headers['set-cookie']!;
        var splt = rawCookie.split(";");
        var csrfToken;
        var sessionId;
        for (var x in splt) {
          if (x.contains("sessionid")) {
            sessionId = x.split("=")[1];
          }
          if (x.contains("csrftoken")) {
            csrfToken = x.split("=")[1];
          }
        }
        sharedPreference.setString("csrftoken", "$csrfToken");
        sharedPreference.setString("sessionid", "$sessionId");
        getEmpDetails(csrfToken, sessionId);
      }catch(e){
        Fluttertoast.showToast(msg: "Error: ${response.body}");
        myController.loginLoading.value=false;
      }

    }
  }
  getEmpDetails(csrfToken,sessionId) async {
    var header={
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}'
    };

    var response=await http.get(Uri.parse("https://scaleupallyio.kredily.com/attendanceLog/clockingWidgetApi/"),headers: header);
    myController.loadingClockBtn.value=false;
    if(response.statusCode==200){
      print("SSSSSSSSS ${response.statusCode}");
      print("SSSSSSSSS ${response.body}");
      try{
        var json=jsonDecode(response.body);

        myController.streamController.sink.add(true);
        print("inside");

        if(json['attendance_log'].isNotEmpty){
          var lastPunchIn=json['attendance_log'][0]['last_punch_in'];
          if(json['attendance_log'][0]['emp_time_out']==null){
            myController.clockBtnText.value="Clock out";
            var locall=DateTime.parse(lastPunchIn).toLocal();
            startTimer(locall.microsecondsSinceEpoch);
          }
        }
        if(myController.shouldGoForward.value==true){
          print("xxxxxxxxxxxxxxx");
          if(json['attendance_log'].isEmpty){
            setClockin(csrfToken, sessionId);
          }else
          if(json['attendance_log'][0]['emp_time_out']==null){
            // myController.animatedWidth.value=null;
          }else{
            setClockin(csrfToken, sessionId);
          }
        }else{
          print("yyyyyyyyyyyyyyyy");
          // myController.animatedWidth.value=null;
          if(json['attendance_log'].isEmpty){
            return [];
          }
          return [json['attendance_log'][0]['emp_time_out']==null?'loggedIn':'loggedOut'];
        }
        // print(json);
      }catch(e){
        print("CATCHED $e");
        return [];
      }

      // print(json);
      // setClockin(csrfToken,sessionId);
      // setClockOut(csrftoken,sessionid);
    }
  }
  setClockin(csrfToken,sessionId) async {
    var header={
      "X-CSRFToken":'$csrfToken',
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}'
    };
    var response=await http.post(Uri.parse("https://scaleupallyio.kredily.com/attendanceLog/clockIn/"),headers: header);
    print(response.statusCode);
    if(response.statusCode==201){
      //created
      myController.clockBtnText.value="Clock out";
      startTimer(DateTime.now().microsecondsSinceEpoch);
      myController.animatedWidth.value=null;

    }else{
      Fluttertoast.showToast(msg: '${response.body}');
      myController.animatedWidth.value=null;
    }
    print(response.body);
  }
  setClockOut(csrfToken,sessionId) async {
    var header={
      "X-CSRFToken":'$csrfToken',
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}'
    };
    var response=await http.get(Uri.parse("https://scaleupallyio.kredily.com/attendanceLog/clockOut/"),headers: header);
    print(response.statusCode);
    if(response.statusCode==201){
      //created
      myController.clockBtnText.value="Start clock in";
      myController.countDownTime.value='';
      myController.timer!.cancel();
      myController.timer=null;

      myController.animatedWidth.value=null;
    }else{
      Fluttertoast.showToast(msg: '${response.body}');
      myController.animatedWidth.value=null;
    }
    print(response.body);
  }
  startTimer(locall){
    if(myController.timer!=null){
      myController.timer!.cancel();
      myController.timer=null;
    }
    myController.timer=Timer.periodic(Duration(seconds: 1), (timer) {
      var timex=DateTime.now().microsecondsSinceEpoch-locall;
      Duration duration=Duration(microseconds: int.parse('$timex'));
      myController.countDownTime.value='${(duration.inHours).toString().padLeft(2,'0')}:${(duration.inMinutes % 60).toString().padLeft(2,'0')}:${(duration.inSeconds % 60).toString().padLeft(2,'0')}';
    });
  }

  getLeaveStatus(csrfToken,sessionId) async {
    var header={
      "X-CSRFToken":'$csrfToken',
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}'
    };
    var response=await http.get(Uri.parse('https://scaleupallyio.kredily.com/leave-request/leave_accrual_user/'),headers: header);
    // print(response.body);
    var json=jsonDecode(response.body);
    return json['leave_bal_json_data'];
  }
}