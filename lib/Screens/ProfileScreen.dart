import 'dart:collection';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:emoji_chat/Helpers/AppColors.dart';
import 'package:emoji_chat/Helpers/ConstData.dart';
import 'package:emoji_chat/Screens/show_list_of_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import 'HomeScreen.dart';

class ProfileScreen extends StatefulWidget {
  final bool backToHome;
  const ProfileScreen({Key key, this.backToHome}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<ProfileScreen> {
  final namecontroller = TextEditingController();
  XFile pickedFile;
  File imageFile;
  String imagename;
  Map<String, dynamic> userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetUserProfileData();
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
            "+91${phoneno.substring(0, 3).toString() == "+91" ? phoneno
                .substring(3, phoneno.length) : phoneno}";
          }catch (e){
            if (kDebugMode) {
              print("$e");
            }
          }
          //  setState(() {
          Contactslist.add(phoneno);
          contactname.add(c.displayName);
          //  });
        }
      }
        getcontactlist();
    } else {
      await Permission.contacts.request();
    }
  }

  getcontactlist() async {
    QuerySnapshot<Map<String, dynamic>> variable = await FirebaseFirestore.instance
        .collection('users').get() ;
    //print(variable.docs[0].data()["name"]);
    for(int a=0; a<variable.docs.length; a++){
      if(Contactslist.indexOf(variable.docs[a].data()["mobileNo"]) > -1){
        map[variable.docs[a].data()["mobileNo"]] = contactname[Contactslist.indexOf(variable.docs[a].data()["mobileNo"])];
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
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: AppColors.primary,
          titleSpacing: 0.0,
          actions: [
            TextButton(
                onPressed: () {
                  updateProfile(context);
                },
                child: Text(
                  "SAVE",
                  style: TextStyle(color: AppColors.white_color, fontSize: 16),
                )),
            const SizedBox(
              width: 5,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(top: 30),
                  alignment: Alignment.center,
                  child: Badge(
                    badgeColor: AppColors.primary,
                    position: BadgePosition.topEnd(top: 110, end: -1),
                    animationDuration: const Duration(milliseconds: 300),
                    badgeContent: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.white_color,
                        ),
                        onPressed: () {
                          _showPicker(context);
                        },
                      ),
                    ),
                    animationType: BadgeAnimationType.slide,
                    child: GestureDetector(
                      child: Container(
                          child: imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.file(
                                    imageFile,
                                    width: 170,
                                    height: 170,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 85,
                                  backgroundImage: NetworkImage(userData == null
                                      ? ConstData.profilelogo
                                      : userData["profileImage"]),
                                  backgroundColor: AppColors.white_color,
                                )),
                    ),
                  )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.grey_color,
                    ),
                    padding: const EdgeInsets.only(left: 15, top: 72),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            top: 60, left: 10, right: 10),
                        child: TextFormField(
                          controller: namecontroller,

                          validator: (str) {
                            if (str == "") {
                              return "Password Can't be blank";
                            }
                            return null;
                          },
                          // focusNode: focusNode,
                          decoration: InputDecoration(
                              labelText: "Name",
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.primary,
                                ), onPressed: () {  },
                              )),
                          style: const TextStyle(
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                            "This is not your username or pin. This name will be visible to your Bliss contacts."),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: const Divider(),
                      )
                    ],
                  ))
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      child: Icon(
                        Icons.phone,
                        size: 30,
                        color: AppColors.grey_color,
                      ),
                      padding: const EdgeInsets.only(left: 15),
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: const Text(
                            "Phone",
                            style: TextStyle(color: Colors.black38),
                          ),
                          padding: const EdgeInsets.only(left: 10),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10, top: 5),
                          child: Text(
                            userData == null ? "" : userData["mobileNo"],
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              )
            ],
          ),
        ));
  }

  GetUserProfileData() async {
    DocumentSnapshot variable = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();

    setState(() {
      userData = variable.data() as Map<String, dynamic>;
      namecontroller.text = userData["name"].toString();
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () async {
                      pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          imageFile = File(pickedFile.path);
                          imagename = pickedFile.name.toString();
                          if (kDebugMode) {
                            print(imagename);
                          }
                        });
                      }
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () async {
                    PickedFile pickedFile = await ImagePicker().getImage(
                      source: ImageSource.camera,
                      maxWidth: 1800,
                      maxHeight: 1800,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        imageFile = File(pickedFile.path);
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove'),
                  onTap: () async {
                    var collection =
                        FirebaseFirestore.instance.collection('users');
                    collection
                        .doc(FirebaseAuth.instance.currentUser
                            .uid) // <-- Doc ID where data should be updated.
                        .update({
                          'profileImage': ConstData.profilelogo
                        }) // <-- Updated data
                        .then((_) => print('Updated'))
                        .catchError((error) => print('Update failed: $error'));
                    GetUserProfileData();
                    ConstData.toastNormal("Removed");
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  updateProfile(BuildContext context) async {
    Map<String, dynamic> map = Map();
    if (imageFile != null) {
      String url = await uploadImage();
      map['profileImage'] = url;
    }
    map['name'] = namecontroller.text;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update(map);
    ConstData.toastNormal("Profile Updated Successfully");
    if(widget.backToHome){
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (ctx) => const HomeScreen()), (route) => false);
    }
  }

  Future<String> uploadImage() async {
    TaskSnapshot taskSnapshot = await FirebaseStorage.instance
        .ref()
        .child("profile")
        .child(FirebaseAuth.instance.currentUser.uid +
            "_" +
            basename(imageFile.path))
        .putFile(imageFile);

    return taskSnapshot.ref.getDownloadURL();
  }
}
