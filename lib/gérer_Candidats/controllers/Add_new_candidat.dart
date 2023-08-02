import 'dart:convert';

import 'package:auto_ecole/g%C3%A9rer_Candidats/controllers/listCandidats.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Screens/login_screen.dart';
import '../../rounded_button.dart';
import 'Candidats.dart';


class AddNewCandidat extends StatefulWidget {
  const AddNewCandidat({Key? key}) : super(key: key);

  @override
  State<AddNewCandidat> createState() => _AddNewCandidatState();
}

class _AddNewCandidatState extends State<AddNewCandidat> {

  // variable pour le password
  bool _obscureText = true;
// controlleur pour la date de naissance
  TextEditingController _dateNaissanceController = TextEditingController();
  // pour le format de la dated e naissance
  final _dateFormat = DateFormat('yyyy-MM-dd');
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


// l'age de candidat entre 18 et 65 ans
  DateTime firstAllowedDate = DateTime.now().subtract(Duration(days: 65 * 365));
  DateTime lastAllowedDate = DateTime.now().subtract(Duration(days: 18 * 365));


  String _nom = '';
  String _prenom = '';
  String _email = '';
  DateTime _date_naissance = DateTime(2000, 1, 1);
  String _cin = '';
  String _num_tel = '';
  String? _adresse = '';
  String _prix_heure = '';
  String _prix_heure_park  = '';
  String _prix_heure_code = '';
  String _avance = '';
  int _nbrHeure = 0;
  int _nbrHeureCode = 0;
  int _nbrHeurePark = 0;
  String _password = '';


  // fonction isNumeric pour la validation des champs (send only numéric value)
  bool isNumeric(String? value) {
    if (value == null) return false;
    return double.tryParse(value) != null;
  }

 // ajouter nouvelle candidat
  void createAccountcandidat({required int? userId}) async {
    // Get the user ID from the UserProvider
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final userId = user?.id;

    if (_nom.isEmpty ||
        _prenom.isEmpty ||
        _date_naissance == null ||
        _cin.isEmpty ||
        _num_tel.isEmpty ||
        _email.isEmpty ||
        _adresse == null ||
        !_prix_heure.isEmpty && !isNumeric(_prix_heure) ||
        !_prix_heure_park.isEmpty && !isNumeric(_prix_heure_park) ||
        !_prix_heure_code.isEmpty && !isNumeric(_prix_heure_code) ||
        !_avance.isEmpty && !isNumeric(_avance)||
        _nbrHeure == null ||
        _nbrHeureCode == null ||
        _nbrHeurePark == null ||
        _password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tous les champs sont obligatoires ou contiennent des valeurs incorrectes',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_email);

    if (!emailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Adresse email invalide',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Datum newData = Datum(
      id: 0,
      userId: userId!,
      nom: _nom,
      prenom: _prenom,
      dateNaissance: _date_naissance,
      cin: _cin,
      numTel: int.parse(_num_tel),
      email: _email,
      adresse: _adresse!,
      prixHeure: _prix_heure,
      prixHeurePark: _prix_heure_park,
      prixHeureCode: _prix_heure_code,
      avance: _avance,
      nbrHeureTotal: _nbrHeure!,
      nbrHeureTotalCode: _nbrHeureCode!,
      nbrHeureTotalPark: _nbrHeurePark!,
      password: _password,
    );

    // Convert the Datum object to JSON
    String jsonData = welcomeToJson(Welcome(data: newData));

    try {
      http.Response response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/add/candidats/${user?.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newData.toJson()),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Candidat ajouté avec succès !!',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the NextPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => ListCandidats()),
        );
      } else {
        final responseMap = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = responseMap['message'] as String;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('\u{2705}'),
              content: Text(errorMessage),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) => ListCandidats()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Unexpected response from server'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final userId = user?.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title:  Text(
          'Ajouter Candidat',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              TextField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.person),
                  hintText: 'Entrer le nom de Candidat',
                  labelText: 'Nom',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0), // Set the border radius here
                  ),
                ),
                onChanged: (value) {
                  _nom = value;
                },
              ),

              const SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.person),
                    hintText: 'Entrer le prénom de candidat',
                    labelText: 'Prénom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    )
                ),
                onChanged: (value) {
                  _prenom = value;
                },
              ),
              const SizedBox(
                height: 15,
              ),

              TextFormField(
                readOnly: true,
                controller: _dateNaissanceController,
                decoration: InputDecoration(
                  suffixIcon:Icon(Icons.calendar_month),
                  labelText: 'Choisissez une Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: lastAllowedDate,
                    firstDate: firstAllowedDate,
                    lastDate: lastAllowedDate,
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _date_naissance = selectedDate;
                      _dateNaissanceController.text = _dateFormat.format(selectedDate);
                    });
                  }
                },
              ),


                const SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.email),
                    hintText: 'Entrer E-mail',
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.credit_card_outlined),
                    hintText: "Entrer le némuro de la carte d'identité",
                    labelText: 'CIN',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    )
                ),
                onChanged: (value) {
                  _cin = value;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.phone),
                    hintText: "Entrer le némuro de télephone",
                    labelText: 'Numéro de téléphone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    )
                ),
                onChanged: (value) {
                  _num_tel = int.parse(value).toString();
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
                            _adresse = newValue; // Assign the selected city to _adresse
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.monetization_on_outlined),
                  hintText: "Entrer le prix d'heure Code",
                  labelText: "Prix Heure code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0), // Set the border radius here
                  ),
                ),
                onChanged: (value) {
                  _prix_heure_code = value;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.monetization_on_outlined),
                  hintText: "Entrer le prix d'heure Conduite",
                  labelText: "Prix Heure Conduite",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0), // Set the border radius here
                  ),
                ),
                onChanged: (value) {
                  _prix_heure = value;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.monetization_on_outlined),
                  hintText: "Entrer le prix d'heure Park",
                  labelText: "Prix Heure Park",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0), // Set the border radius here
                  ),
                ),
                onChanged: (value) {
                  _prix_heure_park= value;
                },
              ),

              SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.money_outlined),
                  hintText: "Entrer l'avance du candidat",
                  labelText: 'Avance',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0), // Set the border radius here
                  ),
                ),
                onChanged: (value) {
                  _avance = value;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.money_outlined),
                  hintText: "Entrer le nombre d'heure total Code",
                  labelText: 'Nombre Heure Total Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0), // Set the border radius here
                  ),
                ),
                onChanged: (value) {
                   _nbrHeureCode = int.tryParse(value) ?? 0;

                },
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.money_outlined),
                  hintText: "Entrer le nombre d'heure total Conduite",
                  labelText: 'Nombre Heure Total Conduite',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0), // Set the border radius here
                  ),
                ),
                onChanged: (value) {
                   _nbrHeure = int.tryParse(value) ?? 0;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.money_outlined),
                  hintText: "Entrer le nombre d'heure total Park",
                  labelText: 'Nombre Heure Total Park',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0), // Set the border radius here
                  ),
                ),
                onChanged: (value) {
                   _nbrHeurePark = int.tryParse(value) ?? 0;
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
                  hintText: 'Choisir votre mot de passe',
                  labelText: 'mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                onChanged: (value) {
                  _password = value;
                },
              ),

              const SizedBox(
                height: 40,
              ),
              RoundedButton(
                btnText: 'Ajouter Candidat',
                onBtnPressed: () => createAccountcandidat(userId: userId),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}