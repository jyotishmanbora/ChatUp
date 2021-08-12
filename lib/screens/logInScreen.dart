import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/components/AuthButton.dart';
import 'ChatHome.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email, password;
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  final foldingCube = SpinKitFoldingCube(
    color: Color(0xffF08943),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: foldingCube,
        child: Column(
          children: [
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Hero(
                  tag: 'logo',
                  child: Image(
                    image: AssetImage('images/chat logo.png'),
                    height: 150.0,
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   height: 30.0,
            // ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: textFieldDecoration.copyWith(
                        helperText: '',
                      ),
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      obscureText: true,
                      decoration: textFieldDecoration.copyWith(
                          hintText: 'Enter Password',
                          helperText: '',
                          icon: Icon(
                            Icons.lock,
                            size: 30.0,
                          )),
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80.0),
                    child: AuthButton(
                      onPress: () async {
                        setState(() {
                          showSpinner = true;
                        });

                        try {
                          UserCredential currentUser =
                              await _auth.signInWithEmailAndPassword(
                                  email: email, password: password);

                          if (currentUser != null) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatHome(
                                    userUid: currentUser.user.uid,
                                  ),
                                ),
                                (Route<dynamic> route) => false);
                          }

                          setState(() {
                            showSpinner = false;
                          });
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            setState(() {
                              showSpinner = false;
                            });
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Some error occurred'),
                                content:
                                    const Text('No user found for that email'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else if (e.code == 'wrong-password') {
                            setState(() {
                              showSpinner = false;
                            });
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Some error occurred'),
                                content: const Text(
                                    'Wrong password provided for that user'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      text: 'Log In',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
