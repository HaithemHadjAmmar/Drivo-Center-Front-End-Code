import 'package:auto_ecole/Examen/listeSeances.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../Screens/login_screen.dart';
import '../gérer_Candidats/controllers/Candidats.dart';
import '../rounded_button.dart';
import 'Examen.dart';
import '../Packs/Succed_Page.dart';


class Ajouter_Test extends StatefulWidget {
  const Ajouter_Test({Key? key}) : super(key: key);

  @override
  State<Ajouter_Test> createState() => _Ajouter_TestState();
}

class _Ajouter_TestState extends State<Ajouter_Test> {
  final _dateFormat = DateFormat('yyyy-MM-dd');
  //cotrollor lel DropDownMenuItem
  TextEditingController _candidatController = TextEditingController();
  //lel attribut Date
  TextEditingController _dateController = TextEditingController();
//controller for dateDebut
  TextEditingController _timeController = TextEditingController();
// controllor lel nbrHeure
  TextEditingController _heureController = TextEditingController();
  //controller fo the recherche
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Datum>> _futureCandidat;
  //liste des vides des candidast pour stoker le résultat de recherche
  List<Datum> _searchResults = [];



  Datum? _selectedCandidat;
  //les attributs necessaire pour un Examen
  DateTime _date = DateTime(2000, 1, 1);
  String _heure = '';
  String _type = 'code';
  int _candidatId = 1;

  //
  String _searchQuery = '';
  bool showSearchBar = false;

  List<String> hoursList =
  List.generate(24, (index) => '${index.toString().padLeft(2, '0')}:00');

  @override
  void initState() {
    super.initState();
    _futureCandidat = getCandidats();
    _futureCandidat = rechercheCandidat(_searchQuery);
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _searchQuery = query;
    });
    rechercheCandidat(query).then((results) {
      setState(() {
        _searchResults = results;
        if (_searchResults.isNotEmpty) {
          _selectedCandidat = _searchResults[0];
          _candidatController.text =
          '${_searchResults[0].nom} ${_searchResults[0].prenom}';
        }
      });
    }).catchError((error) {
      print('Error performing search: $error');
    });
  }


  final _formKey = GlobalKey<FormState>();

  // Ajouter Seance
  Future<void> createExamen({required int candidatId}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? 0;

    if (_date != null && _heure.isNotEmpty && _type.isNotEmpty) {
      final examen = Examen(
        candidatId: _selectedCandidat!.id!,
        date: _date,
        heure: _heure,
        type: _type,
        id: 1,
      );

      try {
        http.Response response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/candidats/examen'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(examen.toJson()),
        );
        if (response.statusCode == 200) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Examen ajouté avec succès !!',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to NextPage or refresh the current page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => Liste_Examens()),
          );
        } else {
          final responseMap =
          jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage = responseMap['message'] as String;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Liste_Examens()),
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
    } else {
      // Show red snack bar for empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tous les champs sont obligatoires',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


// getCandidats() selon l'user
  Future<List<Datum>> getCandidats() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/select/candidats/${user?.id}'));
    if (response.statusCode == 200) {
      print(user?.id);
      print(response.body);
      final jsonData = json.decode(response.body);
      final candidats = <Datum>[];
      for (var item in jsonData['data']) {
        candidats.add(Datum.fromJson(item));
      }
      return candidats;
    } else {
      throw Exception('Failed to get candidats');
    }
  }


  // chercher Candidat
  Future<List<Datum>> rechercheCandidat(String query) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/recherche/candidat/${user?.id}?q=$query'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'];
        final List<Datum> clist = dataList
            .map((e) => Datum.fromJson(e))
            .where((c) =>
        c.nom.toLowerCase().contains(query.toLowerCase()) ||
            c.prenom.toLowerCase().contains(query.toLowerCase()) ||
            c.cin.toLowerCase().contains(query.toLowerCase()) ||
            c.email.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (clist.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Aucun candidat trouvé'),
                content: Text('Aucun candidat ne correspond à votre recherche.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (BuildContext context) => Ajouter_Test(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }

        return clist;
      } else {
        throw Exception('Échec du chargement des candidats');
      }
    } catch (e) {
      print('Erreur lors de la récupération des candidats : $e');
      throw Exception('Échec du chargement des candidats');
    }
  }


  void _runSearch(String query) {
    setState(() {
      _searchQuery = query;
      _futureCandidat = rechercheCandidat(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final userId = user?.id;
    return Scaffold(
        appBar: AppBar(
          title: Text('Ajouter Examen', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: HexColor('4159A2')),),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios),color: HexColor('4159A2'),
          ),
        ),
        body: Center(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(14.0),
                child: Container(
                    child: FutureBuilder<List<Datum>>(
                        future: getCandidats(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                          }
                          if (snapshot.hasError) {
                            return Text('Error loading candidats: ${snapshot.error}');
                          }
                          List<Datum>? candidats = snapshot.data;
                          if (candidats == null || candidats.isEmpty) {
                            return CircularProgressIndicator();
                          }

                          final user = Provider.of<UserProvider>(context, listen: false).user;
                          final filteredCandidats = candidats.where((candidat) => candidat.userId == user?.id).toList();

                          return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Rechercher Candidat',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                        _performSearch(value); // Perform search based on the input
                                      });
                                    },
                                    onSubmitted: (value) async {
                                      await _performSearch(value);
                                    },
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Choisissez un Candidat:',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _candidatController,
                                  readOnly: true, // Disable text editing
                                  decoration: InputDecoration(
                                    labelText: 'Choisissez Candidat ',
                                    labelStyle: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      borderSide: BorderSide(
                                        color: HexColor('A2BFE4'),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.white,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: MediaQuery.of(context).copyWith().size.height / 3,
                                          child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount: _searchResults.length, // Use the search results
                                                  itemBuilder: (context, index) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedCandidat = _searchResults[index];
                                                          _candidatController.text =
                                                          '${_searchResults[index].nom} ${_searchResults[index].prenom}';
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 16.0,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20.0),
                                                          color: HexColor('DDF6DF'),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey,
                                                              blurRadius: 2.0,
                                                              spreadRadius: 0.0,
                                                              offset: Offset(2.0, 2.0),
                                                            )
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                            vertical: 16.0,
                                                            horizontal: 24.0,
                                                          ),
                                                          child: Text(
                                                            '${_searchResults[index].nom} ${_searchResults[index].prenom}',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),

                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Choisissez le type de séance:',
                                  style: TextStyle(
                                      fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text('Code', style: TextStyle(fontWeight: FontWeight.bold,  fontFamily: 'Robobto'),),
                                        value: 'code',
                                        groupValue: _type,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _type = value!;
                                          });
                                        },
                                        activeColor: HexColor('4159A2'),
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text('Conduite', style: TextStyle(fontWeight: FontWeight.bold,  fontFamily: 'Robobto'),),
                                        value: 'conduite',
                                        groupValue: _type,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _type = value!;
                                          });
                                        },
                                        activeColor: HexColor('4159A2'),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text('Park', style: TextStyle(fontWeight: FontWeight.bold,  fontFamily: 'Robobto'),),
                                        value: 'park',
                                        groupValue: _type,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _type = value!;
                                          });
                                        },
                                        activeColor: HexColor('4159A2'),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Choisissez le Date du Seance:',
                                  style: TextStyle(
                                      fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0),
                                TextFormField(
                                  readOnly: true,
                                  controller: _dateController,
                                  decoration: InputDecoration(
                                    labelText: 'Choisissez une Date',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18.0)
                                    ),
                                  ),
                                  onTap: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(Duration(days: 3650)),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        _date = selectedDate;
                                        _dateController.text =
                                            _dateFormat.format(selectedDate);
                                      });
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Choisissez une du Seance:',
                                  style: TextStyle(
                                      fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0),
                                TextFormField(
                                  readOnly: true,
                                  controller: _timeController,
                                  decoration: InputDecoration(
                                    labelText: 'Choisissez une heure',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                  ),
                                  onTap: () async {
                                    final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (selectedTime != null) {
                                      setState(() {
                                        _heure =
                                        '${selectedTime.hour.toString().padLeft(2,
                                            '0')}:${selectedTime.minute.toString().padLeft(
                                            2, '0')}:00';
                                        _timeController.text = _heure;
                                      });
                                    }
                                  },
                                ),

                                SizedBox(
                                  height: 40,
                                ),
                                RoundedButton(
                                  btnText: 'Ajouter Examen',
                                  onBtnPressed: () {
                                    if (_selectedCandidat != null) {
                                      createExamen(candidatId: _selectedCandidat!.id!,);
                                    }
                                  },
                                ),
                              ]
                          );

                        }
                    )
                )
            )
        )
    );
  }

}
