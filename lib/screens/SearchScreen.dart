import 'package:flutter/material.dart';
import 'package:chat_app/components/chatHead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchResults extends StatefulWidget {
  SearchResults({this.userUid});
  final userUid;
  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  String searchedTerm = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  fillColor: Color(0xff29304F),
                  icon: Hero(
                    tag: 'search',
                    child: Icon(Icons.search),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchedTerm = value;
                  });
                },
              ),
            ),
            UsersStream(
              userUid: widget.userUid,
              searchedTerm: searchedTerm,
            ),
          ],
        ),
      ),
    );
  }
}

class UsersStream extends StatelessWidget {
  UsersStream({this.userUid, this.searchedTerm});
  final String searchedTerm;
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
          if ('${data['firstName']} ${data['lastName']}'
              .toLowerCase()
              .contains(searchedTerm.toLowerCase())) {
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
