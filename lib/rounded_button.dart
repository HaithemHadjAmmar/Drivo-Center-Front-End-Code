import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class RoundedButton extends StatelessWidget {
  final String btnText;
  final Function onBtnPressed;

  const RoundedButton(
      {Key? key, required this.btnText, required this.onBtnPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      color: HexColor('4159A2'),
      borderRadius: BorderRadius.circular(15),
      child: MaterialButton(
        onPressed: () {
          onBtnPressed();
        },
        minWidth: 230,
        height: 60,
        child: Text(
          btnText,
          style: const TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
        ),
      ),
    );
  }
}
