import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gsheet/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';

class HoursLogScreenBi extends StatefulWidget {
  const HoursLogScreenBi({super.key, required this.title});

  final String title;

  @override
  State<HoursLogScreenBi> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HoursLogScreenBi> {
  String now = 'Select Date';
  List<SelectedListItem> selectedMemberList = [];
  String selectedMemberValue = "Member Name";
  List<SelectedListItem> selectedProjectList = [];
  String selectedProjectValue = "Project Name";
  List<SelectedListItem> selectedReportList = [];

  // String selectedReportValue = "Report Name";
  List<SelectedListItem> selectedTaskList = [];
  String selectedTaskValue = "Category of Task";
  String selectedStatustValue = "Status of Task";
  List<SelectedListItem> selectedStatusList = [];
  List<SelectedListItem> selectedSubTaskList = [];
  String selectedSubTaskValue = "Sub Category of Task";
  List<SelectedListItem> selectedHourList = [];
  RxString selectedHourValue = "Start Time".obs;
  TimeOfDay selectedTime = TimeOfDay.now();

  RxString selectedEndHourValue = "End Time".obs;
  TimeOfDay selectedEndTime = TimeOfDay.now();

  Duration? difference;
  Duration? globalSelectedDuration;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textReportValueController = TextEditingController();

  // late SharedPreferences sharedPrefrence;
  RxBool isLoading = false.obs;
  List list = [];
  bool progress = false;
  DateTime? startHourDateTime, EndHourDateTime;

  RxString totalHours = "".obs;

  // var coreTasKIDList;
  // var helpTasKIDList;
  // var rnDTaskIDList;
  // var otherTaskIDList;
  // var leisureTaskIDList;

  getdata() async {
    var dataSaved = await sharedPreference.get("saveDataToBI") ?? false;
    if (dataSaved == true) {
      getDataFromHive();
    } else {
      getInitialData();
    }
  }

  @override
  void initState() {
    super.initState();
    // var justNow = DateTime.now();
    // now = DateFormat('dd-MMMM-yyyy').format(justNow);
    getdata();
  }

  getdatass() async {
    Worksheet sheet = spreadSheetBI.worksheetByTitle("Sheet1");
    var allRow = await sheet.values.allRows();
    log(allRow.last.toString());
    // final cell = await sheet.cells.cell(column: 2, row:12);
    // log(cell.value.toString());

    // get first row as List of Cell objects
    // final cellsRow = await sheet.cells.row(7);
    // print(cellsRow);
    // update each cell's value by adding char '_' at the beginning
    // cellsRow.forEach((cell) => cell.value = '_${cell.value}');
    // actually updating sheets cells
    // await sheet.cells.insert(cellsRow);
    // prints [_index, _letter, _number, _label]
    // print(await sheet.values.row(7));
    // print(await sheet.values.map.columnByKey('Name', mapTo: 'Date'));
    // print(await sheet.values.insertRow(1, [
    //   "Name",
    //   "Date",
    //   "Project",
    //   "Report Name",
    //   "Category of Task",
    //   "Sub Category of Task",
    //   "Start Time",
    //   "End Time",
    // ]));

    // sheet.values.allRows().then((value) {
    //   log(value.toString());
    // });
  }

  getDataFromHive() async {
    isLoading.value = true;
    var member = await sharedPreference.get("member");
    if (member != null) {
      selectedMemberValue = member.toString();
    }
    var itemsMember = await sharedPreference.getStringList("itemMember")!;
    var itemsProject = await sharedPreference.getStringList("itemProject")!;
    var itemsReportName =
        await sharedPreference.getStringList("itemReportName")!;
    var itemsTask = await sharedPreference.getStringList("itemTask")!;
    // coreTasKIDList = await sharedPreference.getStringList("coreTasKIDList")!;
    // helpTasKIDList = await sharedPreference.getStringList("helpTasKIDList")!;
    // rnDTaskIDList = await sharedPreference.getStringList("rnDTaskIDList")!;
    // otherTaskIDList = await sharedPreference.getStringList("otherTaskIDList")!;
    // leisureTaskIDList =await sharedPreference.getStringList("leisureTaskIDList")!;

    if (selectedMemberValue == "Member Name") {
      var emailList = await sharedPreference.getStringList("emailList")!;
      if (sharedPreference.get("email") != null &&
          sharedPreference.get("email").toString().isNotEmpty) {
        if (emailList.contains(sharedPreference.get("email"))) {
          String email = sharedPreference.get("email").toString();
          var index = emailList.indexOf(email);
          selectedMemberValue = itemsMember[index];
          await sharedPreference.setString("member", selectedMemberValue);
        }
      }
    }
    for (String x in itemsMember) {
      selectedMemberList.add(SelectedListItem(name: x));
    }

    print('selectedMemberList:${selectedMemberList.length}');
    for (String x in itemsProject) {
      selectedProjectList.add(SelectedListItem(name: x));
    }
    for (String x in itemsReportName) {
      selectedReportList.add(SelectedListItem(name: x));
    }
    for (String x in itemsTask) {
      selectedTaskList.add(SelectedListItem(name: x));
    }
    selectedStatusList.addAll([
      SelectedListItem(name: "Completed"),
      SelectedListItem(name: "In Progress"),
      SelectedListItem(name: "On Hold"),
    ]);
    isLoading.value = false;
    setState(() {});
  }

  getInitialData() async {
    try {
      isLoading.value = true;

      selectedMemberList = [];
      selectedProjectList = [];
      selectedReportList = [];
      selectedTaskList = [];
      selectedStatusList = [];
      selectedSubTaskList = [];
      selectedHourList = [];

      var member = await sharedPreference.get("member");
      if (member != null) {
        selectedMemberValue = member.toString();
      }
      Worksheet sheet = spreadSheetBI.worksheetByTitle("Sheet6");
      var itemsMember = (await sheet.values.columnByKey("Name"))!;
      var itemsProject =
          (await sheet.values.columnByKey("Client/Project Name"))!;
      var itemsReportName = (await sheet.values.columnByKey("Report Name"))!;
      var itemsTask = (await sheet.values.columnByKey("Task Type"))!;
      // coreTasKIDList = (await sheet.values.columnByKey("Core Task ID"))!;
      // helpTasKIDList = (await sheet.values.columnByKey("Help Task ID"))!;
      // rnDTaskIDList = (await sheet.values.columnByKey("R&D Task ID"))!;
      // otherTaskIDList =(await sheet.values.columnByKey("Other Work-Related Task ID"))!;
      // leisureTaskIDList = (await sheet.values.columnByKey("Leisure Task ID"))!;
      await sharedPreference.setStringList("itemMember", itemsMember);
      await sharedPreference.setStringList("itemProject", itemsProject);
      await sharedPreference.setStringList("itemReportName", itemsReportName);
      await sharedPreference.setStringList("itemTask", itemsTask);
      // await sharedPreference.setStringList("coreTasKIDList", coreTasKIDList);
      // await sharedPreference.setStringList("helpTasKIDList", helpTasKIDList);
      // await sharedPreference.setStringList("rnDTaskIDList", rnDTaskIDList);
      // await sharedPreference.setStringList("otherTaskIDList", otherTaskIDList);
      // await sharedPreference.setStringList("leisureTaskIDList", leisureTaskIDList);

      if (selectedMemberValue == "Member Name") {
        var emailList = (await sheet.values.columnByKey("Email"))!;
        await sharedPreference.setStringList("emailList", emailList);
        if (sharedPreference.get("email") != null &&
            sharedPreference.get("email").toString().isNotEmpty) {
          if (emailList.contains(sharedPreference.get("email"))) {
            String email = await sharedPreference.get("email").toString();
            var index = emailList.indexOf(email);
            selectedMemberValue = itemsMember[index];
            await sharedPreference.setString("member", selectedMemberValue);
          }
        }
      }

      // saveFile(itemsMember);
      for (String x in itemsMember) {
        selectedMemberList.add(SelectedListItem(name: x));
      }

      print('215 selectedMemberList:${selectedMemberList.length}');
      for (String x in itemsProject) {
        selectedProjectList.add(SelectedListItem(name: x));
      }
      for (String x in itemsReportName) {
        selectedReportList.add(SelectedListItem(name: x));
      }
      for (String x in itemsTask) {
        selectedTaskList.add(SelectedListItem(name: x));
      }
      selectedStatusList.addAll([
        SelectedListItem(name: "Completed"),
        SelectedListItem(name: "In Progress"),
        SelectedListItem(name: "On Hold"),
      ]);
      await sharedPreference.setBool("saveDataToBI", true);
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong $e");
      print(e);
    } finally {
      isLoading.value = false;
      setState(() {});
    }
  }

  Future<String> getFilePath() async {
    // Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    var directory = Directory('/storage/emulated/0/Download');

    String appDocumentsPath = directory.path; // 2
    String filePath = '$appDocumentsPath/cloud.txt'; // 3
    print('page/state filepath $directory');
    return filePath;
  }

  void saveFile(filter) async {
    print('page/state file save ${(filter)}');
    File file = File(await getFilePath()); // 1
    file.writeAsString(json.encode(filter));
    // file.writeAsString(jsonDecode(filter));
    // 2
  }

  sheetWork() async {
    try {
      var sheet = spreadSheetBI.worksheetByTitle("Sheet1");
      print(sheet);
      var allRow = await sheet!.values.allRows();
      // print(allRow.length);
      int length = allRow.length;
      for (int i = 0; i < list.length; i++) {
        print(list[i]['hour']);
        length = length + 1;
        await sheet.values.insertRow(length, [
          list[i]['date'],
          list[i]['member'],
          list[i]['start Time'],
          list[i]['end Time'],
          list[i]['duration'],
          list[i]['task type'],
          list[i]['project'],
          list[i]['report'],
          list[i]['desc'],
          list[i]['status'],
        ]);
      }
      list = [];
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong");
      print(e);
    } finally {
      progress = false;
      setState(() {});
    }

    Fluttertoast.showToast(msg: "Hours Log Updated Successfully");
  }

  String durationFromTimeOfDay(TimeOfDay? start, TimeOfDay? end) {
    if (start == null || end == null) return '';

    // DateTime(year, month, day, hour, minute)
    final now = DateTime.now();
    final startDT =
        DateTime(now.year, now.month, now.day, start.hour, start.minute);
    final endDT = DateTime(now.year, now.month, now.day, end.hour, end.minute);

    final range = endDT.difference(startDT);
    final hours = range.inHours;
    final minutes = range.inMinutes % 60;

    final _onlyHours = minutes == 0;
    final _onlyMinutes = hours == 0;
    final hourText = _onlyMinutes
        ? ''
        : '$hours${_onlyHours ? ' hour' : 'h'}${hours > 1 ? 's' : ''}';
    final minutesText = _onlyHours
        ? ''
        : '$minutes${_onlyMinutes ? ' min' : 'm'}${minutes > 1 ? 's' : ''}';
    return hourText + minutesText;
  }

  Duration addTimeDurations(TimeOfDay start, TimeOfDay end) {
    final now = DateTime.now();
    final startDate =
        DateTime(now.year, now.month, now.day, start.hour, start.minute);
    final endDate =
        DateTime(now.year, now.month, now.day, end.hour, end.minute);

    // Add one day to endDate if it's before startDate
    if (endDate.isBefore(startDate)) {
      endDate.add(Duration(days: 1));
    }
    final duration = endDate.difference(startDate);
    return Duration(hours: duration.inHours, minutes: duration.inMinutes % 60);
  }

  insertToList() {
    print('check:$startHourDateTime');

    if(now == 'Select Date'){
      Fluttertoast.showToast(msg: "Select Date");
      return;
    } else
    if (selectedMemberValue == "Member Name") {
      Fluttertoast.showToast(msg: "Select Member Name");
      return;
    } else if (selectedProjectValue == "Project Name") {
      Fluttertoast.showToast(msg: "Select Project Name");
      return;
    } else if (textReportValueController.text.trim() == "") {
      Fluttertoast.showToast(msg: "Select Report Name");
      return;
    } else if (selectedTaskValue == "Category of Task") {
      Fluttertoast.showToast(msg: "Select Category of Task");
      return;
    } else if (selectedHourValue == "Start Time") {
      Fluttertoast.showToast(msg: "Select Start Time");
      return;
    } else if (selectedEndHourValue == "End Time") {
      Fluttertoast.showToast(msg: "Select End Time");
      return;
    } else if (startHourDateTime!.isAfter(EndHourDateTime!)) {
      Fluttertoast.showToast(msg: "End time must follow start time");
      return;
    } else if (selectedStatustValue == "Status of Task") {
      Fluttertoast.showToast(msg: "Select Task Status");
      return;
    } else if (textEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Write Work description");
      return;
    }

    print('TIMEDURATION:$selectedTime selectedEndTime:$selectedEndTime');
    Duration selectedDuration = addTimeDurations(selectedTime, selectedEndTime);
    print('');
    String formattedDuration =
        '${selectedDuration.inHours}:${selectedDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}';

    list.add({
      "date": now,
      "member": selectedMemberValue,
      "start Time": selectedHourValue.value,
      "end Time": selectedEndHourValue.value,
      "duration": formattedDuration,
      "task type": selectedTaskValue,
      "project": selectedProjectValue,
      "report": textReportValueController.text.trim(),
      "desc": textEditingController.text,
      "start": selectedTime,
      "end": selectedEndTime,
      "durationTime": selectedDuration,
      "status": selectedStatustValue,
    });

    textEditingController.text = '';
    selectedProjectValue = "Project Name";
    textReportValueController.text = "Report Name";
    selectedTaskValue = "Category of Task";
    selectedSubTaskValue = "Sub Category of Task";
    selectedHourValue.value = "Start Time";
    selectedEndHourValue.value = "End Time";
    selectedStatustValue = "Status of Task";
    selectedTime = TimeOfDay.now();
    selectedEndTime = TimeOfDay.now();
    setState(() {});
    Fluttertoast.showToast(msg: "Added to list");
  }

  Duration calculateTotalDuration(List list) {
    Duration totalDuration = Duration.zero;

    for (var i = 0; i < list.length; i++) {
      Duration duration = list[i]['durationTime'];
      totalDuration += duration;
    }

    return totalDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await getInitialData();
              },
              icon: Icon(Icons.replay_outlined)),
          // IconButton(
          //     onPressed: () async {
          //       await getdatass();
          //     },
          //     icon: Icon(Icons.account_balance_outlined))
        ],
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() => isLoading.value == true
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.red,
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: InkWell(
                                onTap: () {
                                  showDate();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey[200],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    '$now',
                                    style: TextStyle(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                )))
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            if (selectedMemberValue == "Member Name") {
                              showMember();
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: selectedMemberValue == "Member Name"
                                    ? Colors.grey[200]
                                    : Colors.blueGrey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    selectedMemberValue,
                                    style: TextStyle(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                selectedMemberValue == "Member Name"
                                    ? Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      )
                                    : SizedBox()
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            showProject();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: selectedProjectValue == "Project Name"
                                    ? Colors.grey[200]
                                    : Colors.blueGrey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    selectedProjectValue,
                                    style: TextStyle(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //         child: InkWell(
                    //       onTap: () {
                    //         showReport();
                    //       },
                    //       child: Container(
                    //         alignment: Alignment.center,
                    //         decoration: BoxDecoration(
                    //             color: selectedReportValue == "Report Name"
                    //                 ? Colors.grey[200]
                    //                 : Colors.blueGrey[200],
                    //             borderRadius: BorderRadius.circular(10)),
                    //         child: Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             Padding(
                    //               padding: const EdgeInsets.all(16.0),
                    //               child: Text(
                    //                 selectedReportValue,
                    //                 style: TextStyle(color: Colors.black),
                    //                 textAlign: TextAlign.center,
                    //               ),
                    //             ),
                    //             Icon(
                    //               Icons.arrow_drop_down,
                    //               color: Colors.black,
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ))
                    //   ],
                    // ),

                    Container(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                            controller: textReportValueController,
                            minLines: 1,
                            maxLines: 1,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Report Name",
                                hintStyle: TextStyle()),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal))),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            showTask();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: selectedTaskValue == "Category of Task"
                                    ? Colors.grey[200]
                                    : Colors.blueGrey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: Get.width - 75,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    selectedTaskValue,
                                    style: TextStyle(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                    // SizedBox(
                    //   height: 16,
                    // ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //         child: InkWell(
                    //       onTap: () {
                    //         if (selectedSubTaskList.isEmpty) {
                    //           Fluttertoast.showToast(
                    //               msg: "Select Category first");
                    //           return;
                    //         }
                    //         showSubTask();
                    //       },
                    //       child: Container(
                    //         alignment: Alignment.center,
                    //         decoration: BoxDecoration(
                    //             color: selectedSubTaskValue ==
                    //                     "Sub Category of Task"
                    //                 ? Colors.grey[200]
                    //                 : Colors.blueGrey[200],
                    //             borderRadius: BorderRadius.circular(10)),
                    //         child: Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             Padding(
                    //               padding: const EdgeInsets.all(16.0),
                    //               child: Text(
                    //                 selectedSubTaskValue,
                    //                 style: TextStyle(color: Colors.black),
                    //                 textAlign: TextAlign.center,
                    //               ),
                    //             ),
                    //             Icon(
                    //               Icons.arrow_drop_down,
                    //               color: Colors.black,
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ))
                    //   ],
                    // ),

                    SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: Get.width,
                      child: Row(
                        children: [
                          SizedBox(
                            width: Get.width * 0.45,
                            child: Row(
                              children: [
                                Expanded(
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            print('asdfdg');
                                            showHours(context);
                                          });
                                        },
                                        child: Obx(
                                          () => Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: selectedHourValue ==
                                                        "Start Time"
                                                    ? Colors.grey[200]
                                                    : Colors.blueGrey[200],
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Text(
                                                      selectedHourValue.value,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.black,
                                                )
                                              ],
                                            ),
                                          ),
                                        )))
                              ],
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: Get.width * 0.45,
                            child: Row(
                              children: [
                                Expanded(
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            showEndHours(context);
                                          });
                                        },
                                        child: Obx(
                                          () => Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: selectedEndHourValue ==
                                                        "End Time"
                                                    ? Colors.grey[200]
                                                    : Colors.blueGrey[200],
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Text(
                                                      selectedEndHourValue
                                                          .value,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.black,
                                                )
                                              ],
                                            ),
                                          ),
                                        )))
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    // SizedBox(

                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //           child: InkWell(
                    //         onTap: () {
                    //           setState(() {
                    //             showHours(context);
                    //           });
                    //         },
                    //         child: Container(
                    //           alignment: Alignment.center,
                    //           decoration: BoxDecoration(
                    //               color: selectedHourValue == "Time (in hrs)"
                    //                   ? Colors.grey[200]
                    //                   : Colors.blueGrey[200],
                    //               borderRadius: BorderRadius.circular(10)),
                    //           child: Row(
                    //             mainAxisSize: MainAxisSize.min,
                    //             children: [
                    //               Padding(
                    //                 padding: const EdgeInsets.all(16.0),
                    //                 child: Text(
                    //                   selectedHourValue.value,
                    //                   style: TextStyle(color: Colors.black),
                    //                   textAlign: TextAlign.center,
                    //                 ),
                    //               ),
                    //               Icon(
                    //                 Icons.arrow_drop_down,
                    //                 color: Colors.black,
                    //               )
                    //             ],
                    //           ),
                    //         ),
                    //       ))
                    //     ],
                    //   ),
                    // ),
                    ,
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              showStatus();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color:
                                      selectedStatustValue == "Status of Task"
                                          ? Colors.grey[200]
                                          : Colors.blueGrey[200],
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      selectedStatustValue,
                                      style: TextStyle(color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: textEditingController,
                            minLines: 4,
                            maxLines: 10,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Work description",
                                hintStyle: TextStyle()),
                            style: TextStyle())),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            insertToList();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    "ADD",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),

                    ///////////////////// submit start from here///////////////////////////
                    ///
                    ///
                    ///

                    SizedBox(
                      height: 16,
                    ),

                    list.isNotEmpty
                        ? Obx(() => Text(
                              () {
                                return totalHours.value;
                              }(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ))
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      itemCount: list.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (itemBuilder, index) {
                        // get total hour
                        Future.delayed(Duration(seconds: 1), () {
                          Duration totalDuration = calculateTotalDuration(list);
                          totalHours.value =
                              "Total time: ${totalDuration.inHours}:${totalDuration.inMinutes.remainder(60)} hrs";
                        });

                        return GestureDetector(
                          // onLongPress: () {
                          //   // edit list
                          //   setState(() {
                          //     textEditingController.text = list[index]['desc'];
                          //     selectedHourValue.value =
                          //         list[index]['start Time'];
                          //     selectedEndTime = list[index]['end'];
                          //     selectedTime = list[index]['start'];
                          //     selectedEndHourValue.value =
                          //         list[index]['end Time'];
                          //     selectedProjectValue = list[index]['project'];
                          //     now = list[index]['date'];
                          //     selectedMemberValue = list[index]['member'];
                          //     selectedReportValue = list[index]['report'];
                          //     selectedTaskValue = list[index]['task type'];
                          //     list.removeAt(index);
                          //   });
                          // },
                          child: Card(
                            child: ListTile(
                                title: Text(
                                  list[index]['project'],
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(list[index]['date']),
                                        SizedBox(
                                          width: 16,
                                        ),

                                        // Text(DateFormat("dd-MMMM").format(DateFormat("dd-MMMM-yyyy").parse(list[index]['date']))),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(list[index]['start Time']),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text("-"),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(list[index]['end Time']),
                                      ],
                                    ),
                                    Text(
                                        "Duration: ${list[index]['duration']}"),
                                    Text("Status: ${list[index]['status']}"),
                                    Text(list[index]['report']),
                                    Text(list[index]['task type']),
                                    Text(list[index]['desc'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                trailing: Container(
                                  width: 65,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            textEditingController.text =
                                                list[index]['desc'];
                                            selectedHourValue.value =
                                                list[index]['start Time'];
                                            selectedEndTime =
                                                list[index]['end'];
                                            selectedTime = list[index]['start'];
                                            selectedEndHourValue.value =
                                                list[index]['end Time'];
                                            selectedProjectValue =
                                                list[index]['project'];
                                            now = list[index]['date'];
                                            selectedMemberValue =
                                                list[index]['member'];
                                            textReportValueController.text =
                                                list[index]['report'];
                                            selectedTaskValue =
                                                list[index]['task type'];
                                            selectedStatustValue =
                                                list[index]['status'];
                                            list.removeAt(index);
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          )),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            list.removeAt(index);
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )),
                                    ],
                                  ),
                                )),
                          ),
                        );
                      },
                      // separatorBuilder: (BuildContext context, int index) {
                      //   return Divider();
                      // },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    list.isEmpty
                        ? SizedBox()
                        : progress == true
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                      child: InkWell(
                                    onTap: () {
                                      progress = true;
                                      setState(() {});
                                      sheetWork();
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Colors.blueAccent,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              "SUBMIT",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                  ],
                ),
              ),
            )),
    );
  }

  showMember() {
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
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedMemberValue = list.first;
          setState(() {});
          sharedPreference.setString("member", selectedMemberValue);
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  showProject() {
    DropDownState(
      DropDown(
        bottomSheetTitle: Text(
          'Select Client/Project Name',
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
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedProjectValue = list.first;
          setState(() {});
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  showStatus() {
    DropDownState(
      DropDown(
        bottomSheetTitle: Text(
          'Select Status',
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
        data: selectedStatusList,
        // data: widget.cities ?? [],
        selectedItems: (List<dynamic> selectedList) {
          List<String> list = [];
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedStatustValue = list.first;
          setState(() {});
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  showReport() {
    DropDownState(
      DropDown(
        bottomSheetTitle: Text(
          'Select Report',
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
        data: selectedReportList,
        // data: widget.cities ?? [],
        selectedItems: (List<dynamic> selectedList) {
          List<String> list = [];
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          textReportValueController.text = list.first;
          setState(() {});
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  showTask() {
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
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedTaskValue = list.first;
          selectedSubTaskValue = 'Sub Category of Task';
          selectedSubTaskList = [];
          setState(() {});

          // if (selectedTaskValue == "Core task") {
          //   for (String x in coreTasKIDList) {
          //     selectedSubTaskList.add(SelectedListItem(name: x));
          //   }
          // } else if (selectedTaskValue == "Help task") {
          //   for (String x in helpTasKIDList) {
          //     selectedSubTaskList.add(SelectedListItem(name: x));
          //   }
          // } else if (selectedTaskValue == "R&D task") {
          //   for (String x in rnDTaskIDList) {
          //     selectedSubTaskList.add(SelectedListItem(name: x));
          //   }
          // } else if (selectedTaskValue == "Other work-related tasks") {
          //   for (String x in otherTaskIDList) {
          //     selectedSubTaskList.add(SelectedListItem(name: x));
          //   }
          // } else if (selectedTaskValue == "Leisure tasks") {
          //   for (String x in leisureTaskIDList) {
          //     selectedSubTaskList.add(SelectedListItem(name: x));
          //   }
          // }

          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  // showSubTask() {
  //   DropDownState(
  //     DropDown(
  //       bottomSheetTitle: Text(
  //         'Select Sub Category of Task',
  //         style: TextStyle(
  //           fontWeight: FontWeight.bold,
  //           fontSize: 20.0,
  //         ),
  //       ),
  //       submitButtonChild: const Text(
  //         'Done',
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       data: selectedSubTaskList,
  //       // data: widget.cities ?? [],
  //       selectedItems: (List<dynamic> selectedList) {
  //         List<String> list = [];
  //         for (var item in selectedList) {
  //           if (item is SelectedListItem) {
  //             list.add(item.name);
  //           }
  //         }
  //         print(list);
  //         selectedSubTaskValue = list.first;
  //         setState(() {});
  //         // showSnackBar(list.toString());
  //       },
  //       enableMultipleSelection: false,
  //     ),
  //   ).showModal(context);
  // }

  // showHours() {

  showHours(BuildContext context) async {
    // final TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: this.selectedTime,
      // builder: (context, Widget? child) {
      //   return MediaQuery(
      //     data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
      //     child: child!,
      //   );
      // },
    );



    selectedTime = selectedTime!;

    selectedHourValue.value = selectedTime.format(context);
    DateFormat startHourFormat = DateFormat('h:mm a');
    startHourDateTime = startHourFormat.parse(selectedHourValue.value);

    // print('selectedHourValue dateTime:${startHourDateTime}');
    String formattedTime = DateFormat('h:mm a').format(startHourDateTime!);
    print(
        'selectedStartHourValue formattedTime:${formattedTime}'); // Output: 2:23 PM
    // setState(() {
    return selectedHourValue;


  //   // this.selectedTime = selectedTime!;
  //   // selectedHourValue.value = selectedTime.format(context);
  //   // print('date format:${selectedHourValue.value}');
  // var data=   DateFormat("h:mm:a").parse(selectedHourValue.value);
  // print('data value:$data');
  //   // DateFormat format = DateFormat('h:mma');
  //   // print('selectedHourValue:${selectedHourValue.value}');//3710
  //   startHourDateTime = selectedHourValue.value;
  //   // startHourDateTime = format.parse(selectedHourValue.value);
  //   print('startHourDateTime:${startHourDateTime}');
  //   // String formattedTime = DateFormat('h:mma').format(startHourDateTime!);
  //   // print('formate:$formattedTime');
    setState(() {});
    // return selectedHourValue;
  }

    String convertTo12HourFormat(String time24hr) {
    try {
      // Parse the 24-hour time string to a DateTime object
      DateTime time = DateFormat('HH:mm').parse(time24hr);
      // Format the DateTime object to 12-hour format
      String formattedTime12hr = DateFormat('h:mm a').format(time);
      return formattedTime12hr;
    } catch (e) {
      // Return an empty string if the input format is invalid
      return '';
    }
  }

  showEndHours(BuildContext context) async {
    // final TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    selectedEndTime = selectedTime!;

    selectedEndHourValue.value = selectedTime.format(context);
    DateFormat EndHourFormat = DateFormat('h:mm a');
    EndHourDateTime = EndHourFormat.parse(selectedEndHourValue.value);

    // print('selectedEndHourValue dateTime:${EndHourDateTime}');
    String formattedTime = DateFormat('h:mm a').format(EndHourDateTime!);
    print(
        'selectedEndHourValue formattedTime:${formattedTime}'); // Output: 2:23 PM
    // setState(() {
    return selectedEndHourValue;

    // });
  }

  // DropDownState(
  //   DropDown(
  //     bottomSheetTitle: Text(
  //       'Time (in hours)',
  //       style: TextStyle(
  //         fontWeight: FontWeight.bold,
  //         fontSize: 20.0,
  //       ),
  //     ),
  //     submitButtonChild: const Text(
  //       'Done',
  //       style: TextStyle(
  //         fontSize: 16,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     data: selectedHourList,
  //     // data: widget.cities ?? [],
  //     selectedItems: (List<dynamic> selectedList) {
  //       List<String> list = [];
  //       for (var item in selectedList) {
  //         if (item is SelectedListItem) {
  //           list.add(item.name);
  //         }
  //       }
  //       print(list);
  //       selectedHourValue = list.first;
  //       setState(() {});
  //       // showSnackBar(list.toString());
  //     },
  //     enableMultipleSelection: false,
  //   ),
  // ).showModal(context);
  // }

  showDate() async {
    var selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime.now());
    if (selectedDate != null) {
      now = DateFormat('dd-MMMM-yyyy').format(selectedDate);
    }
    setState(() {});
  }
}
