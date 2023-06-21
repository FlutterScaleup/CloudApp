import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gsheet/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';

class HoursLogScreenCloud extends StatefulWidget {
  const HoursLogScreenCloud({super.key, required this.title});
  final String title;

  @override
  State<HoursLogScreenCloud> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HoursLogScreenCloud> {
  String now = 'Select Date';
  List<SelectedListItem> selectedMemberList = [];
  String selectedMemberValue = "Member Name";
  List<SelectedListItem> selectedProjectList = [];
  String selectedProjectValue = "Project Name";
  List<SelectedListItem> selectedTaskList = [];
  String selectedTaskValue = "Category of Task";
  List<SelectedListItem> selectedSubTaskList = [];
  String selectedSubTaskValue = "Sub Category of Task";
  List<SelectedListItem> selectedHourList = [];
  String selectedHourValue = "Time (in hrs)";
  List<SelectedListItem> selectedStatusList = [];
  String selectedStatusValue = "Status of Task";

  TextEditingController textEditingController = TextEditingController();
  TextEditingController workDoneEditingController = TextEditingController();

  TextEditingController workPendingEditingController = TextEditingController();

  // late SharedPreferences sharedPrefrence;
  RxBool isLoading = false.obs;
  List list = [];
  bool progress = false;

  var coreTasKIDList;
  var helpTasKIDList;
  var rnDTaskIDList;
  var otherTaskIDList;
  var leisureTaskIDList;
  var dataSaved;

  getdata() async {
    var dataSaved = sharedPreference.get("saveData") ?? false;
    if (dataSaved == true) {
      getDataFromHive();
    } else {
      getInitialData();
    }
  }

  @override
  void initState() {
    super.initState();

    var justNow = DateTime.now();
    now = DateFormat('dd-MMMM-yyyy').format(justNow);
    var member = sharedPreference.get("member");
    print("Memberrrr $member");
    if (member != null) {
      selectedMemberValue = member.toString();
    }
    list.add({
      "date": now,
      "member": selectedMemberValue,
      "project": "No Project",
      "task": "Leisure tasks",
      "subTask": "Lunch & Tea break",
      "desc": "Lunch Break",
      "hour": "1",
      "status": "",
      "workDone": "",
      "workPending": "",
    });
    getdata();
  }

  Duration calculateTotalDuration(List list) {
    Duration totalDuration = Duration.zero;

    for (var i = 0; i < list.length; i++) {
      Duration duration = list[i]['durationTime'];
      totalDuration += duration;
    }

    return totalDuration;
  }

  getDataFromHive() async {
    isLoading.value = true;
    var member = sharedPreference.get("member");
    print("Memberrrr $member");
    if (member != null) {
      selectedMemberValue = member.toString();
    }
    var itemsMember = sharedPreference.getStringList("memberList");
    var itemsProject = sharedPreference.getStringList("projectList");
    var itemsTask = sharedPreference.getStringList("taskList");
    var itemsHours = sharedPreference.getStringList("hourList");

    coreTasKIDList = sharedPreference.getStringList("coreTasKIDList");
    helpTasKIDList = sharedPreference.getStringList("helpTasKIDList");
    rnDTaskIDList = sharedPreference.getStringList("rnDTaskIDList");
    otherTaskIDList = sharedPreference.getStringList("otherTaskIDList");
    leisureTaskIDList = sharedPreference.getStringList("leisureTaskIDList");

    if (selectedMemberValue == "Member Name") {
      var emailList = sharedPreference.getStringList("emailList");
      if (sharedPreference.get("email") != null &&
          sharedPreference.get("email").toString().isNotEmpty) {
        if (emailList!.contains(sharedPreference.get("email"))) {
          String email = sharedPreference.get("email").toString();
          var index = emailList.indexOf(email);
          selectedMemberValue = itemsMember![index];
          sharedPreference.setString("member", selectedMemberValue);
        }
      }
    }
    for (String x in itemsMember!) {
      selectedMemberList.add(SelectedListItem(name: x));
    }
    for (String x in itemsProject!) {
      selectedProjectList.add(SelectedListItem(name: x));
    }
    for (String x in itemsTask!) {
      selectedTaskList.add(SelectedListItem(name: x));
    }
    for (String x in itemsHours!) {
      selectedHourList.add(SelectedListItem(name: x));
    }
    selectedStatusList.addAll([
      SelectedListItem(name: "Completed"),
      SelectedListItem(name: "In Progress"),
    ]);
    isLoading.value = false;
    setState(() {});
  }

  getInitialData() async {
    isLoading.value = true;

    selectedMemberList = [];
    selectedProjectList = [];
    selectedTaskList = [];
    selectedHourList = [];
    selectedStatusList = [];

    // sharedPrefrence = await SharedPreferences.getInstance();
    var member = sharedPreference.get("member");
    print("Memberrrr $member");
    if (member != null) {
      selectedMemberValue = member.toString();
    }
    Worksheet sheet = spreadSheet.worksheetByTitle("Data Sheet");
    var itemsMember = (await sheet.values.columnByKey("Team Member Name"))!;
    var itemsProject = (await sheet.values.columnByKey("Project Name"))!;
    var itemsTask = (await sheet.values.columnByKey("Category of Task"))!;
    var itemsHours = (await sheet.values.columnByKey("Hours"))!;

    coreTasKIDList = (await sheet.values.columnByKey("Core Task ID"))!;
    helpTasKIDList = (await sheet.values.columnByKey("Help Task ID"))!;
    rnDTaskIDList = (await sheet.values.columnByKey("R&D Task ID"))!;
    otherTaskIDList =
        (await sheet.values.columnByKey("Other Work-Related Task ID"))!;
    leisureTaskIDList = (await sheet.values.columnByKey("Leisure Task ID"))!;

    await sharedPreference.setStringList("memberList", itemsMember);
    await sharedPreference.setStringList("projectList", itemsProject);
    await sharedPreference.setStringList("taskList", itemsTask);
    await sharedPreference.setStringList("hourList", itemsHours);
    await sharedPreference.setStringList("coreTasKIDList", coreTasKIDList);
    await sharedPreference.setStringList("helpTasKIDList", helpTasKIDList);
    await sharedPreference.setStringList("rnDTaskIDList", rnDTaskIDList);
    await sharedPreference.setStringList("otherTaskIDList", otherTaskIDList);
    await sharedPreference.setStringList(
        "leisureTaskIDList", leisureTaskIDList);

    if (selectedMemberValue == "Member Name") {
      var emailList = (await sheet.values.columnByKey("Email"))!;
      await sharedPreference.setStringList("emailList", emailList);
      if (sharedPreference.get("email") != null &&
          sharedPreference.get("email").toString().isNotEmpty) {
        if (emailList.contains(sharedPreference.get("email"))) {
          String email = sharedPreference.get("email").toString();
          var index = emailList.indexOf(email);
          selectedMemberValue = itemsMember[index];
          sharedPreference.setString("member", selectedMemberValue);
        }
      }
    }
    for (String x in itemsMember) {
      selectedMemberList.add(SelectedListItem(name: x));
    }
    for (String x in itemsProject) {
      selectedProjectList.add(SelectedListItem(name: x));
    }
    for (String x in itemsTask) {
      selectedTaskList.add(SelectedListItem(name: x));
    }
    for (String x in itemsHours) {
      selectedHourList.add(SelectedListItem(name: x));
    }
    selectedStatusList.addAll([
      SelectedListItem(name: "Completed"),
      SelectedListItem(name: "In Progress"),
    ]);
    sharedPreference.setBool("saveData", true);
    isLoading.value = false;
    setState(() {});
  }

  RxString totalHours = "".obs;

  sheetWork() async {
    var sheet = spreadSheet.worksheetByTitle("Hours Log");
    print(sheet);
    // await sheet!.values.insertValue('koko', column: 1, row: 1);
    // await sheet.values.insertColumn(7, ['qwer']);
    var allRow = await sheet!.values.allRows();
    // print(allRow.length);
    int length = allRow.length;
    for (int i = 0; i < list.length; i++) {
      print(list[i]['hour']);
      length = length + 1;
      await sheet.values.insertRow(length, [
        list[i]['date'],
        list[i]['member'],
        list[i]['project'],
        list[i]['task'],
        list[i]['subTask'],
        list[i]['desc'],
        list[i]['hour'],
        list[i]['status'],
        list[i]['workPending'],
        list[i]['workDone'],
        list[i]['flag'],
      ]);
    }
    list = [];
    progress = false;
    setState(() {});

    textEditingController.text = '';
    workPendingEditingController.text = '';
    workDoneEditingController.text = '';
    selectedStatusValue = "Status of Task";
    selectedProjectValue = "Project Name";
    selectedTaskValue = "Category of Task";
    selectedSubTaskValue = "Sub Category of Task";
    selectedHourValue = "Time (in hrs)";
    Fluttertoast.showToast(msg: "Hours Log Updated Successfully");
  }

  insertToList() {
    if (selectedMemberValue == "Member Name") {
      Fluttertoast.showToast(msg: "Select Member Name");
      return;
    }
    if (selectedProjectValue == "Project Name") {
      Fluttertoast.showToast(msg: "Select Project Name");
      return;
    }
    if (selectedTaskValue == "Category of Task") {
      Fluttertoast.showToast(msg: "Select Category of Task");
      return;
    }
    if (selectedSubTaskValue == "Sub Category of Task") {
      Fluttertoast.showToast(msg: "Select Sub Category of Task");
      return;
    }
    if (selectedHourValue == "Time (in hrs)") {
      Fluttertoast.showToast(msg: "Select Time (in hrs)");
      return;
    }
    if (textEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Write Work description");
      return;
    }

    if (selectedTaskValue == "Core Task") {
      if (selectedStatusValue == "Status of Task") {
        Fluttertoast.showToast(msg: "Select Status of Task");
        return;
      }
      if (workDoneEditingController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Write Work Done description");
        return;
      }
      if (workPendingEditingController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Write Work Pending description");
        return;
      }
    }
    list.add({
      "date": now,
      "member": selectedMemberValue,
      "project": selectedProjectValue,
      "task": selectedTaskValue,
      "subTask": selectedSubTaskValue,
      "desc": textEditingController.text,
      "hour": selectedHourValue,
      "status": selectedTaskValue != "Core task" ? "" : selectedStatusValue,
      "workDone": selectedTaskValue != "Core task"
          ? ""
          : workDoneEditingController.text,
      "workPending": selectedTaskValue != "Core task"
          ? ""
          : workPendingEditingController.text,
      "flag": now == DateFormat('dd-MMMM-yyyy').format(DateTime.now())
          ? "Blue"
          : "Red",
    });

    textEditingController.text = '';
    workDoneEditingController.text = '';
    workPendingEditingController.text = '';
    selectedProjectValue = "Project Name";
    selectedTaskValue = "Category of Task";
    selectedSubTaskValue = "Sub Category of Task";
    selectedHourValue = "Time (in hrs)";
    selectedStatusValue = "Status of Task";
    setState(() {});
    Fluttertoast.showToast(msg: "Added to list");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () async {
                await getInitialData();
              },
              icon: const Icon(Icons.replay_outlined))
        ],
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
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey[200],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    now,
                                    style: const TextStyle(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                )))
                      ],
                    ),
                    const SizedBox(
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
                                    style: const TextStyle(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                selectedMemberValue == "Member Name"
                                    ? const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      )
                                    : const SizedBox()
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                    const SizedBox(
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
                                  child: SizedBox(
                                    width: Get.width * 0.7,
                                    child: Text(
                                      selectedProjectValue,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                    const SizedBox(
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
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SizedBox(
                                    width: Get.width * 0.7,
                                    child: Text(
                                      selectedTaskValue,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            if (selectedSubTaskList.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Select Category first");
                              return;
                            }
                            showSubTask();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: selectedSubTaskValue ==
                                        "Sub Category of Task"
                                    ? Colors.grey[200]
                                    : Colors.blueGrey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SizedBox(
                                    width: Get.width * 0.7,
                                    child: Text(
                                      selectedSubTaskValue,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),

                    ///////////////////////////////
                    ////////////////////////
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                    Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            showHours();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: selectedHourValue == "Time (in hrs)"
                                    ? Colors.grey[200]
                                    : Colors.blueGrey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    selectedHourValue,
                                    style: const TextStyle(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Visibility(
                      visible: selectedTaskValue == "Core task",
                      child: Column(
                        children: [
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
                                      color: selectedStatusValue ==
                                              "Status of Task"
                                          ? Colors.grey[200]
                                          : Colors.blueGrey[200],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          selectedStatusValue,
                                          style: const TextStyle(
                                              color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      )
                                    ],
                                  ),
                                ),
                              ))
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Visibility(
                            visible: selectedStatusValue == "In Progress",
                            child: Column(
                              children: [
                                Container(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: TextField(
                                        controller: workDoneEditingController,
                                        minLines: 4,
                                        maxLines: 10,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Work Done",
                                            hintStyle: TextStyle()),
                                        style: const TextStyle())),
                                const SizedBox(
                                  height: 16,
                                ),
                                Container(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: TextField(
                                        controller:
                                            workPendingEditingController,
                                        minLines: 4,
                                        maxLines: 10,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Work Pending",
                                            hintStyle: TextStyle()),
                                        style: const TextStyle())),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                            controller: textEditingController,
                            minLines: 4,
                            maxLines: 10,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Work description",
                                hintStyle: TextStyle()),
                            style: const TextStyle())),
                    const SizedBox(
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
                            child:  Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
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
                    const SizedBox(
                      height: 16,
                    ),

                    ////////////////////////////

                    list.isNotEmpty
                        ? Obx(() => Text(
                              () {
                                return totalHours.value;
                              }(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ))
                        : Container(),
                    ListView.builder(
                      reverse: true,
                      itemCount: list.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (itemBuilder, index) {
                        print(list[index]['date']);
                        print(
                            DateFormat('dd-MMMM-yyyy').format(DateTime.now()));

                        Future.delayed(const Duration(seconds: 1), () {
                          totalHours.value =
                              "Total Hours: ${list.map((e) => double.parse(e['hour'])).reduce((value, element) => value + element)}";
                        });
                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              textEditingController.text = list[index]['desc'];

                              selectedProjectValue = list[index]['project'];
                              now = list[index]['date'];
                              selectedMemberValue = list[index]['member'];
                              selectedTaskValue = list[index]['task'];
                              selectedSubTaskValue = list[index]['subTask'];
                              selectedHourValue = list[index]['hour'];
                              list.removeAt(index);
                            });
                          },
                          child: Card(
                            child: ListTile(
                                title: Text(
                                  list[index]['project'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(list[index]['date']),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Text(list[index]['hour'] + "hrs"),

                                        // Text(DateFormat("dd-MMMM").format(DateFormat("dd-MMMM-yyyy").parse(list[index]['date']))),
                                      ],
                                    ),
                                    Text(list[index]['task']),
                                    Text(list[index]['subTask']),
                                    Visibility(
                                      visible:
                                          list[index]['task'] == "Core task",
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                                text: "Status: ",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                                children: [
                                                  TextSpan(
                                                      text: list[index]
                                                          ['status'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ]),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                                text: "Work Pending: ",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                                children: [
                                                  TextSpan(
                                                      text: list[index]
                                                          ['workDone'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ]),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                                text: "Work Done: ",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                                children: [
                                                  TextSpan(
                                                      text: list[index]
                                                          ['workDone'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ]),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(list[index]['desc'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400)),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: Get.width * 0.25,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      list[index]['date'] !=
                                              DateFormat('dd-MMMM-yyyy')
                                                  .format(DateTime.now())
                                          ? Icon(
                                              Icons.flag,
                                              color: Colors.red,
                                            )
                                          : Container(),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            textEditingController.text =
                                                list[index]['desc'];
                                            workDoneEditingController.text =
                                                list[index]['workDone'];
                                            workPendingEditingController.text =
                                                list[index]['workPending'];

                                            selectedProjectValue =
                                                list[index]['project'];
                                            now = list[index]['date'];
                                            selectedMemberValue =
                                                list[index]['member'];
                                            selectedTaskValue =
                                                list[index]['task'];
                                            selectedSubTaskValue =
                                                list[index]['subTask'];
                                            selectedHourValue =
                                                list[index]['hour'];
                                            selectedStatusValue =
                                                list[index]['status'];

                                            list.removeAt(index);
                                            setState(() {});
                                          },
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            list.removeAt(index);
                                            setState(() {});
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )),
                                    ],
                                  ),
                                )),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    list.isEmpty
                        ? const SizedBox()
                        : progress == true
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    width: 50,
                                    height: 50,
                                    child: const CircularProgressIndicator(
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
                                      child:  Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(16.0),
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
                                  ))
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
        bottomSheetTitle: const Text(
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
          selectedStatusValue = list.first;
          setState(() {});
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  showProject() {
    DropDownState(
      DropDown(
        bottomSheetTitle: const Text(
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

  showTask() {
    DropDownState(
      DropDown(
        bottomSheetTitle: const Text(
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

          if (selectedTaskValue == "Core task") {
            for (String x in coreTasKIDList) {
              selectedSubTaskList.add(SelectedListItem(name: x));
            }
          } else if (selectedTaskValue == "Help task") {
            for (String x in helpTasKIDList) {
              selectedSubTaskList.add(SelectedListItem(name: x));
            }
          } else if (selectedTaskValue == "R&D task") {
            for (String x in rnDTaskIDList) {
              selectedSubTaskList.add(SelectedListItem(name: x));
            }
          } else if (selectedTaskValue == "Other work-related tasks") {
            for (String x in otherTaskIDList) {
              selectedSubTaskList.add(SelectedListItem(name: x));
            }
          } else if (selectedTaskValue == "Leisure tasks") {
            for (String x in leisureTaskIDList) {
              selectedSubTaskList.add(SelectedListItem(name: x));
            }
          }

          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  showSubTask() {
    DropDownState(
      DropDown(
        bottomSheetTitle: const Text(
          'Select Sub Category of Task',
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
        data: selectedSubTaskList,
        // data: widget.cities ?? [],
        selectedItems: (List<dynamic> selectedList) {
          List<String> list = [];
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedSubTaskValue = list.first;
          setState(() {});
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  showHours() {
    DropDownState(
      DropDown(
        bottomSheetTitle: const Text(
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
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              list.add(item.name);
            }
          }
          print(list);
          selectedHourValue = list.first;
          setState(() {});
          // showSnackBar(list.toString());
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  showDate() async {
    var selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now());
    if (selectedDate != null) {
      now = DateFormat('dd-MMMM-yyyy').format(selectedDate);
    }
    setState(() {});
  }
}
