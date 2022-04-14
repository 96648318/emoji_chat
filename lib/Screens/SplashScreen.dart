import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:emoji_chat/Helpers/StateManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'show_list_of_user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<SplashScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isLogin = false;

  startTime() async {
    final User user = auth.currentUser;
    if (kDebugMode) {
      print("User$user");
    }
    var _duration = const Duration(seconds: 3);
    if (user != null) {
      setState(() {
        isLogin = true;
      });
    }
    return Timer(_duration, navigationPage);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    startTime();
    _askPermissions();
  }

  List<String> Contactslist = [];
  List<String> contactname = [];
  Map<String, dynamic> map = HashMap();

  Future<void> _askPermissions() async {
    PermissionStatus permission = await Permission.contacts.request();
    if (permission.isGranted) {
      Contactslist = [];
      contactname = [];
      dynamic contacts = await ContactsService.getContacts(
          withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels);
      for (int a = 0; a < contacts.length; a++) {
        Contact c = contacts?.elementAt(a);
        for (int x = 0; x < c.phones.length; x++) {
          var phoneno = c.phones[x].value.replaceAll(" ", "");
          phoneno = phoneno.replaceAll("-", "");
          phoneno = phoneno.replaceAll("(", "");
          phoneno = phoneno.replaceAll(")", "");
          try {
            phoneno =
                "+91${phoneno.substring(0, 3).toString() == "+91" ? phoneno.substring(3, phoneno.length) : phoneno}";
          } catch (e) {
            if (kDebugMode) {
              print("${e}");
            }
          }
          //  setState(() {
          Contactslist.add(phoneno);
          contactname.add(c.displayName);
          //  });
        }
      }
      if (isLogin != null && isLogin) {
        getcontactlist();
      }
      // for (int a = 0; a < Contactslist.length; a++) {
      //   map["${Contactslist[a]}"] = contactname[a];
      // }
      await StateManager.contactlist(Contactslist, contactname);
    } else {
      await Permission.contacts.request();
    }
  }

  getcontactlist() async {
    QuerySnapshot<Map<String, dynamic>> variable =
        await FirebaseFirestore.instance.collection('users').get();
    //print(variable.docs[0].data()["name"]);
    for (int a = 0; a < variable.docs.length; a++) {
      if (Contactslist.indexOf(variable.docs[a].data()["mobileNo"]) > -1) {
        map[variable.docs[a].data()["mobileNo"]] = contactname[
            Contactslist.indexOf(variable.docs[a].data()["mobileNo"])];
      }
    }
    //print(map);
    Map<String, dynamic> map1 = Map();
    map1['Contactlist'] = map;

    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update(map1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    "assets/Blisslogo.jpeg",
                    height: 200,
                    width: 200,
                  )
                  //Text("EmojiChat")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigationPage() {
    if (isLogin != null && isLogin) {
      Navigator.of(context).pushReplacementNamed('/HomeScreen');
    } else {
      Navigator.of(context).pushReplacementNamed('/LoginScreen');
    }
  }
}
