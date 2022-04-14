import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:emoji_chat/Helpers/AppColors.dart';
import 'package:emoji_chat/Screens/LoginScreen.dart';
import 'package:emoji_chat/Screens/ProfileScreen.dart';
import 'package:emoji_chat/Screens/chating_screen.dart';
import 'package:emoji_chat/Screens/show_list_of_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/room_model.dart';
import '../models/user_model.dart';
import '../utilities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  User user = FirebaseAuth.instance.currentUser;
  CollectionReference chatsCollectionReferance;
  List<dynamic> Contactslist = [];
  List<dynamic> contactname = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
    _askPermissions();
  }

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
              print("$e");
            }
          }
          setState(() {
            Contactslist.add(phoneno);
            contactname.add(c.displayName);
          });
        }
      }
    } else {
      await Permission.contacts.request();
    }
  }

  void setStatus(String status) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus("Online");
    } else {
      setStatus("Offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text("BLISS"),
          actions: <Widget>[
            // _shoppingCartBadge(),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  child: Text("Profile"),
                  value: 1,
                ),
                const PopupMenuItem(
                  child: Text("Logout"),
                  value: 2,
                )
              ],
              onSelected: (item) => selectedItem(context, item),
            ),
          ]),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("rooms")
              .where("participantsList", arrayContains: user.uid.toString())
              .orderBy("timeStamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              if (snapshot.data.docs.isEmpty) {
                return const Center(child: Text("No rooms"));
              }
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  RoomModel roomModel =
                      RoomModel.fromMap(snapshot.data.docs[index].data());
                  return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(roomModel.senderId == user.uid
                              ? roomModel.peerId
                              : roomModel.senderId)
                          .get()
                          .asStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          UserModel userModel =
                              UserModel.fromMap(snapshot.data);
                          var displayName = "";
                          for (int a = 0; a < Contactslist.length; a++) {
                            if (Contactslist[a].toString() ==
                                userModel.mobileNo.toString()) {
                              displayName = contactname[a];
                              break;
                            }
                          }
                          return Card(
                            child: ListTile(
                                onTap: () {
                                  Route route = MaterialPageRoute(
                                      builder: (context) => ChattingScreen(
                                            displayName: displayName == ""
                                                ? userModel.mobileNo
                                                : displayName,
                                            roomModel: roomModel,
                                            userModel: userModel,
                                          ));
                                  Navigator.push(context, route).then(onGoBack);
                                },
                                leading: CircleAvatar(
                                  radius: 32,
                                  backgroundImage:
                                      NetworkImage(userModel.profileImage),
                                ),
                                title: Container(
                                  padding: const EdgeInsets.only(bottom: 7),
                                  child: Text(displayName == ""
                                      ? userModel.mobileNo
                                      : displayName),
                                ),
                                subtitle: Text(roomModel.lastMessage.length > 30
                                    ? roomModel.lastMessage.substring(0, 30)
                                    : roomModel.lastMessage ?? ""),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(roomModel.timeStamp != null
                                            ? Utilities
                                                .displayTimeAgoFromTimestamp(
                                                    roomModel.timeStamp
                                                        .toDate()
                                                        .toString())
                                            : ""),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        SizedBox(
                                          height: 25,
                                          child: getChatCount(roomModel.roomId),
                                        )
                                      ],
                                    )
                                  ],
                                )),
                          );
                          //   }
                          // }
                        }
                        return Container();
                      });
                },
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        elevation: 15,
        backgroundColor: AppColors.primary,
        onPressed: () {
          Route route =
              MaterialPageRoute(builder: (context) => const ShowListOfUsers());
          Navigator.push(context, route).then(onGoBack);
        },
        child: const Icon(
          Icons.chat_bubble_outline_sharp,
        ),
      ),
    );
  }

  Widget getChatCount(String roomId) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .doc(roomId)
            .collection('messages')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(),
            );
          } else if (snapshot.connectionState == ConnectionState.none) {
            return const Text('None');
          } else {
            return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection("chats")
                    .doc(roomId)
                    .collection('messages')
                    .get(),
                builder: (context, sna) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(),
                    );
                  } else {
                    int count = 0;
                    if (sna.data != null) {
                      List<dynamic> listData = sna.data.docs;
                      for (int i = 0; i < listData.length; i++) {
                        if (listData[i].data()['isread'].toString() == 'U' &&
                                listData[i].data()['senderId'].toString() !=
                                    user.uid.toString() ||
                            listData[i].data()['isread'].toString() == 'N' &&
                                listData[i].data()['senderId'].toString() !=
                                    user.uid.toString()) {
                          count++;
                        }
                      }
                    }

                    return Badge(
                      badgeColor: Colors.lightGreen,
                      position: BadgePosition.topEnd(top: 110, end: -1),
                      // animationDuration: const Duration(milliseconds: 0),
                      badgeContent: Text(
                        count.toString(),
                      ),
                      showBadge: count == 0 ? false : true,
                      //  animationType: BadgeAnimationType.fade,
                    );
                  }
                });
          }
        });
  }

  void refreshData() {
    setState(() {});
  }

  onGoBack(dynamic value) {
    refreshData();
    setState(() {});
  }

  //
  // Future<dynamic> unreadmsgcount(RoomModel romModel) async {
  //   CollectionReference ref = await FirebaseFirestore.instance
  //       .collection("chats")
  //       .doc(romModel.roomId)
  //       .collection("messages");
  //   QuerySnapshot eventsQuery = await ref.orderBy("timeStamp").get();
  //   count = 0;
  //   for (int i = 0; i < eventsQuery.docs.length; i++) {
  //     DocumentSnapshot result = eventsQuery.docs[i];
  //     Map<String, dynamic> dt = result.data();
  //     if (result["senderId"].toString() !=
  //             FirebaseAuth.instance.currentUser.uid &&
  //         (result["isread"] == null || result["isread"] == "N")) {
  //       setState(() {
  //         count++;
  //       });
  //     }
  //   }
  // }

  Future<void> selectedItem(BuildContext context, item) async {
    switch (item) {
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ProfileScreen(backToHome: false)));
        break;
      case 2:
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (ctx) => const LoginScreen()),
            (route) => false);
        break;
    }
  }
}
