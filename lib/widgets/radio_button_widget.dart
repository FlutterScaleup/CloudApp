import 'package:flutter/material.dart';
import 'package:flutter_gsheet/my_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadioButtonsWidget extends StatefulWidget {
  const RadioButtonsWidget({super.key});

  @override
  _RadioButtonsWidgetState createState() => _RadioButtonsWidgetState();
}

class _RadioButtonsWidgetState extends State<RadioButtonsWidget> {
  MyController myController = Get.put(MyController());
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = 'Patient'; // Set the initial selection
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(
          flex: 1,
        ),
        SizedBox(
          width: Get.width * 0.4,
          // height: 100,
          child: RadioListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cloud Team'),
            value: 'CLoud Team',
            groupValue: _selectedRole,
            onChanged: (value) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('isFromCloud', 'true');
              setState(() {
                _selectedRole = value;
                myController.isFromCloud.value = true;
                myController.isOptionSelected = true.obs;
              });
            },
          ),
        ),
        SizedBox(
         width: Get.width * 0.4,
          // height: 100,
          child: RadioListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('BI Team'),
            value: 'BI Team',
            groupValue: _selectedRole,
            onChanged: (value) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('isFromCloud', 'false');
              setState(() {
                _selectedRole = value;
                myController.isFromCloud.value = false;
                myController.isOptionSelected = true.obs;
              });
            },
          ),
        ),
        const Spacer(
          // Spacer is used to push the radio buttons to the left and right
          flex: 1,
        )
      ],
    );
  }
}
