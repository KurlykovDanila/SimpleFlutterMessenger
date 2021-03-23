import 'package:dima_messager/model/dialog.dart';
import 'package:dima_messager/model/session.dart';
import 'package:dima_messager/model/user.dart';
import 'package:tuple/tuple.dart';
import 'message.dart';

class Model {
  static bool chageTheme = false;
  static final api = Api();
}

class Api {
  final session = Session();
  User user = User.empty();
  Map<String, UserDialog> dialogs = {};
  Future<bool> dialogsInit;

  Future<bool> init() async {
    await user.read();
    if (user.token != null) {
      Model.api.dialogsInit = Model.api.initDialogs();
    }
    return user.token != null;
  }

  Future<bool> login(String email, String password) async {
    var resp = await session.getToken(email, password);
    if (resp['isSuccess'] == true) {
      user.token = resp['data'];
      user.save();
    } else
      return false;
    resp = await session.getInfo(user.token);
    if (resp['isSuccess'] == true) {
      user.name = resp['data']['name'];
      user.username = resp['data']['username'];
      user.save();
    } else
      return false;
    clearAll();
    Model.api.dialogsInit = Model.api.initDialogs();
    return true;
  }

  Future<bool> getDialogs() async {
    var resp = await session.getDialogues(user.token);
    if (resp['isSuccess'] == true) {
      List dialogs = resp['data'];
      for (var dialog in dialogs) {
        if (dialog['username'] != user.username) {
          this.dialogs[dialog['username']] =
              UserDialog.fromJson(dialog['username']);
        }
      }
    }
    return resp['isSuccess'] == true;
  }

  Future<bool> addDialog(String username) async {
    var resp = await session.getName(username);
    if (resp['isSuccess'] == true) {
      this.dialogs[username] = UserDialog.fromJson(username);
      this.dialogs[username].name = resp['data'];
    }
    return resp['isSuccess'] == true;
  }

  Future<bool> initMessages(String username) async {
    var resp = await session.getMessages(username, user.token, 0);
    if (resp['isSuccess'] == true) {
      dialogs[username].messages = [];
      List data = resp['data'];
      for (var mes in data) {
        if (mes != null) {
          dialogs[username].messages.add(Message.fromJson(mes));
        }
      }
    } else {}
    return resp['isSuccess'];
  }

  void clearAll() {
    this.dialogs = {};
  }

  Future<bool> updateUnread(String username) async {
    await Future.delayed(Duration(seconds: 2));
    return (await addUnread(username)).item2;
  }

  bool itOldMes(String username, Message message) {
    for (var oldMes in this.dialogs[username].messages) {
      if (oldMes.id == message.id) return true;
    }
    return false;
  }

  Future<List<bool>> updateAll() async {
    await Future.delayed(Duration(seconds: 1));
    initDialogs();
    List<bool> ans = [];
    Tuple2<bool, bool> res;
    for (var username in this.dialogs.keys) {
      res = await addUnread(username);
      ans.add(res.item1 && res.item2);
    }
    return ans;
  }

  Future<Tuple2<bool, bool>> addUnread(String username) async {
    var hasNew = false;
    var resp = await session.getUnread(user.token, username);
    if (resp['isSuccess'] == true) {
      if (this.dialogs.containsKey(username)) {
        List data = resp['data']['messages'];
        for (var mes in data.reversed) {
          if (mes != null) {
            var mess = Message.fromJsonUnred(mes, username);
            if (!itOldMes(username, mess)) {
              print('new message!!!');
              hasNew = true;
              dialogs[username].messages.add(mess);
            }
          }
        }
      }
    }
    return Tuple2(resp['isSuccess'] == true, hasNew);
  }

  Future<bool> initDialogs() async {
    var ans = await getDialogs();
    if (!ans) return false;
    List<Future<bool>> f = [];
    for (var username in dialogs.keys) {
      f.add(addNameToDialog(username));
    }
    var l = await Future.wait(f);
    for (var b in l) {
      if (!b) return false;
    }
    f = [];
    for (var username in dialogs.keys) {
      f.add(initMessages(username));
    }
    l = [];
    l = await Future.wait(f);
    for (var b in l) {
      if (!b) return false;
    }
    return true;
  }

  Future<bool> updateDialogs() async {
    var resp = await session.getDialogues(user.token);
    var ans = false;
    if (resp['isSuccess'] == true) {
      List dialogs = resp['data'];
      for (var dialog in dialogs) {
        if (!this.dialogs.containsKey(dialog['username'])) {
          ans = true;
          this.dialogs[dialog['username']] =
              UserDialog.fromJson(dialog['username']);
          await this.addNameToDialog(dialog['username']);
          await this.addUnread(dialog['username']);
        }
      }
    }
    return ans;
  }

  Future<bool> addNameToDialog(String username) async {
    var resp = await session.getName(username);
    if (resp['isSuccess'] == true && dialogs.containsKey(username)) {
      dialogs[username].name = resp['data'];
    }
    return resp['isSuccess'] == true;
  }

  Future<bool> sendMessage(String username, String message) async {
    var resp = await session.sendMessage(user.token, username, message);
    print(resp['isSuccess']);
    return resp['isSuccess'] == true;
  }

  Future<bool> register(
      String email, String name, String username, String password) async {
    var resp = await session.register(email, password, username, name);
    if (resp['isSuccess'] == true) {
      user.name = name;
      user.username = username;
      resp = await session.getToken(email, password);
      if (resp['isSuccess'] == true) {
        user.token = resp['data'];
      }
      user.save();
      Model.api.dialogsInit = Model.api.initDialogs();
      clearAll();
      return resp['isSuccess'];
    }
    return resp['isSuccess'];
  }
}
