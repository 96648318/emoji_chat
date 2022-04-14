import 'package:emoji_chat/push_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Screens/HomeScreen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/ProfileScreen.dart';
import 'Screens/SplashScreen.dart';
import 'Screens/chating_screen.dart';
import 'Screens/otpverificationScreen.dart';
import 'Screens/show_list_of_user.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Notification();
  PushNotifications.initialize();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MyApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Notification() {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/SplashScreen",
        navigatorKey: navigatorKey,
        routes: <String, WidgetBuilder>{
          '/SplashScreen': (BuildContext context) => const SplashScreen(),
          '/LoginScreen': (BuildContext context) => const LoginScreen(),
          '/otpverificationScreen': (BuildContext context) =>
              const otpverificationScreen(),
          '/HomeScreen': (BuildContext context) => const HomeScreen(),
          '/ChattingScreen': (BuildContext context) => ChattingScreen(),
          '/ShowListOfUsers': (BuildContext context) => const ShowListOfUsers(),
          '/ProfileScreen': (BuildContext context) => const ProfileScreen(),
        });
  }
}
