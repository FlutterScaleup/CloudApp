import 'dart:async';

import 'package:get/get.dart';

class MyController extends GetxController{
  RxString countDownTime=''.obs;
  RxString clockBtnText="Start clock in".obs;
  RxBool shouldGoForward=false.obs;
  Timer? timer;
  RxBool loadingClockBtn=true.obs;
  // RxString? animatedWidth="".obs;
  final animatedWidth = Rxn<double>();
  RxBool loginLoading=false.obs;
  StreamController<bool>  streamController=StreamController();

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }
}