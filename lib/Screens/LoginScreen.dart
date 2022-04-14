import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Helpers/AppColors.dart';
import '../Helpers/ConstData.dart';
import '../models/user_model.dart';
import '../push_notifications.dart';
import 'HomeScreen.dart';
import 'ProfileScreen.dart';
import 'otpverificationScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<LoginScreen> {
  final Contactcontroller = TextEditingController();
  final Passwordcontroller = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationID = "";

  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Login"),
      // ),
      resizeToAvoidBottomInset: false,
      body: Container(
          color: Colors.white,
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
                  padding: const EdgeInsets.only(top: 50),
                  child: Image.asset("assets/Loginpagelogo.jpg"),
                ),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: const [
                        Text(
                          "Verify your",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Phone number",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                      ],
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: const [
                        Text(
                          "Please enter your mobile number",
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        Text(
                          "and we'll send you OTP",
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        Text(
                          "verification code",
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                      ],
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
                  child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        validator: (values) {
                          if (values == "" || values?.length != 10) {
                            return 'Enter Valid Contact Number';
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        // autofillHints: [AutofillHints.telephoneNumber],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            labelText: 'Mobile Number'),
                        controller: Contactcontroller,
                      )),
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
                    onPressed: ()  {
                      if (Contactcontroller.text.isEmpty ||
                          Contactcontroller.text.length != 10) {
                        ConstData.PopupMessageDialog(
                            context, "Enter valid Mobile Number");
                      }else{
                        loginWithPhone();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => otpverificationScreen(
                                  number: Contactcontroller.text,
                                  verificationID: verificationID,
                                )));

                      }
                    },
                    child: const Text("Get OTP"),
                  ),
                ),
                SizedBox(height: keyboardHeight,)
              ],
            ),
          )),
    );
  }
  void refreshData() {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (ctx) =>  const HomeScreen()), (route) => false);
  }

  onGoBack(dynamic value) {
    refreshData();
    setState(() {});
  }
  void loginWithPhone() async {
   await auth.verifyPhoneNumber(
      phoneNumber: "+91" + Contactcontroller.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          if (kDebugMode) {
            print("You are logged in successfully");
          }

          postDetailsToFirestore() ;

          // Navigator.pushAndRemoveUntil(context,
          //     MaterialPageRoute(builder: (ctx) => HomeScreen()), (route) => false);

        });
      },
      verificationFailed: (FirebaseAuthException e) {
        if (kDebugMode) {
          print(e.message);
        }
      },
      codeSent: (String verificationId, int resendToken) {
        verificationID = verificationId;
        if (kDebugMode) {
          print(resendToken);
        }
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
}
