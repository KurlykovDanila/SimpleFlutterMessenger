import 'package:dima_messager/model/dialog.dart';
import 'package:dima_messager/model/message.dart';
import 'package:dima_messager/model/model.dart';
import 'package:dima_messager/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

class DialogPage extends StatefulWidget {
  String username;

  DialogPage(this.username);

  @override
  _DialogPageState createState() => _DialogPageState(this.username);
}

class _DialogPageState extends State<DialogPage> {
  UserDialog dialog;
  bool _scroll = false;
  final messagesController = TextEditingController();
  final _controller = ScrollController();

  _DialogPageState(String username) {
    dialog = Model.api.dialogs[username];
  }

  bool _stop = false;

  bool _firstUpdate = true;

  @override
  void initState() {
    _update();
    Model.api.initMessages(dialog.username);

    super.initState();
  }

  void _update() async {
    await Future.delayed(Duration(seconds: 3));
    while (!_stop) {
      if (await Model.api.updateUnread(dialog.username))
        setState(() {
          children = [];
        });
      if (_firstUpdate) {
        _firstUpdate = false;
        Model.api.session.markAsRead(Model.api.user.token, dialog.username);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_scroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.animateTo(
            _controller.position.minScrollExtent,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
          ));
      _scroll = false;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(dialog.username),
        ),
        body: Column(children: [
          Expanded(flex: 1, child: _messages()),
          Container(
              color: Theme.of(context).dialogBackgroundColor,
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          constraints: BoxConstraints(maxHeight: 100),
                          margin: EdgeInsets.only(left: 20),
                          child: TextField(
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            controller: messagesController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'write message'),
                          ))),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.send_rounded),
                    onPressed: () {
                      if (messagesController.text.isNotEmpty) {
                        dialog.messages.add(Message(
                            messagesController.text,
                            Model.api.sendMessage(
                                dialog.username, messagesController.text),
                            Model.api.user.username));
                        messagesController.clear();
                        _scroll = true;
                        setState(() {});
                      }
                    },
                  )
                ],
              )),
        ]));
  }

  Widget message(Message mes, bool self) {
    final double rad = 15;
    return Align(
        alignment: (self) ? Alignment.topRight : Alignment.topLeft,
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            constraints: BoxConstraints(maxWidth: 300),
            child: Card(
                color: (self) ? Colors.blue[700] : Colors.blueGrey[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: (self) ? Radius.circular(rad) : Radius.zero,
                        topLeft: Radius.circular(rad),
                        topRight: Radius.circular(rad),
                        bottomRight:
                            (self) ? Radius.zero : Radius.circular(rad))),
                child: Column(
                    crossAxisAlignment: (self)
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(right: 15, left: 15, top: 15),
                          child: Text(
                            mes.text,
                            style: Theme.of(context).primaryTextTheme.subtitle1,
                          )),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(left: 5, top: 5, bottom: 5),
                              child: FutureBuilder(
                                future: mes.sended,
                                builder: (context, snapshot) {
                                  Widget child;
                                  if (snapshot.hasData && snapshot.data) {
                                    child = Icon(Icons.done, size: 15);
                                  } else if (snapshot.hasData &&
                                      !snapshot.data) {
                                    child = Icon(
                                      Icons.error_outline,
                                      size: 15,
                                    );
                                  } else {
                                    child = SizedBox(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                      height: 15,
                                      width: 15,
                                    );
                                  }
                                  return child;
                                },
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.all(5),
                                child: Text(
                                  '${mes.dateTime.hour}:${(mes.dateTime.minute < 10) ? "0" + mes.dateTime.minute.toString() : mes.dateTime.minute.toString()}',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .caption,
                                ))
                          ])
                    ]))));
  }

  List<Widget> children = [];
  Widget _messages() {
    children = [];
    for (var mes in this.dialog.messages) {
      children.add(message(mes, mes.fromUsername == Model.api.user.username));
    }
    if (children.isEmpty)
      children.add(Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Center(child: Text('No messages yet'))));
    return ListView(
      reverse: true,
      controller: this._controller,
      children: [Column(children: children)],
    );
  }

  @override
  void dispose() {
    _stop = true;
    Model.api.session.markAsRead(Model.api.user.token, dialog.username);
    // Clean up the controller when the widget is disposed.
    messagesController.dispose();
    super.dispose();
  }
}
