import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:chat_app/constants.dart';
import 'fullName.dart';
import 'package:chat_app/components/AuthButton.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _registrationScreenState createState() => _registrationScreenState();
}

class _registrationScreenState extends State<RegistrationScreen> {
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
        title: Text('Register'),
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
                      decoration: textFieldDecoration,
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
                          hintText: 'Create Password',
                          helperText: 'must contain minimum 6 characters',
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
                          UserCredential newUser =
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);

                          if (newUser != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullName(),
                              ),
                            );
                          }

                          setState(() {
                            showSpinner = false;
                          });
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            setState(() {
                              showSpinner = false;
                            });
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Some error occurred'),
                                content: const Text(
                                    'The password provided is too weak.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else if (e.code == 'email-already-in-use') {
                            setState(() {
                              showSpinner = false;
                            });
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Some error occurred'),
                                content: const Text(
                                    'The account already exists for that email.'),
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
                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          setState(() {
                            showSpinner = false;
                          });
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Some error occurred'),
                              content: const Text('Please try again'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      text: 'Register',
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
