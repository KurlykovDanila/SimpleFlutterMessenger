import 'package:dima_messager/model/dialog.dart';
import 'package:dima_messager/model/model.dart';
import 'package:flutter/material.dart';

class AlertAddDialog extends StatefulWidget {
  @override
  _AlertAddDialogState createState() => _AlertAddDialogState();
}

class _AlertAddDialogState extends State<AlertAddDialog> {
  final usernameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create dialog'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'Enter the username of the user with whom you want to start chatting.'),
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
                border: UnderlineInputBorder(), hintText: 'username'),
          )
        ],
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('CANCEL'),
        ),
        FlatButton(
            onPressed: () {
              if (usernameController.text.isNotEmpty)
                Navigator.of(context)
                    .pop(Model.api.addDialog(usernameController.text));
            },
            child: Text('ADD')),
      ],
    );
  }
}
