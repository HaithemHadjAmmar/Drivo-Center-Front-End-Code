import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AlertPage extends StatelessWidget {
  final String title;
  final String message;

  const AlertPage({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title:  Text(
          'Notifactions',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: HexColor('4159A2')
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),color: HexColor('4159A2'),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert page
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

void showAlertDialog(BuildContext context, {required String title, required String message}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the alert dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
