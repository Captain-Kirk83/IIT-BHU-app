import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iit_app/screens/home/home.dart';

class PushNotification {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static String _message = '';

  static initialize() {
    _firebaseMessaging.getToken().then((token) => print("fcm token:$token"));
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
      //_popNotification(message["notification"]["title"]);
      _message = message["notification"]["title"];
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      _message = message["notification"]["title"];
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      _message = message["notification"]["title"];
    });
  }

  /*static Future<void> _popNotification(note) async {
    return /*showDialog(
        context: context,
        builder: (context) =>*/
        AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Text(note),
      actions: <Widget>[
        FlatButton(
          child: Text('Show'),
          onPressed: () => MaterialApp(
            home: HomeScreen(),
          ),
        ),
      ],
    );
  }*/
}
