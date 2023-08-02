import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Services/auth_services.dart';
import '../Services/globals.dart';
import '../rounded_button.dart';

import 'home_Screens.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  int _currentPage = 0;
  Map<String, dynamic> _formData = {};

  // variable pour le variable adresse
  String? _selectedCity;
  // Store the selected city
  List<String> cities = [
    'Tunis',
    'Sfax',
    'Sousse',
    'Ettadhamen',
    'Kairouan',
    'Gabès',
    'Bizerte',
    'Ariana',
    'Gafsa',
    'Sahline',
    'Zaghouan',
    'Kasserine',
    'Ben Arous',
    'Mnihla',
    'Monastir',
    'Marsa',
    'La Goulette',
    'Medenine',
    'Hammam-Lif',
    'L\'Ariana',
    'Tataouine',
    'Douane',
    'Béja',
    'La Soukra',
    'Sidi Bouzid',
  ];


// l'age de candidat entre 18 et 65 ans pour éviter les risques d'enregistrement de fausse donneés dans la base
  DateTime firstAllowedDate = DateTime.now().subtract(Duration(days: 65 * 365));
  DateTime lastAllowedDate = DateTime.now().subtract(Duration(days: 18 * 365));

  bool _obscureText = true;
  //les attributs nécessaire pour une auto-école
  String _nom_agence = '';
  int _code_agence = 1;
  String _adresse = '';
  String _num_tel = '';
  String _email = '';
  String _matri_fisc = '';
  String _password = '';
  String _confirm_pass = '';

  createAccountPressed() async {
    bool emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_email);
    if (emailValid) {
      http.Response response =
      (await AuthServices.register(_nom_agence,  _email, _password, _confirm_pass, _adresse, _code_agence, _num_tel, _matri_fisc)) as http.Response;
      Map responseMap = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ListPacks(),
            ));
      } else {
        errorSnackBar(context, responseMap.values.first[0]);
      }
    } else {
      errorSnackBar(context, 'E-mail non valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.account_box),
                hintText: 'Entrer le nom de votre agence',
                labelText: 'Nom Agence',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0), // Set the border radius here
                ),
              ),
              onChanged: (value) {
                _nom_agence = value;
              },
            ),

            const SizedBox(
              height: 15,
            ),
            TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.short_text),
                  hintText: 'Entrer le code agence',
                  labelText: 'Code Agence',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )
              ),
              onChanged: (value) {
                _code_agence = value as int;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              decoration: InputDecoration(
                prefixText:('+216') ,
                  suffixIcon: Icon(Icons.phone),
                  hintText: 'Entrer votre numéro de téléphone',
                  labelText: 'Numéro téléphone ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )
              ),
              onChanged: (value) {
                _num_tel = value;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.email),
                hintText: 'Entrer votre E-mail',
                labelText: 'E-mail',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                )
              ),
              onChanged: (value) {
                _email = value;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.maps_home_work_outlined),
                hintText: "Entrez l'adresse du candidat",
                labelText: 'Adresse',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Sélectionner une ville'),
                    content: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCity = newValue;
                          _adresse = newValue!; // Assign the selected city to _adresse
                        });
                        Navigator.pop(context);
                      },
                      items: cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              controller: TextEditingController(text: _selectedCity), // Set initial value in the text field
            ),
            const SizedBox(
              height: 15,
            ),
          TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.confirmation_num),
                  hintText: 'Entrer votre matricule fiscale',
                  labelText: 'Matricule Fiscale',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )
              ),
              onChanged: (value) {
                _matri_fisc = value;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                hintText: 'Choisir votre mot de passe',
                labelText: 'Mot De Passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onChanged: (value) {
                _password = value;
              },
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                hintText: 'Confirmer votre mot de passe',
                labelText: 'Confirmer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onChanged: (value) {
                _confirm_pass = value;
              },
            ),

            const SizedBox(
              height: 40,
            ),
            RoundedButton(
              btnText: 'Crée Compte',
              onBtnPressed: () => createAccountPressed(),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const LoginScreen(),
                    ));
              },
              child: const Text(
                'vous avez déjà un compte ?',
                style: TextStyle(
                  decoration: TextDecoration.underline,fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    ),
    );
  }
}
