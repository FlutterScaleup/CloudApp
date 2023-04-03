import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gsheet/kredily_clock.dart';
import 'package:flutter_gsheet/leave_page.dart';
import 'package:flutter_gsheet/login_page.dart';
import 'package:flutter_gsheet/my_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class HelloPage extends StatefulWidget {
  const HelloPage({Key? key}) : super(key: key);

  @override
  State<HelloPage> createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  // late SharedPreferences sharedPreference;

  var csrfToken;
  var sessionId;
  MyController myController=Get.put(MyController());
  // var animatedWidth;


  @override
  void initState() {
    super.initState();
    csrfToken=sharedPreference.get("csrftoken");
    sessionId=sharedPreference.get("sessionid");
    getInitialData();
  }
  getInitialData() async {
    List value=await KredilyClock().getEmpDetails(csrfToken, sessionId);
    print(value);
    if(value.isEmpty){
      KredilyClock().getKredily();
    }
  }


  @override
  void dispose() {
    if(myController.timer!=null){
      myController.timer!.cancel();
      myController.timer=null;
    }
    super.dispose();
  }

  clocking() async {
    if(myController.animatedWidth.value==50){
      return;
    }
    myController.animatedWidth.value=50;

    if(csrfToken!=null){
      List value=await KredilyClock().getEmpDetails(csrfToken, sessionId);
      if(value.isEmpty){
        myController.shouldGoForward.value=true;
        KredilyClock().getKredily();
      }
      if(value.contains("loggedIn")){
        KredilyClock().setClockOut(csrfToken, sessionId);
      }else if(value.contains("loggedOut")){
        KredilyClock().setClockin(csrfToken, sessionId);
      }
    }else{
      myController.shouldGoForward.value=true;
      KredilyClock().getKredily();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Icon(Icons.waving_hand_rounded,color: Colors.yellow,),
      title: Text("Hello, ${sharedPreference.get("email")!=null?sharedPreference.get("email").toString().split("@")[0].split(".")[0].capitalizeFirst:''}",style: TextStyle(fontWeight: FontWeight.bold),)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: Material(elevation: 0,borderRadius: BorderRadius.circular(16),
                    child: Container(padding: EdgeInsets.all(16),decoration: BoxDecoration(color: Colors.deepOrange[100],borderRadius: BorderRadius.circular(16)),child:
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Align(alignment: Alignment.centerRight,child: SizedBox(height: 120,width: 120,child: Image.asset("assets/detect.png"),)),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                          const Text("Recognition Clock in",style: TextStyle(color: Colors.deepOrangeAccent,fontSize: 24,fontWeight: FontWeight.bold),),
                          SizedBox(height: 16,),
                          SizedBox(width: MediaQuery.of(context).size.width/2,child: Text("Find out if the person you are thinking about are doing the same right now",style: TextStyle(color: Colors.deepOrangeAccent[200]),)),
                          SizedBox(height: 16,),
                          Row(
                            children: [
                              Obx(() => myController.loadingClockBtn.value==true?
                                  Container(padding: EdgeInsets.only(top: 8,bottom: 8),child: Text(""),)
                                  :InkWell(onTap: (){
                                clocking();
                              },child: Material(elevation: 2,borderRadius: BorderRadius.circular(16),child:
                              Container(width: myController.animatedWidth.value,padding: EdgeInsets.only(top: 8,bottom: 8,left: 16,right: 16),
                                child: Obx(() =>
                                myController.animatedWidth.value!=null?SizedBox(height: 20,child: CircularProgressIndicator(color: myController.clockBtnText.value=="Clock out"?Colors.white:Colors.red,),):
                                    Text(myController.clockBtnText.value,style: TextStyle(color: myController.clockBtnText.value=="Clock out"?Colors.white:Colors.deepOrangeAccent,fontWeight: FontWeight.bold))
                                ),decoration: BoxDecoration(color: myController.clockBtnText.value=="Clock out"?Colors.red:Colors.white,borderRadius: BorderRadius.circular(16)), )))),
                              SizedBox(width: 36,),
                              Obx(() => Text('${myController.countDownTime.value}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 16),))
                            ],
                          ),


                        ],),

                      ],
                    ),),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                Expanded(
                  child: Material(elevation: 0,borderRadius: BorderRadius.circular(16),
                    child: Container(padding: EdgeInsets.all(16),decoration: BoxDecoration(color: Colors.purple[100],borderRadius: BorderRadius.circular(16)),child:
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Align(alignment: Alignment.centerRight,child: SizedBox(height: 100,width: 100,child: Image.asset("assets/scaleup.png"),)),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                          Text("Hour log update",style: TextStyle(color: Colors.purpleAccent,fontSize: 24,fontWeight: FontWeight.bold),),
                          SizedBox(height: 16,),
                          SizedBox(width: MediaQuery.of(context).size.width/2,child: Text("Find out if the person you are thinking about are doing the same right now",style: TextStyle(color: Colors.purpleAccent[200]),)),
                          SizedBox(height: 16,),
                          InkWell(onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (builder)=>MyHomePage(title: "Hours Log")));
                          },child: Material(elevation: 2,borderRadius: BorderRadius.circular(16),child: Container(padding: EdgeInsets.only(top: 8,bottom: 8,left: 16,right: 16),child: Text("New hour log",style: TextStyle(color: Colors.purpleAccent,fontWeight: FontWeight.bold)),decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(16)),)))
                        ],),
                      ],
                    ),),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                Expanded(
                  child: Material(elevation: 0,borderRadius: BorderRadius.circular(16),
                    child: Container(padding: EdgeInsets.all(16),decoration: BoxDecoration(color: Colors.blue[100],borderRadius: BorderRadius.circular(16)),child:
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Align(alignment: Alignment.centerRight,child: SizedBox(height: 100,width: 100,child: Image.asset("assets/leave.png"),)),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                          Text("Emotions log",style: TextStyle(color: Colors.blueAccent,fontSize: 24,fontWeight: FontWeight.bold),),
                          SizedBox(height: 16,),
                          SizedBox(width: MediaQuery.of(context).size.width/2,child: Text("Find out if the person you are thinking about are doing the same right now",style: TextStyle(color: Colors.blueAccent[200]),)),
                          SizedBox(height: 16,),
                          InkWell(onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (builder)=>LeavePage(csrfToken: csrfToken,sessionId: sessionId,)));
                          },child: Material(elevation: 2,borderRadius: BorderRadius.circular(16),child: Container(padding: EdgeInsets.only(top: 8,bottom: 8,left: 16,right: 16),child: Text("Apply leave",style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold)),decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(16)),)))
                        ],),
                      ],
                    ),),
                  ),
                ),
              ],
            )
          ],),
        ),
      ),
    );
  }
}
