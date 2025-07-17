import 'dart:async';
import 'dart:convert';

// import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  print('=========== ON BACKGROUND============');
  print('Message data: ${message.data}');

  try {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    var dataBase = await openDatabase(path);
    // if (dataBase == null || !dataBase.isOpen) {
    //   dataBase = await openDatabase(path);
    // }

    final Map<String, dynamic> eventClientJson =
        json.decode(message.data['eventClient']);
    final Map<String, dynamic> dataMap = {
      'id': int.parse(eventClientJson['id']),
      'clientId': int.parse(eventClientJson['clientId']),
      'eventId': int.parse(eventClientJson['eventId'])
    };
    final msg = await dataBase.insert('eventclient', dataMap);
    print('se agrego una noti: $msg');

    await dataBase.close();
  } catch (e) {
    print('error en el background');
    print(e);
  }
}

class PushNotificationProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageStreamController.stream;

  initNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    String? token = await _firebaseMessaging.getToken();
    print(token);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //cuando la app esta en primer plano
      print('=========== ON MESSAGE============');
      print('Message data: ${message.data}');

      _messageStreamController.sink.add(message.data);
    });
  }

  void deleteData() {
    _messageStreamController.sink.add({});
  }

  void dispose() {
    _messageStreamController.close();
  }
}
