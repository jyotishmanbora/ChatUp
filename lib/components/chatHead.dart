import 'package:flutter/material.dart';
import 'dart:math';
import 'package:chat_app/screens/ChatScreen.dart';
import 'dart:ui';

class ChatHead extends StatelessWidget {
  ChatHead(
      {this.imageURL,
      this.nameAdded,
      this.imageRadius,
      this.firstName,
      this.lastName,
      this.userUid,
      this.personUid});
  final imageURL, firstName, lastName;
  final bool nameAdded;
  final double imageRadius;
  final userUid, personUid;
  final List<int> colors = [
    0xffDDD78D,
    0xffCCC9E7,
    0xff74DACB,
    0xff5BC0EB,
    0xff7EBC89
  ];
  final random = Random();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userUid: userUid,
              personUid: personUid,
              imageUrl: imageURL,
              personFirstName: firstName,
              personLastName: lastName,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: [
            CircleAvatar(
              radius: imageRadius,
              backgroundColor: Color(colors[random.nextInt(colors.length)]),
              child: Text(
                '${firstName[0].toString().toUpperCase() + lastName[0].toString().toUpperCase()}',
                textDirection: TextDirection.ltr,
              ),
            ),
            (nameAdded)
                ? Container(
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(color: Color(0xff898989), width: 0.5),
                    )),
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    margin: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Text(
                      '$firstName $lastName',
                      textDirection: TextDirection.ltr,
                    ),
                    width: 210.0,
                  )
                : SizedBox(
                    width: 0.0,
                  ),
          ],
        ),
      ),
    );
  }
}
