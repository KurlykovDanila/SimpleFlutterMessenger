import 'package:dima_messager/model/model.dart';
import 'package:dima_messager/pages/app.dart';
import 'package:dima_messager/pages/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LoginPage extends StatefulWidget {
  BuildContext themeContext;

  LoginPage(this.themeContext);
  @override
  _LoginPageState createState() => _LoginPageState(this.themeContext);
}

class _LoginPageState extends State<LoginPage> {
  BuildContext themeContext;

  _LoginPageState(this.themeContext);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: Text('Account'),
              bottom: TabBar(
                tabs: [Tab(text: 'SIGN IN'), Tab(text: 'SIGN UP')],
              )),
          body: TabBarView(
            children: [
              SignInPage(this.themeContext),
              SignUpPage(this.themeContext)
            ],
          ),
        ));
  }
}

class SignUpPage extends StatefulWidget {
  BuildContext themeContext;

  SignUpPage(this.themeContext);
  @override
  _SignUpPageState createState() => _SignUpPageState(this.themeContext);
}

class _SignUpPageState extends State<SignUpPage> {
  BuildContext themeContext;

  _SignUpPageState(this.themeContext);

  bool signup = false;
  bool difpass = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

  Future<bool> register() async {
    var email = _emailController.text;
    var name = _nameController.text;
    var username = _usernameController.text;
    var password = _passwordController.text;
    return Model.api.register(email, name, username, password);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Builder(
        builder: (context) {
          if (signup) {
            return LinearProgressIndicator();
          }
          return Container(
            height: 4,
          );
        },
      ),
      Container(
        margin: EdgeInsets.symmetric(vertical: 30),
        child: Text(
          'Sign up',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: TextField(
              readOnly: signup,
              textAlign: TextAlign.center,
              controller: _emailController,
              maxLength: 30,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'email',
                prefixIcon: Icon(Icons.email),
              ))),
      Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: TextField(
            readOnly: signup,
            textAlign: TextAlign.center,
            controller: _usernameController,
            maxLength: 30,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                hintText: 'user name'),
          )),
      Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: TextField(
            readOnly: signup,
            textAlign: TextAlign.center,
            controller: _nameController,
            maxLength: 30,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.face),
                border: OutlineInputBorder(),
                hintText: 'name'),
          )),
      Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: TextField(
            readOnly: signup,
            textAlign: TextAlign.center,
            controller: _passwordController,
            maxLength: 50,
            obscureText: true,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                hintText: 'password'),
          )),
      Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: TextField(
            readOnly: signup,
            textAlign: TextAlign.center,
            controller: _repeatPasswordController,
            maxLength: 50,
            obscureText: true,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                hintText: 'repeat password'),
          )),
      Container(
        child: RaisedButton(
          onPressed: () {
            if (_passwordController.text == _repeatPasswordController.text) {
              register().then((value) {
                if (value) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TextingPage(themeContext)));
                }
              });
            } else {
              setState(() {
                difpass = true;
              });
            }
            setState(() {
              signup = !signup;
            });
          },
          child: Text(
            'SIGN UP',
            style: Theme.of(context).textTheme.button,
          ),
        ),
      ),
      Container(child: Builder(
        builder: (context) {
          if (difpass)
            return Text(
              'You entered different passwords',
              style: TextStyle(color: Colors.redAccent),
            );
          return Container();
        },
      ))
    ]));
  }
}

class SignInPage extends StatefulWidget {
  BuildContext themeContext;
  SignInPage(this.themeContext);

  @override
  _SignInPageState createState() => _SignInPageState(this.themeContext);
}

class _SignInPageState extends State<SignInPage> {
  BuildContext themeContext;

  _SignInPageState(this.themeContext);

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool login = false;
  bool valid = true;

  Future<bool> signin() async {
    return Model.api.login(_loginController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            if (login) {
              return LinearProgressIndicator();
            }
            return Container(
              height: 4,
            );
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 30),
          child: Text(
            'Sign in',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: TextField(
              readOnly: login,
              textAlign: TextAlign.center,
              controller: _loginController,
              maxLength: 30,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  hintText: 'email'),
            )),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: TextField(
              readOnly: login,
              textAlign: TextAlign.center,
              controller: _passwordController,
              maxLength: 50,
              obscureText: true,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  hintText: 'password'),
            )),
        Container(
          child: RaisedButton(
            onPressed: () {
              setState(() {
                login = !login;
                signin().then((value) {
                  login = false;
                  valid = value;
                  if (value)
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TextingPage(themeContext)));
                });
              });
            },
            child: Text(
              'SIGN IN',
              style: Theme.of(context).textTheme.button,
            ),
          ),
        ),
        Builder(builder: (context) {
          if (login) {
            return Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Wait for a response from the server',
                  style: TextStyle(color: Colors.redAccent),
                ));
          }
          return Container();
        }),
        Builder(builder: (context) {
          if (!valid) {
            return Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'You entered incorrect account details',
                  style: TextStyle(color: Colors.redAccent),
                ));
          }
          return Container();
        }),
      ],
    ));
  }
}
