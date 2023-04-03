import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gsheet/hello_page.dart';
import 'package:flutter_gsheet/onBoard/on_board_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

const credential=r''' 
  {
  "type": "service_account",
  "project_id": "myspreadsheet-381908",
  "private_key_id": "5a247c08321454e70eec2cebfbb962ae64b326a8",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCxxXEznqdC+XZM\nSTuDW3IDiYJyPVs8ZeX1IJnJ4Fz7hpF79+sguHzICV5Dgf0zCYJnilY+yoLpl62J\nK6FA9fTq2cWS70zQPsJXPw9kiwkCyV4D1MuwdWDuVglQ0anxe3KwCVec2QMshpv4\nvgjZx6rEPTiXWh+Syn9vzIyJF4M0at6aCQHk8Qh1CHgIqrL1B/XhVtgUGIY5HE2x\nE/kBO5UQCu9BRx3HuWmv49Xa8rOnztiZuaVpWGgnUPDNUfUp3kEhrkGtTDB7GlMb\nly7q47QIMCqAtBFdC1K4WL04mCaS4yAtEtwORh2CAEAbbVfn3VMc0fINVSGGuqBW\nwPCieGmLAgMBAAECggEAEasHbLN0eT4U6VEP9qa0hrB4hAUgF7ki6UFzt3Iym5cM\nx47k0gwz7qertDbrpNJpoQPJPZVf/HpkN3FcJfor/Nlm/wsEjd/m7cfpLjt5Sksc\nKnJQSjnoR9fKNjuYUdVMmT1cdUzGOXspbkfo1kg3ayiQgs5ku/CfSMvCHe/1zNQ1\n4QfO4yxlAFhqprw4FbC4b1/FvImt8dWGZQRjVxunMTdzLnYxTTL1wuVZpHiwCT4+\nPBiViNXllN2+bMFdOaNUu1OenEYtiFMDbnhPYRBOmCKeLypAtSCTf8UQLqSbMRfy\nq7qv90aIwuOJCackZdKQTGLt8Qs9dUCK4TLe+3jWdQKBgQDZUKM/w8FaIFqcmuEO\nveY5u80nTmiWJXIRORePcH+4QjSbuQZDl2+wu09r9jGIGuXcDh+D62yPQgflV1mX\nDINiS+/AX365Ix5wRktrqNgHFarnJUNgJ77uoVqKt3qmz8T5cu8ERo7I3i974y7c\nuvwAwG+nvSpp4IlmjZnixJjHZQKBgQDRar0cyF69S7ilXJP69eqHav9rE2mG9d/g\nNAonhFB5lrqVF9UDo0xCUzKCJojoWFTVs105yMbJrNBVd+eB5mM1MnIzaNnz1ffE\n03V4GJLaG9bc+z+lqGfb2iE830si5qluQGeS7DqFxYuiqs4hrw2chw7bV5uOYaDS\nRZh5uGK2LwKBgQCrEWVRHsIoNmvd97XOqwJ+1C2NEZYXC+cdU7oOOlrwK33KT/50\nWtObZfgBXs5i+/mSHrQEXuEYbLxWd0qZM0qBqJFU+FeDWffuHgfk+gcEnLPqPVUq\nbl9I7k+d/w1YHxpJ24X38asYyH7MoWwUakVSOioq+yhWLGE9D57h+iziWQKBgBzi\nGukwXZjAK9xq02Imrs00nbvX9pMNsG4M32Wp4yuR9XQA0Hlq+WagcPPwequJG1JK\nJc6FeZ1xP166ZezNqNs6dPPQP1dZKI42GBqTURXSByV9Zb7kZka1ZCYwKf3LUI0L\nRv3FpSC0KVkrM7kDmt3+5rar86GEp5i4zpnjK4IzAoGBAI+PdOSU/tAH8t9jn+9Q\nnF+Y+Hfg7xZc+UT0Fy3ISJ1ockXLBFaPgXUQLevV2UenERxhKzjFhRC56TBcbfWi\n3zZBNWKb+L88iNqH97b8JRBWL5CpTOOmHTNrW/qi3JTsmn95diIuAtERSc0Rnjpg\nkmiphw5oawHb6dY8cVVbNqIS\n-----END PRIVATE KEY-----\n",
  "client_email": "flutter-gsheets@myspreadsheet-381908.iam.gserviceaccount.com",
  "client_id": "116491668632362320015",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-gsheets%40myspreadsheet-381908.iam.gserviceaccount.com"
}
''';

var spreadSheetId="1TRjzU-PAkm3_rQJpmL1aWo4r-jJDh200XlmAVfvZukI";
var spreadSheet;
late SharedPreferences sharedPreference;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreference = await SharedPreferences.getInstance();
  print(sharedPreference.get("verified"));
  final gsheets = GSheets(credential);
  spreadSheet =await gsheets.spreadsheet(spreadSheetId);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true
      ),
      // home: const MyHomePage(title: 'Hours Log'),
      // home: OnboardScreen(),
      home: sharedPreference.get("verified")==null || sharedPreference.getString("verified")!.isEmpty?LoginPage():const HelloPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String now='Select Date';
  List<SelectedListItem> selectedMemberList=[];
  String selectedMemberValue="Member Name";
  List<SelectedListItem> selectedProjectList=[];
  String selectedProjectValue="Project Name";
  List<SelectedListItem> selectedTaskList=[];
  String selectedTaskValue="Category of Task";
  List<SelectedListItem> selectedHourList=[];
  String selectedHourValue="Time (in hrs)";
  TextEditingController textEditingController=TextEditingController();
  // late SharedPreferences sharedPrefrence;
  bool isLoading=true;




  @override
  void initState() {
    super.initState();
    var justNow=DateTime.now();
    now = DateFormat('dd-MMMM-yyyy').format(justNow);

    getInitalData();
  }

  getInitalData() async {
    // sharedPrefrence = await SharedPreferences.getInstance();
    var member=sharedPreference.get("member");
    print("Memberrrr $member");
    if(member!=null){
      selectedMemberValue=member.toString();
    }
    Worksheet sheet=spreadSheet.worksheetByTitle("Data sheet");
    print(await sheet.values.columnByKey("Project Name"));
    var itemsMember=(await sheet.values.columnByKey("Team Member Name"))!;
    var itemsProject=(await sheet.values.columnByKey("Project Name"))!;
    var itemsTask=(await sheet.values.columnByKey("Category of Task"))!;
    var itemsHours=(await sheet.values.columnByKey("Hours"))!;
    for(String x in itemsMember){
      selectedMemberList.add(SelectedListItem(name: x));
    }
    for(String x in itemsProject){
      selectedProjectList.add(SelectedListItem(name: x));
    }
    for(String x in itemsTask){
      selectedTaskList.add(SelectedListItem(name: x));
    }
    for(String x in itemsHours){
      selectedHourList.add(SelectedListItem(name: x));
    }
    isLoading=false;
    setState(() {
    });
  }
  sheetWork()async{
    var sheet=spreadSheet.worksheetByTitle("Worksheet1");
    print(sheet);
    // await sheet!.values.insertValue('koko', column: 1, row: 1);
    // await sheet.values.insertColumn(7, ['qwer']);
    var allRow=await sheet!.values.allRows();
    // print(allRow.length);
    await sheet.values.insertRow(allRow.length+1, [now,selectedMemberValue,selectedProjectValue,selectedTaskValue,textEditingController.text,selectedHourValue]);

    textEditingController.text='';
    selectedProjectValue="Project Name";
    selectedTaskValue="Category of Task";
    selectedHourValue="Time (in hrs)";
    setState(() {
    });
    Fluttertoast.showToast(msg: "Hours Log Updated Successfully");
  }
  onSubmit(){
    if(selectedMemberValue=="Member Name"){
      Fluttertoast.showToast(msg: "Select Member Name");
      return;
    }
    if(selectedProjectValue=="Project Name"){
      Fluttertoast.showToast(msg: "Select Project Name");
      return;
    }
    if(selectedTaskValue=="Category of Task"){
      Fluttertoast.showToast(msg: "Select Category of Task");
      return;
    }
    if(selectedHourValue=="Time (in hrs)"){
      Fluttertoast.showToast(msg: "Select Time (in hrs)");
      return;
    }
    if(textEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Write Work description");
      return;
    }
    sheetWork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading==true?Center(child: CircularProgressIndicator(color: Colors.red,)):SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Row(children: [
              Expanded(child: InkWell(onTap: (){
                showDate();
              },child: Container(padding: EdgeInsets.all(16),decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10)),child: Text('$now',style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),)))
            ],),
            SizedBox(height: 16,),

            Row(children: [
              Expanded(child: InkWell(onTap: (){
                showMember();
              },
                child: Container(alignment: Alignment.center,decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10)),child: Row(mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(selectedMemberValue,style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                    ),
                    Icon(Icons.arrow_drop_down,color: Colors.black,)
                  ],
                ),),
              ))
            ],),
            SizedBox(height: 16,),
            Row(children: [
              Expanded(child: InkWell(onTap: (){
                showProject();
              },
                child: Container(alignment: Alignment.center,decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10)),child: Row(mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(selectedProjectValue,style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                    ),
                    Icon(Icons.arrow_drop_down,color: Colors.black,)
                  ],
                ),),
              ))
            ],),
            SizedBox(height: 16,),
            Row(children: [
              Expanded(child: InkWell(onTap: (){
                showTask();
              },
                child: Container(alignment: Alignment.center,decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10)),child: Row(mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(selectedTaskValue,style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                    ),
                    Icon(Icons.arrow_drop_down,color: Colors.black,)
                  ],
                ),),
              ))
            ],),

            SizedBox(height: 16,),
            Row(children: [
              Expanded(child: InkWell(onTap: (){
                showHours();
              },
                child: Container(alignment: Alignment.center,decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10)),child: Row(mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(selectedHourValue,style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                    ),
                    Icon(Icons.arrow_drop_down,color: Colors.black,)
                  ],
                ),),
              ))
            ],),
            SizedBox(height: 16,),
            Container(padding: EdgeInsets.only(left: 16,right: 16),decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10) ),child: TextField(controller: textEditingController,minLines: 4,maxLines: 10,decoration: InputDecoration(border: InputBorder.none,hintText: "Work description",hintStyle: TextStyle()),style: TextStyle())),

            SizedBox(height: 16,),
            Row(children: [
              Expanded(child: InkWell(onTap: (){
                onSubmit();
              },
                child: Container(alignment: Alignment.center,decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(10)),child: Row(mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("SUBMIT",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                    ),
                  ],
                ),),
              ))
            ],),

          ],),
        ),
      ),
    );
  }
  showMember(){
    DropDownState(
      DropDown(
        bottomSheetTitle: Text(
          'Select Member',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        submitButtonChild: const Text(
          'Done',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        data: selectedMemberList,
        // data: widget.cities ?? [],
        selectedItems: (List<dynamic> selectedList) {
          List<String> list = [];
          for(var item in selectedList) {
            if(item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedMemberValue=list.first;
          setState(() {
          });
          sharedPreference.setString("member", selectedMemberValue);
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }
  showProject(){
    DropDownState(
      DropDown(
        bottomSheetTitle: Text(
          'Select Project',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        submitButtonChild: const Text(
          'Done',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        data: selectedProjectList,
        // data: widget.cities ?? [],
        selectedItems: (List<dynamic> selectedList) {
          List<String> list = [];
          for(var item in selectedList) {
            if(item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedProjectValue=list.first;
          setState(() {
          });
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }
  showTask(){
    DropDownState(
      DropDown(
        bottomSheetTitle: Text(
          'Select Category of Task',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        submitButtonChild: const Text(
          'Done',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        data: selectedTaskList,
        // data: widget.cities ?? [],
        selectedItems: (List<dynamic> selectedList) {
          List<String> list = [];
          for(var item in selectedList) {
            if(item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedTaskValue=list.first;
          setState(() {
          });
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }
  showHours(){
    DropDownState(
      DropDown(
        bottomSheetTitle: Text(
          'Time (in hours)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        submitButtonChild: const Text(
          'Done',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        data: selectedHourList,
        // data: widget.cities ?? [],
        selectedItems: (List<dynamic> selectedList) {
          List<String> list = [];
          for(var item in selectedList) {
            if(item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedHourValue=list.first;
          setState(() {
          });
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }
  
  showDate()async {
    var selectedDate=await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(Duration(days: 365)), lastDate: DateTime.now());
    if(selectedDate!=null){
      now = DateFormat('dd-MMMM-yyyy').format(selectedDate);
    }
    setState(() {
    });
  }
}