import 'package:flutter/material.dart';
import 'package:progressive_image/progressive_image.dart';

class Profile extends StatelessWidget {
  Profile({this.imageUrl, this.lastName, this.firstName});
  final imageUrl, firstName, lastName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 40.0),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.all(35.0),
                  child: Hero(
                    tag: 'circleAvatar',
                    child: ProgressiveImage(
                      placeholder: AssetImage('images/placeholder.gif'),
                      thumbnail: NetworkImage(imageUrl),
                      image: NetworkImage(imageUrl),
                      height: 200.0,
                      width: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(
                  '$firstName $lastName',
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
        ),
      ),
    );
  }
}
