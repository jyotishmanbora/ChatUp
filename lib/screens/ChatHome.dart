import 'package:chat_app/screens/seeAll.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/components/chatHead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SearchScreen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'settingsScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/constants.dart';
import 'dart:ui';

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser.uid;

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'token': token,
  });
}

Future<void> saveToken() async {
  userToken = await FirebaseMessaging.instance.getToken();

  // Save the initial token to the database
  await saveTokenToDatabase(userToken);

  // Any time the token refreshes, store this in the database too.
  FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
}

final firestore = FirebaseFirestore.instance;

class ChatHome extends StatefulWidget {
  ChatHome({@required this.userUid});
  final userUid;
  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  @override
  void initState() {
    // TODO: implement initState
    // currentPersonUid = 'notAnId';
    super.initState();
    saveToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatUp'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResults(
                    userUid: widget.userUid,
                  ),
                ),
              );
            },
            icon: Hero(
              tag: 'search',
              child: Icon(Icons.search),
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('users')
                  .get()
                  .then((QuerySnapshot querySnapshot) {
                querySnapshot.docs.forEach((doc) {
                  if (doc['uid'] == widget.userUid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          imageUrl: doc['dpurl'],
                          firstName: doc['firstName'],
                          lastName: doc['lastName'],
                        ),
                      ),
                    );
                  }
                });
              });
            },
          ),
        ],
      ),
      backgroundColor: Color(0xffF08943),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              textDirection: TextDirection.ltr,
              children: [
                Text(
                  'see all',
                  textDirection: TextDirection.ltr,
                ),
                IconButton(
                  padding: EdgeInsets.only(right: 10.0),
                  icon: Icon(Icons.read_more),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeeAll(
                          userUid: widget.userUid,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          UsersStream(
            userUid: widget.userUid,
          ),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
            flex: 18,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: Color(0xFF0A0E21),
              ),
              child: Column(
                children: [
                  Conversations(
                    userUid: widget.userUid,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UsersStream extends StatelessWidget {
  UsersStream({this.userUid});
  final userUid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('users').orderBy('firstName').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
            child: SpinKitThreeBounce(
              color: Colors.white,
              size: 20.0,
            ),
          );
        }

        var users = snapshot.data.docs;
        List<ChatHead> usersList = [];

        for (var user in users) {
          Map<String, dynamic> data = user.data() as Map<String, dynamic>;
          if (data['uid'] != userUid) {
            String url = data['dpurl'];

            ChatHead person = ChatHead(
              userUid: userUid,
              personUid: data['uid'],
              imageURL: url,
              imageRadius: 35.0,
              nameAdded: false,
              lastName: data['lastName'],
              firstName: data['firstName'],
            );

            usersList.add(person);
          }
        }

        return Expanded(
          flex: 3,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 5.0),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return usersList[index];
            },
            itemCount: usersList.length,
          ),
        );
      },
    );
  }
}

class Conversations extends StatelessWidget {
  Conversations({this.userUid});
  final userUid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('messages')
            .doc(userUid)
            .collection('messages')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Expanded(
              child: SpinKitThreeBounce(
                color: Colors.white,
                size: 20.0,
              ),
            );
          }

          var messages = snapshot.data.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('users').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Expanded(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 20.0,
                  ),
                );
              }

              var users = snapshot.data.docs;
              List<ChatHead> conversationList = [];
              List visitedConvos = [];

              for (var message in messages) {
                for (var user in users) {
                  Map<String, dynamic> messageData =
                      message.data() as Map<String, dynamic>;
                  Map<String, dynamic> userData =
                      user.data() as Map<String, dynamic>;
                  if ((messageData['sender'] == userData['uid'] ||
                          messageData['receiver'] == userData['uid']) &&
                      userData['uid'] != userUid &&
                      !(visitedConvos.contains(userData['uid']))) {
                    visitedConvos.add(userData['uid']);

                    ChatHead person = ChatHead(
                      userUid: userUid,
                      personUid: userData['uid'],
                      imageURL: userData['dpurl'],
                      imageRadius: 30.0,
                      nameAdded: true,
                      firstName: userData['firstName'],
                      lastName: userData['lastName'],
                    );

                    conversationList.add(person);
                  }
                }
              }

              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 10.0, top: 10.0),
                  itemBuilder: (context, index) {
                    return conversationList[index];
                  },
                  itemCount: conversationList.length,
                ),
              );
            },
          );
        });
  }
}
