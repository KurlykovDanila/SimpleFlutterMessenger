import 'package:dima_messager/model/model.dart';
import 'package:dima_messager/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  BuildContext themeContext;

  SettingsPage(this.themeContext);

  @override
  _SettingsPageState createState() => _SettingsPageState(themeContext);
}

class _SettingsPageState extends State<SettingsPage> {
  BuildContext themeContext;

  _SettingsPageState(this.themeContext);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text("Settings"),
        ),
        body: ListView(children: [
          SwitchListTile(
            value: ThemeProvider.themeOf(themeContext).data == ThemeData.dark(),
            title: Text("Dark theme"),
            onChanged: (value) {
              Model.chageTheme = true;
              ThemeProvider.controllerOf(themeContext).nextTheme();
            },
          ),
          InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            LoginPage(themeContext)),
                    (Route<dynamic> route) => false);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: ListTile(
                    title: Text('Exit from account'),
                  )),
                  Flexible(
                      child: Container(
                          margin: EdgeInsets.only(right: 30),
                          child: Icon(Icons.exit_to_app)))
                ],
              ))
        ]));
  }
}
