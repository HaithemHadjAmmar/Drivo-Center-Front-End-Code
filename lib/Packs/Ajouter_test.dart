import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Ajouter_Test extends StatefulWidget {
  const Ajouter_Test({Key? key}) : super(key: key);

  @override
  State<Ajouter_Test> createState() => _Ajouter_TestState();
}

class _Ajouter_TestState extends State<Ajouter_Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Test', style: TextStyle(fontFamily: 'Roboto'),),
        centerTitle: true,
        backgroundColor: HexColor('4159A2'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
