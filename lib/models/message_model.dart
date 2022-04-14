import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageModel {
  String message;
  Timestamp timeStamp;
  String senderId;
  String isread;

  MessageModel({this.message, this.timeStamp, this.senderId, this.isread});

  factory MessageModel.fromMap(Map map) {
    return MessageModel(
      message: map['message'],
      timeStamp: map['timeStamp'],
      senderId: map['senderId'],
      isread: map['isread'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'timeStamp': FieldValue.serverTimestamp(),
      'senderId': FirebaseAuth.instance.currentUser.uid,
      'isread': isread
    };
  }
}
