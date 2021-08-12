import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:chat_app/components/AuthButton.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ChatHome.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progressive_image/progressive_image.dart';

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('images/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

var loggedInUser;
void getUser() async {
  try {
    var user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  } catch (e) {
    print(e);
  }
}

class AddPhoto extends StatefulWidget {
  @override
  _AddPhotoState createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  double maleIconWidth = 2.0;
  double femaleIconWidth = 0.0;
  String imageURL;
  String backupImageURL = 'male.png';
  bool showSpinner = false;
  final foldingCube = SpinKitFoldingCube(
    color: Color(0xffF08943),
  );

  @override
  void initState() {
    // TODO: implement initState
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add profile picture'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: foldingCube,
        child: Column(
          children: [
            Flexible(
              child: Center(
                child: (imageURL == null)
                    ? CircleAvatar(
                        backgroundImage: AssetImage('images/$backupImageURL'),
                        radius: 120.00,
                      )
                    : ProgressiveImage(
                        placeholder: AssetImage('images/placeholder.gif'),
                        thumbnail: NetworkImage(imageURL),
                        image: NetworkImage(imageURL),
                        height: 200.0,
                        width: 200.0,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 3.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: maleIconWidth,
                        color: Color(0xffF08943),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.mars),
                        onPressed: () {
                          setState(() {
                            maleIconWidth = 2.0;
                            femaleIconWidth = 0.0;
                            backupImageURL = 'male.png';
                          });
                        },
                      ),
                      Text('male'),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 3.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: femaleIconWidth,
                        color: Color(0xffF08943),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.venus),
                        onPressed: () {
                          setState(() {
                            maleIconWidth = 0.0;
                            femaleIconWidth = 2.0;
                            backupImageURL = 'female.png';
                          });
                        },
                      ),
                      Text('female'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () async {
                        final _picker = ImagePicker();
                        PickedFile image;

                        //Check Permissions
                        var permissionStatus =
                            await Permission.photos.request();
                        // = await Permission.photos.status;

                        if (permissionStatus.isGranted) {
                          //Select Image
                          image = await _picker.getImage(
                            source: ImageSource.gallery,
                            imageQuality: 70,
                          );
                          var file = File(image.path);

                          if (image != null) {
                            setState(() {
                              showSpinner = true;
                            });
                            try {
                              if (loggedInUser != null) {
                                var snapshot = await storage
                                    .ref()
                                    .child('ProfilePics/${loggedInUser.uid}')
                                    .putFile(file);

                                var downloadUrl =
                                    await snapshot.ref.getDownloadURL();

                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc('${loggedInUser.uid}')
                                    .update({
                                  'dpurl': downloadUrl
                                }).catchError((error) => showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Some error occurred'),
                                            content:
                                                const Text('Please try again'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'OK'),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        ));

                                setState(() {
                                  imageURL = downloadUrl;
                                });

                                setState(() {
                                  showSpinner = false;
                                });
                              } else {
                                setState(() {
                                  showSpinner = false;
                                });
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
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
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    Text('add photo'),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Text(
                'You can skip adding profile picture',
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 70.0),
              child: AuthButton(
                text: 'Next',
                onPress: () async {
                  setState(() {
                    showSpinner = true;
                  });

                  if (imageURL == null) {
                    File image = await getImageFileFromAssets(backupImageURL);
                    var file = File(image.path);
                    try {
                      if (loggedInUser != null) {
                        var snapshot = await storage
                            .ref()
                            .child('ProfilePics/${loggedInUser.uid}')
                            .putFile(file);

                        var downloadUrl = await snapshot.ref.getDownloadURL();

                        FirebaseFirestore.instance
                            .collection('users')
                            .doc('${loggedInUser.uid}')
                            .update({'dpurl': downloadUrl}).catchError(
                                (error) =>
                                    print("Failed to update user: $error"));

                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => ChatHome(
                                      userUid: loggedInUser.uid,
                                    )),
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
                                onPressed: () => Navigator.pop(context, 'OK'),
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
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => ChatHome(
                                  userUid: loggedInUser.uid,
                                )),
                        (Route<dynamic> route) => false);
                    setState(() {
                      showSpinner = false;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
