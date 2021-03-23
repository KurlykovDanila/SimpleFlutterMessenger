import 'package:dima_messager/model/dialog.dart';
import 'package:dima_messager/model/model.dart';
import 'package:dima_messager/pages/dialog.dart';
import 'package:dima_messager/pages/login.dart';
import 'package:dima_messager/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:tuple/tuple.dart';

import 'allert.dart';

class MyApp extends StatelessWidget {
  static const _colorScheme = ColorScheme(
      primary: Colors.blue,
      primaryVariant: Colors.blueGrey,
      secondary: Colors.grey,
      secondaryVariant: Colors.lightBlue,
      surface: Colors.white,
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light);
  ThemeData _darkTheme = ThemeData.from(colorScheme: MyApp._colorScheme);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
        saveThemesOnChange: true,
        loadThemeOnInit: true,
        themes: [
          AppTheme
              .dark(), // This is standard light theme (id is default_light_theme)
          AppTheme
              .light(), // This is standard dark theme (id is default_dark_theme)
        ],
        child: ThemeConsumer(
          child: Builder(
              builder: (themeContext) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeProvider.themeOf(themeContext).data,
                  title: 'Gessenger',
                  home: Builder(builder: (context) {
                    if (Model.chageTheme) {
                      return TextingPage(themeContext);
                    }
                    return FutureBuilder(
                      future: Model.api.init(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data) {
                            return TextingPage(themeContext);
                          } else
                            return LoginPage(themeContext);
                        } else {
                          return LoadingPage();
                        }
                      },
                    );
                  }))),
        ));
  }
}

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class TextingPage extends StatefulWidget {
  BuildContext themeContext;

  TextingPage(this.themeContext);
  @override
  _TextingPageState createState() => _TextingPageState(this.themeContext);
}

class _TextingPageState extends State<TextingPage> {
  BuildContext themeContext;
  final _controller = ScrollController();

  _TextingPageState(this.themeContext);

  List<Widget> _children = [];

  @override
  void initState() {
    _update();
    super.initState();
  }

  void _update() async {
    await Future.delayed(Duration(seconds: 3));
    bool ans;
    while (true) {
      await Future.delayed(Duration(seconds: 3));
      ans = await Model.api.updateDialogs();
      if (ans) {
        print('add new dialog');
        setState(() {});
      }
    }
  }

  void _initChildren(BuildContext context) {
    _children = [];
    for (var dialog in Model.api.dialogs.values.toList().reversed) {
      _addDialog(context, dialog);
    }
  }

  void _addDialog(BuildContext context, UserDialog dialog) {
    _children.add(InkWell(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialogWidget(dialog.username));
        },
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DialogPage(dialog.username))),
        child: Container(
            padding: EdgeInsets.only(right: 7, left: 7),
            child: ListTile(
              title: Text(dialog.name),
            ))));
    _children.add(Divider(
      height: 0,
      indent: 10,
      endIndent: 10,
      thickness: 1.3,
    ));
  }

  Widget dialogs(BuildContext context) {
    _initChildren(context);
    return Flexible(
        child: ListView(
      controller: this._controller,
      children: _children,
    ));
  }

  bool _addedDiaog = false;

  SnackBar _dialogAddedSuccess =
      SnackBar(content: Text('Dialog added successfully'));
  SnackBar _noUser =
      SnackBar(content: Text('No user with this username was found'));
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(themeContext)));
              },
              tooltip: "Settings",
            ),
          ],
          title: Container(
            child: Text("Messages"),
            margin: EdgeInsets.only(left: 10),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.create),
          onPressed: () {
            showDialog<Future<bool>>(
                context: context,
                builder: (context) => AlertAddDialog()).then((value) {
              if (value != null) {
                value.then((res) {
                  setState(() {});
                  _addedDiaog = false;
                  if (res)
                    _scaffoldKey.currentState.showSnackBar(_dialogAddedSuccess);
                  else
                    _scaffoldKey.currentState.showSnackBar(_noUser);
                });
                setState(() {
                  _addedDiaog = true;
                });
              }
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: FutureBuilder(
          future: Model.api.dialogsInit,
          builder: (context, snapshot) {
            if (_addedDiaog) {
              return LinearProgressIndicator();
            }
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done &&
                snapshot.data) {
              return Column(
                children: [dialogs(context)],
              );
            } else if (snapshot.hasData && snapshot.data == false) {
              return Container();
            } else if (snapshot.hasError) {
              print(snapshot.error);
            } else
              return LinearProgressIndicator();
          },
        ));
  }
}

class AlertDialogWidget extends StatefulWidget {
  String username;

  AlertDialogWidget(this.username);
  @override
  _AlertDialogState createState() => _AlertDialogState(this.username);
}

class _AlertDialogState extends State<AlertDialogWidget> {
  String username;
  bool delete = false;
  bool block = false;
  _AlertDialogState(this.username);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(username),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
              value: delete,
              title: Text('Delete history'),
              subtitle: Text(
                  'Delete all messages for you and another user. The action cannot be undone.'),
              onChanged: (bool value) {
                setState(() {
                  delete = !delete;
                });
              }),
          CheckboxListTile(
              title: Text('Block this user'),
              subtitle: Text(
                  'You and the blocked user will not be able to text each other. The action can be canceled at any time.'),
              value: block,
              onChanged: (bool value) {
                setState(() {
                  block = !block;
                });
              })
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
            Navigator.of(context).pop();
          },
          child: Text('CONFIRM'),
        ),
      ],
    );
  }
}
