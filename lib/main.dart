import 'package:chat_app/screens/AddPhoto.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/welcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/ChatHome.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:chat_app/screens/fullName.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:chat_app/screens/ChatScreen.dart';
// import 'constants.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

var firestore = FirebaseFirestore.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class MyApp extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MyApp> {
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyApp()));
      }
    });

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;
    //   if (notification != null &&
    //       android != null &&
    //       message.data['personUid'] != currentPersonUid) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             channel.description,
    //             // TODO add a proper drawable resource to android, for now using
    //             //      one that already exists in example app.
    //           ),
    //         ));
    //   }
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupInteractedMessage();
  }

  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  Future getUser() async {
    var user = await FirebaseAuth.instance.currentUser;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print('error');
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder(
            future: getUser(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              var loggedInUser = snapshot.data;
              if (!snapshot.hasData) {
                return MaterialApp(
                  title: 'Flutter Demo',
                  theme: ThemeData.dark().copyWith(
                    primaryColor: Color(0xFF0A0E21),
                    scaffoldBackgroundColor: Color(0xFF0A0E21),
                  ),
                  home: Welcome(),
                );
              } else {
                return MaterialApp(
                  title: 'Flutter Demo',
                  theme: ThemeData.dark().copyWith(
                    primaryColor: Color(0xFF0A0E21),
                    scaffoldBackgroundColor: Color(0xFF0A0E21),
                  ),
                  home: StreamBuilder(
                    stream: firestore.collection('users').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
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

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SpinKitThreeBounce(
                          color: Colors.white,
                          size: 20.0,
                        );
                      }

                      var users = snapshot.data.docs;

                      for (var user in users) {
                        Map<String, dynamic> data =
                            user.data() as Map<String, dynamic>;
                        if (data['uid'] == loggedInUser.uid) {
                          if (data['dpurl'] == null) {
                            return AddPhoto();
                          } else {
                            return ChatHome(
                              userUid: loggedInUser.uid,
                            );
                          }
                        }
                      }

                      return FullName();
                    },
                  ),
                );
              }
            },
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          theme: ThemeData.dark().copyWith(
            primaryColor: Color(0xFF0A0E21),
            scaffoldBackgroundColor: Color(0xFF0A0E21),
          ),
          home: Scaffold(
            body: Center(
              child: Hero(
                tag: 'logo',
                child: Image(
                  image: AssetImage('images/chat logo.png'),
                  height: 200.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
