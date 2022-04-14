import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String mobileNo;
  String name;
  String profileImage;
  String status;
  String notificationtoken;
  Map Contactlist;
  var timeStamp;

  UserModel({
    this.uid,
    this.mobileNo,
    this.name,
    this.profileImage,
    this.timeStamp,
    this.notificationtoken,
    this.Contactlist,
    this.status,
  });

  // data from server parsing
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      mobileNo: map['mobileNo'],
      name: map['name'],
      Contactlist: map['Contactlist'],
      profileImage: map['profileImage'],
      timeStamp: map['timeStamp'],
      notificationtoken: map['notificationtoken'],
      status: map['status'],
    );
  }

  // sending data to server

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'mobileNo': mobileNo,
      'name': name,
      'Contactlist': Contactlist,
      'notificationtoken': notificationtoken,
      'profileImage': profileImage,
      'timeStamp': FieldValue.serverTimestamp(),
      'status': status,
    };
  }
}
