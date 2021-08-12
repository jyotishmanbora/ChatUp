import 'package:flutter/material.dart';

const textFieldDecoration = InputDecoration(
  hintText: 'Enter Email id',
  helperText: 'valid e-mail address',
  icon: Icon(
    Icons.email,
    size: 30.0,
  ),
  contentPadding: EdgeInsets.symmetric(
    horizontal: 20.0,
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
//color: Color(0xffb3b3b3),
        ),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
// enabledBorder: OutlineInputBorder(
//   borderSide: BorderSide(
//     color: Color(0xffF08943),
//   ),
//   borderRadius: BorderRadius.all(Radius.circular(32.0)),
// ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xffF08943),
    ),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

String userToken;
// String currentPersonUid;
