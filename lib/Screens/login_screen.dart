import 'dart:convert';

import 'package:auto_ecole/Packs/Succed_Page.dart';
import 'package:auto_ecole/Screens/register_Screen.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Services/auth_services.dart';
import '../Services/globals.dart';
import '../rounded_button.dart';
import 'home_Screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  String _email = '';
  String _password = '';

  loginPressed() async {
    if (_email.isNotEmpty && _password.isNotEmpty) {
      http.Response response = await AuthServices.login(_email, _password);
      Map responseMap = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final storage = FlutterSecureStorage();
        String token = responseMap['token'];
        int userId = responseMap['user_id'];

        await storage.write(key: 'token', value: token);
        await storage.write(key: 'user_id', value: userId.toString());

        // stockage lel id w token fi 2 variables
        User user = User(id: userId, token: token);
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ListPacks(),
          ),
        );
      } else {
        errorSnackBar(context, responseMap.values.first);
      }
    } else {
      errorSnackBar(context, 'Entrer tous les champs obligatoires');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Container(
    height: 200,
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage('assets/images/drivo.jpg'),
    fit: BoxFit.scaleDown,
    ),
    ),
    ),
SizedBox(
  height: 20,
),


            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecoration(
                suffixIcon: Icon(Icons.email),
                hintText: 'Entrer votre email',
                labelText: 'E-mail',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onChanged: (value) {
                _email = value;
              },
            ),
            const SizedBox(
              height: 25,
            ),

          TextField(
            obscureText: _obscureText,
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
              ),
              hintText: 'Enter your password',
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            onChanged: (value) {
              _password = value;
            }
          ),
            const SizedBox(
              height: 30,
            ),
            RoundedButton(
              btnText: 'Connecter',
              onBtnPressed: () => loginPressed(),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const RegisterScreen(),
                    ));
              },
              child: const Text(
                'Crée Compte Auto-école',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    color: Colors.black
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

// Class User bech nestaaml l'id_User w token (the User When he loggin)
class User {
  final int id;
  final String token;

  User({required this.id, required this.token});
}

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }
}
