import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gsheet/firebase_options.dart';
import 'package:flutter_gsheet/hello_page.dart';
import 'package:flutter_gsheet/onBoard/on_board_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gsheets/gsheets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const credential = r''' 
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
const credentialBI = r''' 
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

// var spreadSheetId="1TRjzU-PAkm3_rQJpmL1aWo4r-jJDh200XlmAVfvZukI";

var spreadSheetId = "1c1AV0zQ6rFB4TjzX406fSBWwIXQpIoqaVE5-ctygOWU";
var spreadSheetIdBI = "1NIrj6uVQ9mfNnWTgKcfDSFg1zR9pxLfqUJaTrQh6ET8";
// var spreadSheetIdBI = "1WDr07Z8Ytjn4R2qjDkBPdK1tJEbMWNvnVQCz0ZM9aek";

var spreadSheet;
var spreadSheetBI;

late SharedPreferences sharedPreference;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreference = await SharedPreferences.getInstance();

  final gsheets = GSheets(credential);
  final gsheetsBI = GSheets(credentialBI);
  bool worked = false;
  int tries = 0;
  while (!worked && tries < 2) {
    try {
      if (tries > 0) {
        Fluttertoast.showToast(
            msg: "Unable to connect Google Sheets, Trying again...");
      }
      await Future.delayed(const Duration(milliseconds: 800));
      spreadSheet = await gsheets.spreadsheet(spreadSheetId);
      spreadSheetBI = await gsheetsBI.spreadsheet(spreadSheetIdBI);
      worked = true;
    } catch (e) {
      tries++;
    }
  }
  AlertDialog(
    title: const Text("Err: Disconnected"),
    content: const Text(
        "Unable to load data from internet, please check your internet connection or try connecting to a different network.\nIf the problem persists contact developer."),
  );
  if (worked) {
    print("Nor worked");
    Fluttertoast.showToast(
        msg:
            "Unable to load Google Sheets, please check your internet connection and try again");
  }
  // check if web
  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  } else {
    await Firebase.initializeApp(
      // name: "Scaleupally",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await FirebaseMessaging.instance.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      criticalAlert: true,
      announcement: true);
  var token = await FirebaseMessaging.instance.getToken();
  print("token $token");
  FirebaseMessaging.onMessage.listen((event) async {
    print("event ${event.data}");
    print(jsonEncode(event.notification));
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher')));
    flutterLocalNotificationsPlugin.show(
        1,
        event.data['title'] + "listen",
        event.data['body'],
        const NotificationDetails(
            android: AndroidNotificationDetails("1", "sad")));
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
  // await flutterLocalNotificationsPlugin.initialize(InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
  // flutterLocalNotificationsPlugin.show(1, message.data['title']+" background", message.data['body'], NotificationDetails(android: AndroidNotificationDetails("1","sad")),payload: "");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Scaleupally',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      home: sharedPreference.get("verified") == null ||
              sharedPreference.getString("verified")!.isEmpty
          ? const OnboardScreen()
          : const HelloPage(),
      // home: sharedPreference.get("verified")==null || sharedPreference.getString("verified")!.isEmpty?OnboardScreen():const HelloPage(),
    );
  }
}
