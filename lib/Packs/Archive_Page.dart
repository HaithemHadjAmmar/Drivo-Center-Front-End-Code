import 'dart:convert';

import 'package:auto_ecole/Packs/Succed_Page.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Screens/login_screen.dart';
import '../gérer_Candidats/controllers/Candidats.dart';
import '../gérer_Candidats/controllers/Seance.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Archive extends StatefulWidget {
  const Archive({Key? key}) : super(key: key);

  @override
  State<Archive> createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';

  late Future<List<Seance>> _futureSeances;
  late Future<List<Datum>> _futureCandidat;


  Future<void> _performSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _futureSeances = rechercheSeance(_searchQuery);
    });
  }



  //get all Seances
  // get the seances where date == date d'aujourd'hui and whe user_id == user.id
  Future<List<Seance>> getSeances() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/candidats/archive/seance/${user?.id}'));
    if (response.statusCode == 200) {
      print(user?.id);
      print(response.body);
      final jsonData = json.decode(response.body);
      final seances = <Seance>[];
      for (var item in jsonData) {
        seances.add(Seance.fromJson(item));
      }
      return seances;
    } else {
      throw Exception('Failed to get seances');
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


  // recherche les historique de séances
  Future<List<Seance>> rechercheSeance(String query) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/recherche/seancehis/${user?.id}?query=$query'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'];
        final List<Seance> seances = dataList
            .map((e) => Seance.fromJson(e))
            .toList();

        if (seances.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Aucune séance trouvée'),
                content: Text('Aucune séance ne correspond à votre recherche.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }

        return seances;
      } else {
        throw Exception('Échec du chargement des séances');
      }
    } catch (e) {
      print('Erreur lors de la récupération des séances : $e');
      throw Exception('Échec du chargement des séances');
    }
  }

  @override
  void initState() {
    _futureSeances = getSeances();
    _futureCandidat = getCandidats();
    _futureSeances = rechercheSeance(_searchQuery);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Historique Séance',
            style: TextStyle(
                fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: HexColor('4159A2')
            ),),
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),color: HexColor('4159A2'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => NextPage(),
                  ));
            },
          ),
        ),

        body: SingleChildScrollView(
            child: FutureBuilder<List<dynamic>>(
                future: Future.wait<List<dynamic>>([getSeances(), getCandidats()]),
                builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData &&
                      snapshot.data![0].isNotEmpty &&
                      snapshot.data![1].isNotEmpty) {
                    final List<Seance> seances = snapshot.data![0].cast<Seance>();
                    final List<Datum> candidats = snapshot.data![1].cast<Datum>();

                    Map<String, Map<String, List<Datum>>> candidatesByDateAndTypeAndId = {};

                    for (Seance seance in seances) {
                      final String key = '${seance.date}';
                      final List<Datum> candidatesForSeance = candidats
                          .where((candidat) => candidat.id == seance.candidatId)
                          .toList();

                      if (candidatesByDateAndTypeAndId.containsKey(key)) {
                        final Map<String, List<Datum>> candidatesById =
                        candidatesByDateAndTypeAndId[key]!;

                        if (candidatesById.containsKey(seance.candidatId.toString())) {
                          candidatesById[seance.candidatId.toString()]!
                              .addAll(candidatesForSeance);
                        } else {
                          candidatesById[seance.candidatId.toString()] =
                              candidatesForSeance;
                        }
                      } else {
                        candidatesByDateAndTypeAndId[key] = {
                          seance.candidatId.toString(): candidatesForSeance
                        };
                      }
                    }

                    return  Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Recherche...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                            onSubmitted: (value) async {
                              setState(() {
                                _searchQuery = value;
                                _futureSeances = rechercheSeance(value);
                              });
                            },
                          ),
                        ),

                        ...candidatesByDateAndTypeAndId.entries.map((entry) => Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(padding: EdgeInsets.all(8.0),
                                child:  Text(
                                    DateFormat.yMMMMd().format(DateTime.parse(entry.key)),
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                                  ),
                                  )
                                ],
                              ),
                          Column(
                            children: entry.value.entries
                                .map((subEntry) => Column(
                              children: [
                                ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: subEntry.value.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final Datum candidate = subEntry.value[index];
                                      final Seance seance = seances[index];

                                      return AnimationConfiguration.staggeredList(
                                          position: index,
                                          duration: const Duration(milliseconds: 800),
                                          child: SlideAnimation(
                                              verticalOffset: 50.0,
                                              child: FadeInAnimation(
                                                  child: Padding(
                                                      padding: EdgeInsets.all(16.0),
                                                      child: Card(
                                                          elevation: 5,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(30),
                                                              bottomLeft: Radius.circular(30),
                                                              topRight: Radius.circular(35),
                                                              bottomRight: Radius.circular(35),
                                                            ),
                                                          ),
                                                          child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 29,
                                                                  decoration: BoxDecoration(
                                                                    color:  HexColor('4159A2'),
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(35),
                                                                      bottomLeft: Radius.circular(35),
                                                                    ),
                                                                  ),
                                                                  height: 100,
                                                                ),
                                                                SizedBox(width: 8),
                                                                Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                              children: [
                                                                                Text(
                                                                                  '${candidate.nom} ${candidate.prenom}',
                                                                                  style: TextStyle(
                                                                                      fontSize: 18,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontFamily: 'Roboto'
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 20.0),
                                                                                Text(
                                                                                  DateFormat.Hm().format(
                                                                                    DateFormat('HH:mm:ss').parse(seance.heureDebut),
                                                                                  ),
                                                                                  style: TextStyle(
                                                                                    color: Colors.grey,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'Roboto',
                                                                                    fontSize: 18,
                                                                                  ),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ]
                                                                          ),
                                                                          SizedBox(height: 5.0),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                '${seance.nbrHeure} heure',
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'Roboto',
                                                                                    fontSize: 17
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 200.0),
                                                                              Positioned(
                                                                                left: 0,
                                                                                top: 90,
                                                                                child: Container(
                                                                                  width: 15,
                                                                                  height: 15,
                                                                                  decoration: BoxDecoration(
                                                                                    color: HexColor('4159A2'),
                                                                                    shape: BoxShape.circle,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          SizedBox(height: 8.0),
                                                                          Row(
                                                                              children: [
                                                                                Text(
                                                                                  '${seance.type}',
                                                                                  style: TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontFamily: 'Roboto',
                                                                                      fontSize: 17
                                                                                  ),
                                                                                ),
                                                                              ]
                                                                          ),
                                                                        ]
                                                                    )
                                                                )
                                                              ]
                                                          )
                                                      )
                                                  )
                                              )
                                          )
                                      );
                                    }
                                )
                              ],
                            ))
                                .toList(),
                          ),
                        ],
                      )
                      ).toList(),
                    ]
                    );
                  } else {
                    return Center(child: CircularProgressIndicator(),);
                  }
                }
            )
        )
    );
  }
}

class SearchResult {
  Datum datum;
  Seance seance;

  SearchResult({required this.datum, required this.seance});
}