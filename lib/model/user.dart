import 'package:shared_preferences/shared_preferences.dart';

class User {
  String username;
  String name;
  String token;
  User(this.name, this.token, this.username);
  User.empty();

  void read() async {
    var prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    username = prefs.getString('username');
    name = prefs.getString('name');
  }

  void save() async {
    var prefs = await SharedPreferences.getInstance();
    List<Future> f = [];
    f.add(prefs.setString('token', token));
    f.add(prefs.setString('username', username));
    f.add(prefs.setString('name', name));
    await Future.wait(f);
  }
}
