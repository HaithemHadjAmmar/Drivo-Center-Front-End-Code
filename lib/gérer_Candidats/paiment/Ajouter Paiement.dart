import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../Screens/login_screen.dart';
import '../controllers/Candidats.dart';
import '../../rounded_button.dart';


class Ajouter_Paiement extends StatefulWidget {
  const Ajouter_Paiement({required this.candidatId, Key? key}) : super(key: key);
  final int candidatId;

  @override
  State<Ajouter_Paiement> createState() => _Ajouter_PaiementState();
}

class _Ajouter_PaiementState extends State<Ajouter_Paiement> {
  final _dateFormat = DateFormat('yyyy-MM-dd');
  //cotrollor lel DropDownMenuItem
  TextEditingController _candidatController = TextEditingController();
  //Controlleur lel attribut Date
  TextEditingController _dateController = TextEditingController();
  TextEditingController _controller = TextEditingController();

  //controller for the recherche TextField
  final TextEditingController _searchController = TextEditingController();


  late Future<List<Datum>> _futureCandidat;
  //liste des vides des candidast pour stoker le résultat de recherche
  List<Datum> _searchResults = [];

  Datum? _selectedCandidat;
  //les attributs necessaire pour une Seance
  DateTime _datePaiement = DateTime(2000, 1, 1);
  double _montant = 0.0;


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

// ajouter paiement
  Future<void> createPaiement({required int candidatId}) async {
    final apiUrl = 'http://10.0.2.2:8000/api/candidat/paiement';

    final formattedDate = DateFormat('yyyy-MM-dd').format(_datePaiement);

    if (_montant ==  null || formattedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tous les champs sont obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'candidat_id': candidatId,
          'montant': _montant,
          'date_paiement': formattedDate,
        }),
      );
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Payment stored successfully: ${responseData['paiment']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Montant ajouté avec succès!!'),
            backgroundColor: Colors.green,
          ),
        );
        // Handle successful payment creation
      } else {
        final errorData = json.decode(response.body);
        print('Failed to create payment: ${errorData['error']}');
        // Handle failed payment creation
      }
    } catch (error) {
      print('An error occurred: $error');
      // Handle error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while creating the payment.'),
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

// get Candidats
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
                          builder: (BuildContext context) => Ajouter_Paiement(candidatId: 1),
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
          title: Text('Ajouter Paiement', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: HexColor('4159A2')),),
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
                                  ' Le Montant a payer:',
                                  style: TextStyle(
                                      fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),

                                TextFormField(
                                  controller: _controller,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _montant = double.tryParse(value) ?? 0.0; // Parse the entered value to double
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    labelText: 'Montant',
                                  ),
                                ),

                                SizedBox(height: 8.0),

                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  ' Date du Paiement:',
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
                                      lastDate: DateTime.now(),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        _datePaiement = selectedDate;
                                        _dateController.text =
                                            _dateFormat.format(selectedDate);
                                      });
                                    }
                                  },
                                ),

                                SizedBox(
                                  height: 40,
                                ),
                                RoundedButton(
                                  btnText: 'Ajouter Montant',
                                  onBtnPressed: () {
                                    if (_selectedCandidat != null) {
                                      createPaiement(candidatId: _selectedCandidat!.id!,);
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
//       ** fin class paiement **
