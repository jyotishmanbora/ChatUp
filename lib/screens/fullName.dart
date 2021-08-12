import 'package:flutter/material.dart';
import 'package:chat_app/components/AuthButton.dart';
import 'package:chat_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:chat_app/screens/AddPhoto.dart';

class FullName extends StatefulWidget {
  @override
  _FullNameState createState() => _FullNameState();
}

class _FullNameState extends State<FullName> {
  String uid;
  String firstName = '', lastName = '';
  bool showSpinner = false;
  final foldingCube = SpinKitFoldingCube(
    color: Color(0xffF08943),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Full Name'),
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
                      decoration: textFieldDecoration.copyWith(
                          hintText: 'First Name',
                          helperText: 'enter your first name',
                          icon: Icon(
                            Icons.account_circle,
                            size: 30.0,
                          )),
                      onChanged: (value) {
                        firstName = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      decoration: textFieldDecoration.copyWith(
                          hintText: 'Last Name',
                          helperText: 'enter your last name',
                          icon: Icon(
                            Icons.account_circle,
                            size: 30.0,
                          )),
                      onChanged: (value) {
                        lastName = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80.0),
                    child: AuthButton(
                      text: 'Next',
                      onPress: () async {
                        setState(() {
                          showSpinner = true;
                        });

                        if (firstName == '' && lastName == '') {
                          setState(() {
                            showSpinner = false;
                          });

                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Some error occurred'),
                              content: const Text('Name cannot be empty'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          try {
                            var user = await FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc('${user.uid}')
                                  .set({
                                'firstName': firstName,
                                'lastName': lastName,
                                'uid': '${user.uid}'
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPhoto(),
                                ),
                              );

                              setState(() {
                                showSpinner = false;
                              });
                            } else {
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
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
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
