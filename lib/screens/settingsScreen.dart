import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'fullName.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'welcomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progressive_image/progressive_image.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({this.imageUrl, this.firstName, this.lastName});
  final firstName, lastName;
  final imageUrl;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool showSpinner = false;
  final foldingCube = SpinKitFoldingCube(
    color: Color(0xffF08943),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: foldingCube,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xff29304F),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(35.0),
                    child: ProgressiveImage(
                      placeholder: AssetImage('images/placeholder.gif'),
                      thumbnail: NetworkImage(widget.imageUrl),
                      image: NetworkImage(widget.imageUrl),
                      height: 200.0,
                      width: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    '${widget.firstName} ${widget.lastName}',
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      color: Color(0xffF08943),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullName(),
                          ),
                        );
                      },
                    ),
                    Text(
                      'update info',
                      style: TextStyle(
                        color: Color(0xffF08943),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.logout),
                      color: Color(0xffF08943),
                      onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          var user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseAuth.instance.signOut();

                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Welcome(),
                                ),
                                (Route<dynamic> route) => false);

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
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    Text(
                      'logout',
                      style: TextStyle(
                        color: Color(0xffF08943),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
