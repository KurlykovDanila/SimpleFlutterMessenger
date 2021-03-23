class Message {
  Future<bool> sended = Future.value(true);
  String id;
  String fromUsername;
  String toUsername;
  bool unread;
  String text;
  DateTime dateTime = DateTime.now();
  static Duration timzone = DateTime.now().timeZoneOffset;

  Message(this.text, this.sended, this.fromUsername);

  Message.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    text = json['content'];
    print(text);
    fromUsername = json['fromUsername'];
    toUsername = json['toUsername'];
    unread = json['unread'];
    dateTime = DateTime.fromMicrosecondsSinceEpoch(
        (int.tryParse(json['date']) ?? 0) * 1000);
    dateTime.add(timzone);
  }

  Message.fromJsonUnred(Map<String, dynamic> json, String username) {
    id = json['_id'];
    text = json['content'];
    unread = json['unread'];
    dateTime = DateTime.fromMicrosecondsSinceEpoch(
        (int.tryParse(json['date']) ?? 0) * 1000,
        isUtc: true);
    dateTime.add(timzone);
    fromUsername = username;
  }
}
