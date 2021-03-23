import 'package:dima_messager/model/message.dart';

class UserDialog {
  bool blocked;
  String username = 'Username';
  String name = 'Name';
  List<Message> messages = [];

  UserDialog.fromJson(this.username);

  int unreadCount() {
    int count = 0;
    for (var mes in this.messages) {
      if (mes.unread) count++;
    }
    return count;
  }

  void addMessageBefore() {}
}
