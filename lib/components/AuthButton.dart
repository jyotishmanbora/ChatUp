import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  AuthButton({this.text, this.onPress});
  final Function onPress;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20.0,
              color: Color(0xffffffff),
            ),
          ),
        ),
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Color(0xffF08943),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
    );
  }
}
