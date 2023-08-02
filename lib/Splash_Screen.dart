
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'Screens/login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('4159A2'), // set the background color with transparency
      body: Column(
        children: [
          Expanded(
            flex: 2, // make the image take 2/3 of the available height
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.scaleDown, // scale the image to fit within the container
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1, // make the remaining space take 1/3 of the available height
            child: Container(
              color: Colors.transparent, // make the background color transparent
             /* child: Center(
                child: Text(
                  'Your content here',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
              ),*/
            ),
          ),
        ],
      ),
    );
  }

}