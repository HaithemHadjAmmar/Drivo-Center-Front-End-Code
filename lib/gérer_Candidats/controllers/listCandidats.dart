import 'dart:convert';

import 'package:auto_ecole/Packs/Succed_Page.dart';
import 'package:auto_ecole/g%C3%A9rer_Candidats/controllers/Add_new_candidat.dart';
import 'package:auto_ecole/g%C3%A9rer_Candidats/controllers/Details_candidats.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Screens/login_screen.dart';
import '../../Services/globals.dart';
import 'Autoécole.dart';
import 'Candidats.dart';
import 'Update_Candidat.dart';

class ListCandidats extends StatefulWidget {

  const ListCandidats({Key? key,}) : super(key: key);

  @override
  State<ListCandidats> createState() => _ListCandidatsState();
}

class _ListCandidatsState extends State<ListCandidats> {
  late Future<List<Datum>> _futureCandidat;


  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';

  bool isExpanded = false;


  Future<void> _performSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _futureCandidat = rechercheCandidat(query);
    });
  }


  @override
  void initState() {
    super.initState();
    _futureCandidat = getCandidats();
    _loadData();

    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    _performSearch(_searchController.text);
  }

  Future<void> _loadData() async {
    try {
      await deleteCandidat(1);
      setState(() {
        _futureCandidat = rechercheCandidat(_searchQuery);
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }




// supprimer Candidat
  Future<void> deleteCandidat(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/api/delete/candidat/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // La suppression a réussi
      print('Candidat supprimé avec succès.');
    } else {
      // La suppression a échoué
    //  print('Erreur lors de la suppression du candidat: ${response.body}');
    }
  }


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
                          builder: (BuildContext context) => ListCandidats(),
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
      _futureCandidat = rechercheCandidat(_searchQuery);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste Candidats', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: HexColor('4159A2')),),
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed:()
          {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => NextPage(),
                ));
          },
          icon:Icon(Icons.arrow_back_ios),color: HexColor('4159A2'),
        ),
      ),

      body: FutureBuilder<List<Datum>>(
        future: _futureCandidat,
        builder: (BuildContext context, AsyncSnapshot<List<Datum>> snapshot) {
          if (snapshot.hasData) {
            final filteredCandidats = snapshot.data!.where((candidat) => candidat.userId == Provider.of<UserProvider>(context, listen: false).user?.id).toList();

            return Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
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
                      });
                    },
                    onSubmitted: (value) async {
                      await _performSearch(value);
                    },
                  )
                ),

                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                     itemCount: filteredCandidats.length,
                      itemBuilder: (BuildContext context, int index) {
                        return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 800),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Dismissible(
                                  key: UniqueKey(),
                                  background: Container(
                                    color: Colors.green,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: Icon(Icons.edit, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 20),
                                        child: Icon(Icons.delete, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  onDismissed: (direction) async {
                                    if (direction == DismissDirection.endToStart) {
                                      // show confirmation dialog
                                      bool confirmDelete = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmer la suppression'),
                                            content: Text(
                                                'Êtes-vous sûr(e) de vouloir supprimer ce candidat ?'),
                                            actions: [
                                              TextButton(
                                                child: Text('Annuler'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                  Navigator.of(context).pushReplacement(
                                                    MaterialPageRoute(builder: (context) =>
                                                        ListCandidats()),
                                                  );
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Supprimer'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmDelete) {
                                        // handle delete operation
                                        deleteCandidat(snapshot.data![index].id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Container(
                                              height: 14,
                                              child: Center(
                                                child: Text(
                                                  'Candidat Supprimer avec Succés !',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) => ListCandidats()),
                                        );
                                      }
                                    } else if (direction == DismissDirection.startToEnd) {
                                      // handle update operation
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateCandidat(
                                                  candidatId: snapshot.data![index].id),
                                        ),
                                      ).then((result) {
                                        if (result != null && result) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Container(
                                                height: 14,
                                                child: Center(
                                                  child: Text(
                                                    'Candidat mis à jour avec succès!',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          setState(() {}); // refresh the list view
                                        }
                                      });
                                    }
                                  },
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Details_candidats(
                                            nom: snapshot.data![index].nom,
                                            prenom: snapshot.data![index].prenom,
                                            cin: snapshot.data![index].cin,
                                            numTel: snapshot.data![index].numTel,
                                            email: snapshot.data![index].email,
                                            adresse: snapshot.data![index].adresse,
                                            px_h: snapshot.data![index].prixHeure,
                                            px_h_c: snapshot.data![index].prixHeureCode,
                                            px_h_P: snapshot.data![index].prixHeurePark,
                                            id: snapshot.data![index].id,
                                            d_n: snapshot.data![index].dateNaissance,
                                            avance: snapshot.data![index].avance,
                                            nbHT: snapshot.data![index].nbrHeureTotal,
                                            nbHtC: snapshot.data![index].nbrHeureTotalCode,
                                            nbHtP: snapshot.data![index].nbrHeureTotalPark,
                                            data: snapshot.data![index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Card(
                                        elevation: 5,
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: HexColor('DDF6DF'),
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${snapshot.data![index].nom}',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 6,
                                                    ),
                                                    Text(
                                                      '${snapshot.data![index].prenom}',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar:CurvedNavigationBar(
        color: HexColor('4159A2'),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor:HexColor('4159A2'),
        height: 55,
        items: <Widget>[
          Icon(Icons.add, size: 45,color: Colors.white,),
        ],
        onTap: (index) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewCandidat()),
          );
        },
      ),
    );
  }
}