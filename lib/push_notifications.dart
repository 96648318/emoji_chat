import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'models/message_model.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.data["body"].toString()}");
  }
  // DocumentSnapshot variable = await FirebaseFirestore.instance
  //     .collection('users')
  //     .doc(FirebaseAuth.instance.currentUser.uid)
  //     .get();
  // print(variable.data());
  showNotification(message.data["body"].toString(),
      message.data["title"].toString(), message.data["roomId"].toString());
}

void showNotification(String body, String mobileNo, String roomId) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('123456', 'location_tracking',
          channelDescription: 'fetch location in background',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(""),
          ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      1256789, mobileNo, body, platformChannelSpecifics,
      payload: 'item 1');
  await Firebase.initializeApp();
  getReviews(roomId);
}
Future<List<MessageModel>> getReviews(String roomId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("chats")
        .doc(roomId)
        .collection('messages')
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      DocumentSnapshot result = querySnapshot.docs[i];
      Map<String, dynamic> dt = result.data();
      if (result["senderId"].toString() !=
          FirebaseAuth.instance.currentUser.uid &&
          (result["isread"] == null || result["isread"] == "N")) {
        dt["isread"] = "U";
        FirebaseFirestore.instance
            .collection('chats')
            .doc(roomId.toString())
            .collection("messages")
            .doc(result.id)
            .update(dt);
      }
    }
    return null;
  } catch (error) {
    return error.message;
  }
}

class PushNotifications {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static const String _authServerKey =
      'AAAANy03E78:APA91bEhEPuBGSHielSuEUzrHNtd2SvpgLcwJ2o12_rZe8Z-7UU-vG4Fi_thwKduN1fKOo6TkONN9EZBJBMBIXgpWi96CbTqpH_drjcb9X9z5m6RY0k-Md71j5aYAIanSJxhLDnJ8u9c'; // Paste your FCM auth Key here

  static Future initialize() async {
    if (Platform.isIOS) {
      _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      // RemoteNotification notification = message.notification;
      // AndroidNotification android = message.notification?.android;
      if (message.notification != null) {
        if (kDebugMode) {
          print(
            'Message also contained a notification: ${message.data["body"].toString()}');
        }
        // showNotification(message.data["body"].toString(), message.data["title"].toString());

      }
      getReviews(message.data["roomId"].toString());
      // ContactList.instance.updateLastMessage(
      //     message.data['contactid'], message.notification.body);
      // ContactList.instance.displayLastMessage(message.data['contactid']);
      // ContactList.instance.updateUnreadMessage(message.data['contactid'], true);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data != null) {
        _serializeAndNavigate(message.data);
      }
    });

    _fcm.onTokenRefresh.listen((newToken) {
      if (FirebaseAuth.instance.currentUser != null) {
        final userID = FirebaseAuth.instance.currentUser.uid;
        FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({'notificationtoken': newToken});
      }
    });
  }

  static Future<void> _serializeAndNavigate(
      Map<String, dynamic> messageData) async {
    // final chatID = messageData['chatid'];
    // final contactID = messageData['contactid'];
    // DocumentSnapshot contactDetails = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(contactID)
    //     .get();
    // navigatorKey.currentState.pushNamed(ChatScreen.routeName,
    //    arguments: {'chatID': chatID, 'contactDetails': contactDetails});
  }

  static Future<void> sendNotification(
      {String title,
      String message,
      String chatID,
      String userID,
      String notificationToken,
      String roomID,String status}) async {
    const postUrl = "https://fcm.googleapis.com/fcm/send";
    final data = {
      // "notification": {"body": message, "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "chatid": chatID,
        "contactid": userID,
        "roomId": roomID,
        "body": message,
        "title": title
      },
      "to": notificationToken
    };
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=$_authServerKey'
    };
    BaseOptions options = BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: headers,
    );
    try {
      final response = await Dio(options).post(postUrl, data: data);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Notification sent successfully');
        }
        if(status=="Online"){
          getReviews(roomID);
        }
        //Notification sent successfully
      } else {
        if (kDebugMode) {
          print('notification sending failed');
        }
        // on failure do sth
      }
    } catch (e) {
      if (kDebugMode) {
        print('exception $e');
      }
    }
  }

  static Future<String> getNotificationsToken() async {
    return await _fcm.getToken();
  }
}
