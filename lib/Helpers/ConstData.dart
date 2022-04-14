

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

class ConstData {

  static  String profilelogo = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSppofOFi_mWX-jMsOD26xTKP_h1D_nk_8uFA&usqp=CAU";

  static progressDialog(BuildContext context) async {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              Navigator.pop(context);
              return;
            },
            child: alert);
      },
    );
  }

  static NoInternetConnection(BuildContext context) async {
    AlertDialog alert = AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
            child: Container(
          width: MediaQuery.of(context).size.height,
          color: Colors.white,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset("assets/Lotti/no-internet-connection.json",
                  height: 170, width: 170),
              const Text(
                "No Internet Connection !",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                "Please Check Your Internet Connection",
                style: TextStyle(
                  // fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow,
                  elevation: 5,
                  padding: const EdgeInsets.only(left: 35,right: 35,top: 5,bottom: 5),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        )));
    showDialog(
      //prevent outside touch
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        //prevent Back button press
        return WillPopScope(
            onWillPop: () {
              Navigator.pop(context);
              return;
            },
            child: alert);
      },
    );
  }

  static PopupMessageDialog(context, message) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        actionsPadding: const EdgeInsets.all(0),
        buttonPadding: const EdgeInsets.all(0),
        titlePadding: const EdgeInsets.only(top: 10),
        title: const Icon(
          Icons.error_outline_outlined,
          color: Colors.red,
          size: 50,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              color: Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Column(
                children: [
                  Wrap(
                    children: [
                      Text(
                        message,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow,
                elevation: 5,
                padding: const EdgeInsets.only(left: 35,right: 35,top: 5,bottom: 5),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.only(bottom: 10),
      ),
    );
  }



  static Color hexToColor(String code) {
    return  Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static Future<bool> checkNetworkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  static toastError(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static toastNormal(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor:Colors.white,
        fontSize: 16.0);
  }



  static timeDatePickerTheme(child, isDark, context) {
    return Theme(
      data: isDark
          ? ThemeData.dark().copyWith(
              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            )
          : ThemeData.light().copyWith(
              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
      child: child,
    );
  }
}
