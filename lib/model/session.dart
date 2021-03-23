import 'package:http/http.dart' as http;
import 'dart:convert';

class Session {
  String _root = 'http://192.168.1.108:5000/';

  void addRoot(String root) {
    _root = root;
  }

  Future<http.Response> _postSafe(String url, Map<String, String> data) async {
    try {
      return await http.post(_root + url, body: data);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> markAsRead(String token, String username) async {
    var resp = await _postSafe(
        'messages.markasread', {'token': token, 'username': username});
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> getInfo(String token) async {
    var resp = await _postSafe('user.getfullinfo', {'token': token});
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> register(
      String email, String password, String username, String name) async {
    var resp = await _postSafe('auth.register', {
      'email': email,
      'password': password,
      'username': username,
      'name': name
    });
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> getMessages(String username, String token, int from,
      [int count = 1000]) async {
    var resp = await _postSafe('messages.get', {
      'token': token,
      'username': username,
      'from': from.toString(),
      'to': (from + count).toString()
    });
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> getToken(String email, String password) async {
    var resp = await _postSafe(
        'auth.gettoken', {'email': email, 'password': password});
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> getBlocked(String token) async {
    var resp = await _postSafe('user.getblocked', {'token': token});
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> getDialogues(String token) async {
    var resp = await _postSafe('user.getdialogues', {'token': token});
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> getUnread(String token, String username) async {
    var resp = await _postSafe(
        'messages.getunread', {'token': token, 'username': username});
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> block(String token, String otherUsername) async {
    var resp = await _postSafe(
        'user.block', {'token': token, 'username': otherUsername});
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> getName(String username) async {
    var resp = await _postSafe('user.getname', {'username': username});
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }

  Future<dynamic> sendMessage(
      String token, String username, String content) async {
    var resp = await _postSafe('messages.send',
        {'token': token, 'username': username, 'content': content});
    return json.decode(resp?.body ?? '{"isSuccess": false}');
  }
}
