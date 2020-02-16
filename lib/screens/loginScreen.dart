import 'dart:convert' show json;
import 'dart:io';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:filcnaplo/Datas/Account.dart';
import 'package:filcnaplo/Datas/Institution.dart';
import 'package:filcnaplo/Datas/User.dart';

import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/Helpers/UserInfoHelper.dart';

import 'package:filcnaplo/Utils/AccountManager.dart';

import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/Utils/StringFormatter.dart';

LoginScreenState loginScreenState = new LoginScreenState();

class LoginScreen extends StatefulWidget {
  LoginScreen({this.fromApp});

  bool fromApp = false;

  @override
  LoginScreenState createState() => LoginScreenState();
}

Icon helpIconSwitch = new Icon(
  Icons.help,
  color: Colors.white12,
);
bool helpSwitch = false;

void helpToggle() {
  helpSwitch = !helpSwitch;
  if (helpSwitch) {
    helpIconSwitch = new Icon(
      Icons.help,
      color: Colors.white,
    );
  } else {
    helpIconSwitch = new Icon(
      Icons.help,
      color: Colors.white12,
    );
  }
}

void showToggle() {
  showSwitch = !showSwitch;
  if (showSwitch) {
    showIconSwitch = new Icon(
      Icons.remove_red_eye,
      color: Colors.white,
    );
  } else {
    showIconSwitch = new Icon(
      Icons.remove_red_eye,
      color: Colors.white12,
    );
  }
}

Icon showIconSwitch = new Icon(
  Icons.remove_red_eye,
  color: Colors.white12,
);
bool showSwitch = false;

String userName = "";
String password = "";

String userError;
String passwordError;
bool schoolSelected = true;

double kbSize;

bool isDialog = false;

bool loggingIn = false;

final userNameController = new TextEditingController();
final passwordController = new TextEditingController();

class LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    loggingIn = false;
    super.initState();
  }

  void initJson() async {
    String data = await RequestHelper().getInstitutes();
    try {
      globals.jsonres = json.decode(data);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: "Nem sikerült lekérni a Krétás iskolákat.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      globals.jsonres = json.decode(data);
    }

    globals.jsonres.sort((dynamic a, dynamic b) {
      return a["Name"].toString().compareTo(b["Name"].toString());
    });

    globals.searchres = json.decode(data);

    globals.searchres.sort((dynamic a, dynamic b) {
      return a["Name"].toString().compareTo(b["Name"].toString());
    });

    if (isDialog) {
      myDialogState.setState(() {});
    }
  }

  void login(BuildContext context) async {
    userError = null;
    passwordError = null;

    try {
      final result = await InternetAddress.lookup('e-kreta.hu');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        password = passwordController.text;
        userName = userNameController.text;
        userError = null;
        passwordError = null;
        schoolSelected = true;
        String bearerResp;
        String code;
        if (userName == "") {
<<<<<<< Updated upstream
          userError = I18n.of(context).loginUsernameError;
=======
          userError = .choose_username;
>>>>>>> Stashed changes
          setState(() {
            loggingIn = false;
          });
        } else if (password == "") {
          setState(() {
            loggingIn = false;
          });
<<<<<<< Updated upstream
          passwordError = I18n.of(context).loginPasswordError;
=======
          passwordError = .choose_password;
>>>>>>> Stashed changes
        } else if (globals.selectedSchoolUrl == "") {
          setState(() {
            loggingIn = false;
          });
          schoolSelected = false;
        } else {
          String instCode = globals.selectedSchoolCode; //suli kódja
          String jsonBody = "institute_code=" +
              instCode +
              "&userName=" +
              userName +
              "&password=" +
              password +
              "&grant_type=password&client_id=" +
              globals.clientId;

          try {
            bearerResp =
                await RequestHelper().getBearer(jsonBody, instCode, false);
            Map<String, dynamic> bearerMap = json.decode(bearerResp);
            code = bearerMap.values.toList()[0];

            Map<String, String> userInfo = await UserInfoHelper()
                .getInfo(instCode, userName, password, false);

            setState(() {
              User user = new User(
                  int.parse(userInfo["StudentId"]),
                  userName,
                  password,
                  userInfo["StudentName"],
                  instCode,
                  globals.selectedSchoolUrl,
                  globals.selectedSchoolName,
                  userInfo["ParentName"],
                  userInfo["ParentId"]);
              AccountManager().addUser(user);

              globals.users.add(user);

              globals.multiAccount = globals.users.length != 1;

              globals.accounts = List();
              for (User user in globals.users)
                globals.accounts.add(Account(user));
              globals.selectedAccount = globals.accounts
                  .firstWhere((Account account) => account.user.id == user.id);
              globals.selectedUser = user;

              Navigator.pushNamed(context, "/main");
            });
          } catch (e) {
            setState(() {
              loggingIn = false;
            });
            print(e);
            setState(() {
              if (code == "invalid_grant") {
                passwordError = "hibás felasználónév vagy jelszó";
              } else if (code == "invalid_password") {
                passwordError = "hibás felasználónév vagy jelszó";
              } else {
                passwordError = "ismeretlen (valószínűleg KRÉTÁS) probléma: " +
                    code.toString();
              }
            });
          }
        }
      } else {
        setState(() {
          loggingIn = false;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        loggingIn = false;
      });
      passwordError = "nincs internet";
    }
  }

  void showSelectDialog() {
    initJson();
    setState(() {
      myDialogState = new MyDialogState();
      showDialog<Institution>(
          context: context,
          builder: (BuildContext context) {
            return new MyDialog();
          }).then((dynamic) {
        setState(() {});
      });
    });
  }

  _gotoAbout() {
    Navigator.popAndPushNamed(context, "/about");
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () {
          if (widget.fromApp)
            Navigator.pushReplacementNamed(context, "/accounts");
        },
        child: Scaffold(
            body: new Container(
                color: Colors.black87,
                child: new Center(
                    child: !loggingIn
                        ? new Container(
                            child: new ListView(
                            reverse: true,
                            padding:
                                EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
                            children: <Widget>[
                              new Container(
                                padding: new EdgeInsets.only(
                                    left: 40.0, right: 40.0),
                                child: Image.asset("assets/icon.png"),
                                height: kbSize,
                              ),
                              new Container(
                                  margin: EdgeInsets.only(top: 5.0),
                                  child: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Flexible(
                                          child: new TextFormField(
                                            style:
                                                TextStyle(color: Colors.white),
                                            controller: userNameController,
                                            decoration: InputDecoration(
                                              prefixIcon:
                                                  new Icon(Icons.person),
<<<<<<< Updated upstream
                                              hintText: I18n.of(context).loginUsername,
=======
                                              hintText: .username,
>>>>>>> Stashed changes
                                              hintStyle: TextStyle(
                                                  color: Colors.white30),
                                              errorText: userError,
                                              fillColor: Color.fromARGB(
                                                  40, 20, 20, 30),
                                              filled: true,
                                              helperText: helpSwitch
<<<<<<< Updated upstream
                                                  ? I18n.of(context).loginUsernameHint
=======
                                                  ? .username_hint
>>>>>>> Stashed changes
                                                  : null,
                                              helperStyle: TextStyle(
                                                  color: Colors.white30),
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      5.0, 15.0, 5.0, 15.0),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  gapPadding: 1.0,
                                                  borderSide: BorderSide(
                                                    color: Colors.green,
                                                    width: 2.0,
                                                  )),
                                            ),
                                          ),
                                        ),
                                        new IconButton(
                                            icon: helpIconSwitch,
                                            onPressed: () {
                                              setState(() {
                                                helpToggle();
                                              });
                                            })
                                      ])),
                              new Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: new Row(children: <Widget>[
                                    new Flexible(
                                      child: new TextFormField(
                                        style: TextStyle(color: Colors.white),
                                        controller: passwordController,
                                        keyboardType: TextInputType.text,
                                        obscureText: !showSwitch,
                                        decoration: InputDecoration(
                                          prefixIcon: new Icon(Icons.https),
                                          hintStyle:
                                              TextStyle(color: Colors.white30),
<<<<<<< Updated upstream
                                          hintText: I18n.of(context).loginPassword,
=======
                                          hintText: .password,
>>>>>>> Stashed changes
                                          errorText: passwordError,
                                          fillColor:
                                              Color.fromARGB(40, 20, 20, 30),
                                          filled: true,
                                          helperText: helpSwitch
<<<<<<< Updated upstream
                                              ? I18n.of(context).loginPasswordHint
=======
                                              ? .password_hint
>>>>>>> Stashed changes
                                              : null,
                                          helperStyle:
                                              TextStyle(color: Colors.white30),
                                          contentPadding: EdgeInsets.fromLTRB(
                                              5.0, 15.0, 5.0, 15.0),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              gapPadding: 1.0,
                                              borderSide: BorderSide(
                                                color: Colors.deepOrange,
                                                width: 2.0,
                                              )),
                                        ),
                                      ),
                                    ),
                                    new IconButton(
                                        icon: showIconSwitch,
                                        onPressed: () {
                                          setState(() {
                                            showToggle();
                                          });
                                        }),
                                  ])),
                              new Column(children: <Widget>[
                                new Container(
                                  margin: new EdgeInsets.fromLTRB(
                                      0.0, 10.0, 0.0, 5.0),
                                  padding: new EdgeInsets.fromLTRB(
                                      10.0, 4.0, 10.0, 4.0),
                                  decoration: new BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Color.fromARGB(40, 20, 20, 30),
                                    border: new Border.all(
                                      color: schoolSelected
                                          ? Colors.black87
                                          : Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: new Row(
                                    children: <Widget>[
                                      new Text(
<<<<<<< Updated upstream
                                        I18n.of(context).loginSchool + ": ",
=======
                                        .school,
>>>>>>> Stashed changes
                                        style: new TextStyle(
                                            fontSize: 21.0,
                                            color: Colors.white30),
                                      ),
                                      new Expanded(
                                        child: new FlatButton(
                                          onPressed: () {
                                            showSelectDialog();
                                            setState(() {});
                                          },
                                          child: new Text(
                                            globals.selectedSchoolName ??
<<<<<<< Updated upstream
                                                I18n.of(context).loginChoose,
=======
                                                .choose,
>>>>>>> Stashed changes
                                            style: new TextStyle(
                                                fontSize: 21.0,
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                !schoolSelected
                                    ? new Text(
<<<<<<< Updated upstream
                                        I18n.of(context).loginSchoolError,
=======
                                        .choose_school_warning,
>>>>>>> Stashed changes
                                        style: new TextStyle(color: Colors.red),
                                      )
                                    : new Container(),
                              ]),
                              new Row(
                                children: <Widget>[
                                  !Platform.isIOS
                                      ? Expanded(
                                          child: new Container(
                                          child: FlatButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, "/import");
                                            },
                                            child: new Text("Import"),
                                            disabledColor: Colors.blueGrey[800],
                                            disabledTextColor: Colors.blueGrey,
                                            color: Colors.green,
                                            //#2196F3
                                            textColor: Colors.white,
                                          ),
                                          padding: EdgeInsets.only(right: 12),
                                        ))
                                      : Container(),
                                ],
                              ),
                              new FlatButton(
                                onPressed: !loggingIn
                                    ? () {
                                        setState(() {
                                          loggingIn = true;
                                          login(context);
                                        });
                                      }
                                    : null,
                                disabledColor: Colors.blueGrey.shade800,
                                disabledTextColor: Colors.blueGrey,
<<<<<<< Updated upstream
                                child: new Text(capitalize(I18n.of(context).login)),
=======
                                child: new Text(.login),
>>>>>>> Stashed changes
                                color: Colors.blue,
                                //#2196F3
                                textColor: Colors.white,
                              ),
                            ].reversed.toList(),
                          ))
                        : new Container(
                            child: new CircularProgressIndicator(),
                          )))));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog();
  @override
  State createState() {
    if (globals.jsonres != null) globals.searchres.addAll(globals.jsonres);
    return myDialogState;
  }
}

MyDialogState myDialogState = new MyDialogState();

class MyDialogState extends State<MyDialog> {
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    isDialog = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isDialog = true;
  }

  Widget build(BuildContext context) {
    return new SimpleDialog(
<<<<<<< Updated upstream
      title: new Text(I18n.of(context).loginChooseSchool + ":"),
=======
      title: new Text(.choose_school),
>>>>>>> Stashed changes
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        new Container(
          child: new TextField(
              maxLines: 1,
              autofocus: true,
              onChanged: (String search) {
                setState(() {
                  updateSearch(search);
                });
              }),
          margin: new EdgeInsets.all(10.0),
        ),
        new Container(
          child: globals.searchres != null
              ? new ListView.builder(
                  itemBuilder: _itemBuilder,
                  itemCount: globals.searchres.length,
                )
              : new Container(),
          width: 320.0,
          height: 400.0,
        )
      ],
    );
  }

  void updateSearch(String searchText) {
    setState(() {
      globals.searchres.clear();
      globals.searchres.addAll(globals.jsonres);
    });
    if (searchText != "") {
      setState(() {
        globals.searchres.removeWhere((dynamic element) => !element
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase()));
      });
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return new Column(
      children: <Widget>[
        ListTile(
          title: new Text(globals.searchres[index]["Name"]),
          subtitle: new Text(globals.searchres[index]["Url"]),
          onTap: () {
            setState(() {
              globals.selectedSchoolCode =
                  globals.searchres[index]["InstituteCode"];
              globals.selectedSchoolUrl = globals.searchres[index]["Url"];
              globals.selectedSchoolName = globals.searchres[index]["Name"];
              Navigator.pop(context);
            });
          },
        ),
        new Container(
          child: new Text(globals.searchres[index]["City"]),
          alignment: new Alignment(1.0, 0.0),
        )
      ],
    );
  }
}
