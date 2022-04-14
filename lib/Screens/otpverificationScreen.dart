import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../Helpers/AppColors.dart';
import '../Helpers/ConstData.dart';
import '../models/user_model.dart';
import '../push_notifications.dart';
import 'HomeScreen.dart';
import 'ProfileScreen.dart';

class otpverificationScreen extends StatefulWidget {
  final dynamic number, verificationID;

  const otpverificationScreen({Key key, this.number, this.verificationID})
      : super(key: key);

  @override
  State<otpverificationScreen> createState() =>
      _otpverificationScreenScreenState();
}

class _otpverificationScreenScreenState extends State<otpverificationScreen> {
  final otpcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white30,
        width: double.infinity,
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                alignment: Alignment.center,
                child: Image.asset("assets/otp.gif"),
              ),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: const [
                      Text(
                        "OTP Verification",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.black54),
                      ),
                    ],
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      const Text(
                        "Enter the OTP send to",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      Text(
                        "+91 ${widget.number.toString().substring(0, 6)}XXXX",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                child: OTPTextField(
                    length: 6,
                    width: MediaQuery.of(context).size.width,
                    fieldWidth: 50,
                    style: const TextStyle(fontSize: 17),
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    fieldStyle: FieldStyle.box,
                    onChanged: (pin) {
                      if (kDebugMode) {
                        print("Completed: " + pin);
                      }
                    },
                    onCompleted: (pin) {
                      otpcontroller.text = pin.toString();
                    }),
              ),
              Container(
                padding: const EdgeInsets.only(top: 50),
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.primary,
                    elevation: 5,
                    padding: const EdgeInsets.only(
                        left: 35, right: 35, top: 5, bottom: 5),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () {
                    if (otpcontroller.text.isEmpty ||
                        otpcontroller.text.length != 6) {
                      ConstData.PopupMessageDialog(context, "Enter valid OTP");
                    } else {
                      if (kDebugMode) {
                        print(otpcontroller.text);
                      }
                      verifyOTP();
                    }
                  },
                  child: const Text("Verify OTP"),
                ),
              ),
              SizedBox(height: keyboardHeight,)
            ],
          ),
        ),
      ),
    );
  }

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationID, smsCode: otpcontroller.text);

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (kDebugMode) {
        print("Login successful");
      }
      postDetailsToFirestore();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        if (kDebugMode) {
          print("invalid---verification---code");
        }
        ConstData.PopupMessageDialog(context, "Enter Valid OTP");
      }
      if (kDebugMode) {
        print("E1 $e");
      }
    } catch (e) {
      if (kDebugMode) {
        print("E2 $e");
      }
    }
  }

  postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User user = FirebaseAuth.instance.currentUser;


    String notificationToken = await PushNotifications.getNotificationsToken();

    DocumentSnapshot variable = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();

    Map<String, dynamic> userData = variable.data() as Map<String, dynamic>;

    UserModel userModel = UserModel();
    userModel.uid = user.uid;
    // narimetisaigopi@gmail.com
    userModel.mobileNo = user.phoneNumber.toString();
    userModel.notificationtoken = notificationToken;

    if(userData==null){
      userModel.name = user.phoneNumber.toString();
      userModel.profileImage = ConstData.profilelogo;
    }else {
      if (userData["name"] == null || userData["name"] == "") {
        userModel.name = user.phoneNumber.toString();
      } else {
        userModel.name = userData["name"];
      }
      if (userData["profileImage"] == null || userData["profileImage"] == "") {
        userModel.profileImage = ConstData.profilelogo;
      } else {
        userModel.profileImage = userData["profileImage"];
      }
    }
    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text("User account created")));
    Route route = MaterialPageRoute(
        builder: (context) => const ProfileScreen(backToHome: true,
        ));
    Navigator.push(context, route).then(onGoBack);

    // Navigator.pushAndRemoveUntil(context,
    //     MaterialPageRoute(builder: (ctx) => HomeScreen()), (route) => false);
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
