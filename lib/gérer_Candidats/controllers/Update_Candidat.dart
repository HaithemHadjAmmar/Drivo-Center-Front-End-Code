import 'dart:convert';

import 'package:auto_ecole/Packs/Succed_Page.dart';
import 'package:auto_ecole/g%C3%A9rer_Candidats/controllers/listCandidats.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Services/globals.dart';
import '../../rounded_button.dart';
import 'Candidats.dart';
import 'databaseHelper.dart';

class UpdateCandidat extends StatefulWidget {
  final int candidatId;

  UpdateCandidat({required this.candidatId});

  @override
  _UpdateCandidatState createState() => _UpdateCandidatState();
}

 class _UpdateCandidatState extends State<UpdateCandidat> {
   late Future<Datum> _candidatData;
   late TextEditingController _nomController;
   late TextEditingController _prenomController;
   late TextEditingController _emailController;
   late TextEditingController _dateNaissanceController;
   late TextEditingController _cinController;
   late TextEditingController _numTelController;
   late TextEditingController _adresseController;
   late TextEditingController _prixHeureController;
   late TextEditingController _prixHeureParkController;
   late TextEditingController _prixHeureCodeController;
   late TextEditingController _avanceController;
   late TextEditingController _nbr_heureController;
   late TextEditingController _nbr_heureCodeController;
   late TextEditingController _nbr_HeureParkController;
   late TextEditingController _passwordController;

   Future<Datum> getCandidatById(int id) async {
     try {
       final response = await http.get(
           Uri.parse('http://10.0.2.2:8000/api/select/candidat/$id'));
       if (response.statusCode == 200) {
         dynamic decodedData = jsonDecode(response.body);
         if (decodedData is Map<String, dynamic> &&
             decodedData.containsKey('data')) {
           final Map<String, dynamic> data = decodedData['data'];
           final Datum candidat = Datum.fromJson(data);
           return candidat;
         } else {
           throw Exception('Failed to load candidat');
         }
       } else {
         throw Exception('Failed to load candidat');
       }
     } catch (e) {
       print('Error fetching candidat: $e');
       throw Exception('Failed to load candidat');
     }
   }


   void _updateCandidat() async {
     print('Updating candidate...');

     // Validate the email format
     bool emailValid = RegExp(
         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
         .hasMatch(_emailController.text);
     if (!emailValid) {
       errorSnackBar(context, 'E-mail non valide');
       return;
     }

     // Parse the numeric values
     int nbr_heure_total_code;
     int nbr_heure_total;
     int nbr_heure_total_park;
     try {
       nbr_heure_total_code = int.parse(_nbr_heureCodeController.text.trim());
       nbr_heure_total = int.parse(_nbr_heureController.text.trim());
       nbr_heure_total_park = int.parse(_nbr_HeureParkController.text.trim());
     } catch (e) {
       print('Error parsing numeric values: $e');
       errorSnackBar(context, 'Erreur de conversion numérique');
       return;
     }

     try {
       final response = await CandidatServices.updateCandidatById(
         widget.candidatId.toString(),
         _nomController.text,
         _prenomController.text,
         DateTime.parse(_dateNaissanceController.text),
         _cinController.text,
         int.parse(_numTelController.text.trim()),
         _adresseController.text,
         _emailController.text,
         _prixHeureCodeController.text,
         _prixHeureController.text,
         _prixHeureParkController.text,
         _avanceController.text,
         nbr_heure_total_code,
         nbr_heure_total,
         nbr_heure_total_park,
         _passwordController.text,
       );

       if (response.statusCode == 200) {
         final rowsUpdated = int.parse(response.body);
         if (rowsUpdated > 0) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               backgroundColor: Colors.green,
               content: Text('Candidat modifié avec succès !!'),
             ),
           );
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (BuildContext context) => ListCandidats(),
             ),
           );
         } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               backgroundColor: Colors.red,
               content: Text('La mise à jour a échoué'),
             ),
           );
         }
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             backgroundColor: Colors.red,
             content: Text('Erreur lors de la mise à jour du candidat'),
           ),
         );
       }
     } catch (e) {
       print('true: $e');
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           backgroundColor: Colors.green,
           content: Text('Candidat modifié avec succès !!'),
         ),
       );
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
           builder: (BuildContext context) => ListCandidats(),
         ),
       );
     }
   }

     @override
     void initState() {
       super.initState();
       _candidatData = getCandidatById(widget.candidatId);
       _nomController = TextEditingController();
       _prenomController = TextEditingController();
       _emailController = TextEditingController();
       _dateNaissanceController = TextEditingController();
       _cinController = TextEditingController();
       _numTelController = TextEditingController();
       _adresseController = TextEditingController();
       _prixHeureCodeController = TextEditingController();
       _prixHeureController = TextEditingController();
       _prixHeureParkController = TextEditingController();
       _avanceController = TextEditingController();
       _nbr_heureCodeController = TextEditingController();
       _nbr_heureController = TextEditingController();
       _nbr_HeureParkController = TextEditingController();
       _passwordController = TextEditingController();
     }

     @override
     void dispose() {
       _nomController.dispose();
       _prenomController.dispose();
       _emailController.dispose();
       _dateNaissanceController.dispose();
       _cinController.dispose();
       _numTelController.dispose();
       _adresseController.dispose();
       _prixHeureCodeController.dispose();
       _prixHeureController.dispose();
       _prixHeureParkController.dispose();
       _avanceController.dispose();
       _nbr_heureCodeController.dispose();
       _nbr_heureController.dispose();
       _nbr_HeureParkController.dispose();
       _passwordController.dispose();
       super.dispose();
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: Text('Modifier Candidat', style: TextStyle(
               fontWeight: FontWeight.bold,
               fontFamily: 'Roboto',
               color: HexColor('4159A2')),),
           backgroundColor: Colors.white,
           centerTitle: true,
           leading: IconButton(
             icon: Icon(Icons.arrow_back_ios), color: HexColor('4159A2'),
             onPressed: () {
               Navigator.pushReplacement(
                   context,
                   MaterialPageRoute(
                   builder: (BuildContext context) => ListCandidats(),
               ));
             },
           ),
         ),
         body: Center(
           child: FutureBuilder<Datum>(
             future: _candidatData,
             builder: (context, snapshot) {
               if (snapshot.hasData) {
                 final candidat = snapshot.data!;

                 _nomController.text = candidat.nom;
                 _prenomController.text = candidat.prenom;
                 _emailController.text = candidat.email;
                 _dateNaissanceController.text = candidat.dateNaissance.toString();
                 _cinController.text = candidat.cin;
                 _numTelController.text = candidat.numTel.toString();
                 _adresseController.text = candidat.adresse;
                 _prixHeureCodeController.text = candidat.prixHeureCode;
                 _prixHeureController.text = candidat.prixHeure;
                 _prixHeureParkController.text = candidat.prixHeurePark;
                 _avanceController.text = candidat.avance;
                 _nbr_heureController.text = candidat.nbrHeureTotal.toString();
                 _nbr_heureCodeController.text = candidat.nbrHeureTotalCode.toString();
                 _nbr_HeureParkController.text = candidat.nbrHeureTotalPark.toString();
                 _passwordController.text = candidat.password;

                 return SingleChildScrollView(
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
                                   labelText: 'Nom du Candidat',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _nomController,
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             TextField(
                               keyboardType: TextInputType.name,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(Icons.person),
                                   labelText: 'Prénom',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _prenomController,
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             TextField(
                               keyboardType: TextInputType.emailAddress,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(Icons.email),
                                   labelText: 'Email',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _emailController,
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             TextField(
                               decoration: InputDecoration(
                                   suffixIcon: Icon(Icons.calendar_month),
                                   labelText: 'Date de naissance',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _dateNaissanceController,
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             TextField(
                               keyboardType: TextInputType.number,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(Icons.credit_card),
                                   labelText: 'CIN',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _cinController,
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             TextField(
                               keyboardType: TextInputType.phone,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(Icons.phone),
                                   labelText: 'Numéro téléphone',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _numTelController,
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             TextField(
                               decoration: InputDecoration(
                                   suffixIcon: Icon(
                                       Icons.maps_home_work_outlined),
                                   labelText: 'Adresse',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _adresseController,
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             TextField(
                               keyboardType:TextInputType.number,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(
                                       Icons.monetization_on_outlined),
                                   labelText: 'Prix Heure Code',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _prixHeureCodeController,
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             TextField(
                               keyboardType: TextInputType.number,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(
                                       Icons.monetization_on_outlined),
                                   labelText: 'Prix Heure Conduite',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _prixHeureController,
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             TextField(
                               keyboardType: TextInputType.number,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(
                                       Icons.monetization_on_outlined),
                                   labelText: 'Prix Heure park',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _prixHeureParkController,
                             ),
                             SizedBox(
                               height: 15,
                             ), TextField(
                               keyboardType: TextInputType.number,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(Icons.money_outlined),
                                   labelText: 'Avance',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _avanceController,
                             ),
                             SizedBox(
                               height: 15,
                             ), TextField(
                               keyboardType: TextInputType.number,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(Icons.timer),
                                   labelText: 'Nombre heure Code',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _nbr_heureCodeController,
                             ),
                             SizedBox(
                               height: 15,
                             ), TextField(
                               keyboardType: TextInputType.number,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(Icons.timer),
                                   labelText: 'Nombre Heure Conduite',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _nbr_heureController,
                             ),
                             SizedBox(
                               height: 15,
                             ), TextField(
                               keyboardType: TextInputType.number,
                               decoration: InputDecoration(
                                   suffixIcon: Icon(Icons.timer),
                                   labelText: 'Nombre Heure park',
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(18.0),
                                   )
                               ),
                               controller: _nbr_HeureParkController,
                             ),
                             SizedBox(
                               height: 25,
                             ),
                             RoundedButton(
                               btnText: 'Mettre a jour ',
                               onBtnPressed: () => _updateCandidat(),
                             ),
                             SizedBox(
                               height: 25,
                             ),
                           ],
                         )
                     )
                 );
               } else if (snapshot.hasError) {
                 return Text('Error fetching candidat data: ${snapshot.error}');
               } else {
                 return CircularProgressIndicator();
               }
             },
           ),
         ),
       );
     }
   }