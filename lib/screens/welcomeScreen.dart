import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'registrationScreen.dart';
import 'logInScreen.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/chatbg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 40.0,
                        horizontal: 60.0,
                      ),
                      child: Hero(
                        tag: 'logo',
                        child: Image(
                          image: AssetImage('images/chat logo.png'),
                        ),
                      ),
                    ),
                    Text(
                      'ChatUp',
                      style: TextStyle(
                        fontSize: 50.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('A chat application made for learning purpose'),
                    WelcomeButton(
                      text: 'Register',
                      color: Color(0xff4383FF),
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationScreen(),
                          ),
                        );
                      },
                    ),
                    WelcomeButton(
                      text: 'Log In',
                      color: Color(0xff9042F3),
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeButton extends StatelessWidget {
  WelcomeButton({this.text, this.color, this.onPress});

  final String text;
  final Color color;
  final Function onPress;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(1.0, 1.0),
              blurRadius: 3.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        width: 150.0,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 25.0,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}
