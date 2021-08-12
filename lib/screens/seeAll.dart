import 'package:flutter/material.dart';
import 'package:chat_app/components/chatHead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SeeAll extends StatelessWidget {
  SeeAll({this.userUid});
  final userUid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UsersStream(
            userUid: userUid,
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
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('firstName')
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

        var users = snapshot.data.docs;
        List<ChatHead> usersList = [];

        for (var user in users) {
          Map<String, dynamic> data = user.data() as Map<String, dynamic>;
          if (data['uid'] != userUid) {
            String url = data['dpurl'];
            String firstName = data['firstName'];
            String lastName = data['lastName'];

            ChatHead person = ChatHead(
              userUid: userUid,
              personUid: data['uid'],
              imageURL: url,
              imageRadius: 30.0,
              nameAdded: true,
              firstName: firstName,
              lastName: lastName,
            );

            usersList.add(person);
          }
        }

        return Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(left: 10.0),
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
