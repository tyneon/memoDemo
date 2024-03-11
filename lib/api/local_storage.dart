import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static late SharedPreferences instance;
  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }
}
