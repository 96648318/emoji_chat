import 'package:shared_preferences/shared_preferences.dart';

class StateManager {
  static Future<bool> contactlist(var data, var name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('contactlist', data);
    prefs.setStringList('contactname', name);
    return true;
  }

  static Future<List<String>> getcontactlist() async {
   // SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('contactlist');
  }

  static Future<List<String>> getcontactname() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('contactname');
  }
}
