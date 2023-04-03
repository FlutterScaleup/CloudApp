import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ApplyLeave extends StatefulWidget {
  String type;
  ApplyLeave({Key? key,required this.type}) : super(key: key);

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  TextEditingController textEditingController=TextEditingController();
  String dropdownValue = 'First Half';
  String dropdownValue2 = 'First Half';
  String startDate="Start Date";
  String endDate="End Date";


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Apply Leave",style: TextStyle(fontWeight: FontWeight.bold)),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
            Text("Leave Type",style: TextStyle(color: Colors.grey,fontSize: 16,fontWeight: FontWeight.bold)),
            SizedBox(height: 4,),
            Text(widget.type,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),),
            SizedBox(height: 16,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Start Date",style: TextStyle(color: Colors.grey,fontSize: 16,fontWeight: FontWeight.bold)),
                    SizedBox(height: 4,),
                    InkWell(onTap: (){
                      selectDateFunc('d1');
                    },child: Container(padding: EdgeInsets.only(left: 16,right: 16,top: 12,bottom: 12),decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10)),child: Text(startDate,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),))),
                  ],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Half",style: TextStyle(color: Colors.grey,fontSize: 16,fontWeight: FontWeight.bold)),
                    SizedBox(height: 4,),
                    Container(padding: EdgeInsets.only(left: 16,right: 16),decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10)),child:
                    dropDown(dropdownValue,'d1')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("End Date",style: TextStyle(color: Colors.grey,fontSize: 16,fontWeight: FontWeight.bold)),
                    SizedBox(height: 4,),
                    InkWell(onTap: (){
                      selectDateFunc('d2');
                    },child: Container(padding: EdgeInsets.only(left: 16,right: 16,top: 12,bottom: 12),decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10)),child: Text(endDate,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),))),
                  ],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Half",style: TextStyle(color: Colors.grey,fontSize: 16,fontWeight: FontWeight.bold)),
                    SizedBox(height: 4,),
                    Container(padding: EdgeInsets.only(left: 16,right: 16,),decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10)),child:
                    dropDown(dropdownValue2,'d2')),
                  ],
                )
              ],
            ),

            SizedBox(height: 32,),
            Text("Write your Reason",style: TextStyle(color: Colors.grey,fontSize: 16,fontWeight: FontWeight.bold)),
            Container(margin: EdgeInsets.only(top: 4),padding: EdgeInsets.only(left: 16,right: 16),decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(10) ),child: TextField(controller: textEditingController,minLines: 4,maxLines: 10,decoration: InputDecoration(border: InputBorder.none,hintText: "Reason....",hintStyle: TextStyle()),style: TextStyle())),
            SizedBox(height: 32,),
            Row(children: [
              Expanded(child: InkWell(onTap: (){
                // onSubmit();
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
            ],)
          ],),
        ),
      ),
    );
  }
  selectDateFunc(from){
    var initialDate=DateTime.now();
    var firstDate=DateTime.now().subtract(Duration(days: 365));
    if(startDate=="Start Date" && from=='d2'){
      Fluttertoast.showToast(msg: "Select start date first");
      return;
    }
    if(startDate!="Start Date" && from=="d2"){
      initialDate=DateFormat('dd-MMMM-yyyy').parse(startDate);
      firstDate=DateFormat('dd-MMMM-yyyy').parse(startDate);
      print(initialDate);
      print(DateTime.now());
    }

    showDatePicker(context: context, initialDate: initialDate, firstDate: firstDate, lastDate: DateTime.now().add(Duration(days: 365))).then((value){
      if(value!=null){
        String now = DateFormat('dd-MMMM-yyyy').format(value);
        if(from=='d1'){
          startDate=now;
          endDate="End Date";
        }else{
          endDate=now;
        }
        setState(() {
        });
      }
    });
  }
  dropDown(value,from){
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        items: <String>['First Half', 'Second Half']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            value = newValue!;
            if(from=='d1'){
              dropdownValue=value;
            }else{
              dropdownValue2=value;
            }
          });
        },
      ),
    );
  }
}
