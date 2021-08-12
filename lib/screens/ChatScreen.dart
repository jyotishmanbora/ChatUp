import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'profile.dart';
import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:chat_app/constants.dart';
// import 'package:chat_app/main.dart';

import 'package:http/http.dart' as http;

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     'This channel is used for important notifications.', // description
//     importance: Importance.high,
//     playSound: true);

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('A bg message just showed up :  ${message.messageId}');
// }
// import 'package:firebase_auth/firebase_auth.dart';

// var user;
final firestore = FirebaseFirestore.instance;
// FirebaseMessaging messaging = FirebaseMessaging.instance;
// final auth = FirebaseAuth.instance;
//
// void getUser() async {
//   try {
//     var loggedInUser = await FirebaseAuth.instance.currentUser;
//     if (loggedInUser != null) {
//       user = loggedInUser;
//     }
//   } catch (e) {
//     print(e);
//   }
// }

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {this.imageUrl,
      this.personFirstName,
      this.personLastName,
      this.personUid,
      this.userUid});
  final userUid;
  final imageUrl;
  final personFirstName, personLastName;
  final personUid;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Future<void> setupInteractedMessage() async {
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  //   await flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(channel);
  //
  //   await FirebaseMessaging.instance
  //       .setForegroundNotificationPresentationOptions(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  //   // Get any messages which caused the application to open from
  //   // a terminated state.
  //   RemoteMessage initialMessage =
  //       await FirebaseMessaging.instance.getInitialMessage();
  //
  //   // If the message also contains a data property with a "type" of "chat",
  //   // navigate to a chat screen
  //   if (initialMessage != null) {
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => MyApp()));
  //   }
  //
  //   // Also handle any interaction when the app is in the background via a
  //   // Stream listener
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     RemoteNotification notification = message.notification;
  //     AndroidNotification android = message.notification?.android;
  //     if (notification != null && android != null) {
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => MyApp()));
  //     }
  //   });
  //
  //   // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   //   RemoteNotification notification = message.notification;
  //   //   AndroidNotification android = message.notification?.android;
  //   //   if (notification != null &&
  //   //       android != null &&
  //   //       message.data['personUid'] != currentPersonUid) {
  //   //     flutterLocalNotificationsPlugin.show(
  //   //         notification.hashCode,
  //   //         notification.title,
  //   //         notification.body,
  //   //         NotificationDetails(
  //   //           android: AndroidNotificationDetails(
  //   //             channel.id,
  //   //             channel.name,
  //   //             channel.description,
  //   //             // TODO add a proper drawable resource to android, for now using
  //   //             //      one that already exists in example app.
  //   //           ),
  //   //         ));
  //   //   }
  //   // });
  // }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   // currentPersonUid = widget.personUid;
  //   super.initState();
  //   // setupInteractedMessage();
  // }

  final messageTextController = TextEditingController();
  String text = '';

  // @override
  // void initState() {
  //   getUser();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: Hero(
            tag: 'circleAvatar',
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl),
            ),
          ),
        ),
        title: Text('${widget.personFirstName} ${widget.personLastName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.face),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(
                    imageUrl: widget.imageUrl,
                    firstName: widget.personFirstName,
                    lastName: widget.personLastName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/chatbg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MessagesStream(
                personUid: widget.personUid,
                userUid: widget.userUid,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          text = value;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffffff),
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          fillColor: Color(0xff29304F),
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.lightBlue,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          if (text != '') {
                            messageTextController.clear();
                            firestore
                                .collection('messages')
                                .doc('${widget.userUid}')
                                .collection('messages')
                                .add({
                              'text': text,
                              'sender': widget.userUid,
                              'receiver': widget.personUid,
                              'timeStamp': DateTime.now(),
                              'time':
                                  '${DateTime.now().hour}:${DateTime.now().minute}'
                            });
                            firestore
                                .collection('messages')
                                .doc(widget.personUid)
                                .collection('messages')
                                .add({
                              'text': text,
                              'sender': widget.userUid,
                              'receiver': widget.personUid,
                              'timeStamp': DateTime.now(),
                              'time':
                                  '${DateTime.now().hour}:${DateTime.now().minute}'
                            });
                            text = '';

                            var personInfo = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.personUid)
                                .get()
                                .then((DocumentSnapshot documentSnapshot) {
                              if (documentSnapshot.exists) {
                                Map<String, dynamic> data = documentSnapshot
                                    .data() as Map<String, dynamic>;
                                return {
                                  'token': data['token'],
                                  'firstName': data['firstName'],
                                  'lastName': data['lastName'],
                                  'uid': data['uid'],
                                  'dpurl': data['dpurl']
                                };
                              } else {
                                return null;
                              }
                            });

                            var userInfo = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.userUid)
                                .get()
                                .then((DocumentSnapshot documentSnapshot) {
                              if (documentSnapshot.exists) {
                                Map<String, dynamic> data = documentSnapshot
                                    .data() as Map<String, dynamic>;
                                return {
                                  'token': data['token'],
                                  'firstName': data['firstName'],
                                  'lastName': data['lastName'],
                                  'uid': data['uid'],
                                  'dpurl': data['dpurl']
                                };
                              } else {
                                return null;
                              }
                            });

                            if (personInfo == null || userInfo == null) {
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
                            } else {
                              try {
                                await http.post(
                                  Uri.parse(
                                      'https://fcm.googleapis.com/fcm/send'),
                                  headers: <String, String>{
                                    'Content-Type':
                                        'application/json; charset=UTF-8',
                                    'Authorization':
                                        'key=add proper key',
                                  },
                                  body: jsonEncode({
                                    'to': personInfo['token'],
                                    'data': {
                                      'userUid': widget.personUid,
                                      'personUid': widget.userUid,
                                      'firstName': userInfo['firstName'],
                                      'lastName': userInfo['lastName'],
                                      'imageUrl': userInfo['dpurl']
                                    },
                                    'notification': {
                                      'title': 'New Message',
                                      'body':
                                          'New message from ${userInfo['firstName']} ${userInfo['lastName']}'
                                    }
                                  }),
                                );
                              } catch (e) {
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
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  MessagesStream({this.personUid, this.userUid});
  final personUid, userUid;

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
          return SpinKitThreeBounce(
            color: Colors.white,
            size: 20.0,
          );
        }

        var messages = snapshot.data.docs;
        List<MessageBubble> messagesList = [];

        for (var message in messages) {
          Map<String, dynamic> data = message.data() as Map<String, dynamic>;
          if (data['sender'] == userUid && data['receiver'] == personUid) {
            var messageBubble = MessageBubble(
              isMe: true,
              text: data['text'],
              time: data['time'],
            );
            messagesList.add(messageBubble);
          } else if (data['sender'] == personUid &&
              data['receiver'] == userUid) {
            var messageBubble = MessageBubble(
              isMe: false,
              text: data['text'],
              time: data['time'],
            );
            messagesList.add(messageBubble);
          }
        }

        return Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 3.0),
            reverse: true,
            itemBuilder: (context, index) {
              return messagesList[index];
            },
            itemCount: messagesList.length,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.isMe, this.time});
  final bool isMe;
  final text;
  final time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(2.0),
          child: Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topRight: Radius.circular(4.0),
                    topLeft: Radius.circular(25.0),
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0))
                : BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
            elevation: 3.0,
            color: isMe ? Color(0xffF08943) : Color(0xff9042F3),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xabffffff),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
