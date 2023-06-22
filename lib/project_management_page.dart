import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:gsheets/gsheets.dart';

import 'main.dart';

class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({Key? key}) : super(key: key);

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {

  List<SelectedListItem> selectedProjectList = [];
  String selectedProjectValue = "Project Name";
  @override
  void initState() {
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Project',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(child: Column(children: [
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
      ],)),
    ));
  }

  Future<void> getData() async {

    Worksheet sheet = spreadSheet.worksheetByTitle("Data Sheet");
    var itemsProject = (await sheet.values.columnByKey("Project Name"))!;
    for (String x in itemsProject) {
      selectedProjectList.add(SelectedListItem(name: x));
      setState(() {

      });
    }

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
}
