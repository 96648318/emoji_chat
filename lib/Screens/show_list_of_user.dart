import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:emoji_chat/Helpers/AppColors.dart';
import 'package:emoji_chat/Screens/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Helpers/ConstData.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import 'chating_screen.dart';

const iOSLocalizedLabels = false;

class ShowListOfUsers extends StatefulWidget {
  const ShowListOfUsers({Key key}) : super(key: key);

  @override
  _ShowListOfUsersState createState() => _ShowListOfUsersState();
}

class _ShowListOfUsersState extends State<ShowListOfUsers> {
  User user = FirebaseAuth.instance.currentUser;
  List<dynamic> Contactslist = [];
  List<dynamic> contactname = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          //phoneno = phoneno.substring(phoneno.length-10,phoneno.length);
          try {
            phoneno =
            "+91${phoneno.substring(0, 3).toString() == "+91" ? phoneno
                .substring(3, phoneno.length) : phoneno}";
          }catch (e){
            if (kDebugMode) {
              print("${e}");
            }

          } setState(() {
            Contactslist.add(phoneno);
            contactname.add(c.displayName);
          });
        }
      }
    } else {
      await Permission.contacts.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          titleSpacing: 0.0,
          title: const Text("Start Chat"),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("users").get().asStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.hasData) {
                if (snapshot.data.docs.isEmpty) {
                  return const Text("No Users Found");
                }
                return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      UserModel userModel = UserModel.fromMap(snapshot.data.docs[index].data());
                      if (userModel.uid ==
                          FirebaseAuth.instance.currentUser.uid) {
                        return Container();
                      }
                      for (int a = 0; a < Contactslist.length; a++) {
                        if (Contactslist[a].toString() ==
                                userModel.mobileNo.toString() &&
                            Contactslist[a].toString() !=
                                FirebaseAuth.instance.currentUser.phoneNumber) {
                          return InkWell(
                            onTap: () {
                              checkAndCreateNewRoom(userModel, context,
                                  contactname[a].toString());
                            },
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 32,
                                  backgroundImage: userModel.profileImage ==
                                          null
                                      ? NetworkImage(ConstData.profilelogo)
                                      : NetworkImage(userModel.profileImage),
                                ),
                                title: Text(contactname[a].toString()),
                                subtitle: Text(userModel.mobileNo),
                              ),
                            ),
                          );
                        }
                      }
                      return Container();
                    });
              }

              return const Center(child: CircularProgressIndicator());
            }));
  }

  String createRoomId(UserModel toChatUserModel) {
    // SmallId_LargeId
    String roomID = "";
    if (kDebugMode) {
      print(
          "createRoomId ${user.uid.hashCode} >> ${toChatUserModel.uid.hashCode} ");
      print("createRoomId ${user.uid} >> ${toChatUserModel.uid} ");
    }
    if (user.uid.hashCode > toChatUserModel.uid.hashCode) {
      roomID = toChatUserModel.uid + "_" + user.uid;
    } else if (user.uid.hashCode < toChatUserModel.uid.hashCode) {
      roomID = user.uid + "_" + toChatUserModel.uid;
    } else {
      roomID = user.uid + "_" + toChatUserModel.uid;
    }

    if (kDebugMode) {
      print("createRoomId @$roomID");
    }

    return roomID;
  }

  checkAndCreateNewRoom(
      UserModel toChatUserModel, BuildContext context, String Name) async {
    String roomId = createRoomId(toChatUserModel);

    CollectionReference roomCollectionReference =
        FirebaseFirestore.instance.collection("rooms");

    DocumentSnapshot documentSnapshot =
        await roomCollectionReference.doc(roomId).get();
    RoomModel roomModel = RoomModel();
    if (documentSnapshot.exists) {
      // already created a room
      roomModel = RoomModel.fromMap(documentSnapshot.data());
    } else {
      // create a new room
      roomModel.roomId = roomId;
      roomModel.peerId = toChatUserModel.uid;
      roomModel.participantsList = [];
      roomModel.participantsList.add(toChatUserModel.uid);
      roomModel.participantsList.add(user.uid);
      await roomCollectionReference.doc(roomId).set(roomModel.toMap());
    }

    if (roomModel != null) {
      Route route = MaterialPageRoute(
          builder: (context) => ChattingScreen(
                displayName: Name,
                roomModel: roomModel,
                userModel: toChatUserModel,
              ));
      Navigator.push(context, route).then(onGoBack);
    }
  }

  void refreshData() {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (ctx) => const HomeScreen()), (route) => false);
  }

  onGoBack(dynamic value) {
    refreshData();
    setState(() {});
  }
}
