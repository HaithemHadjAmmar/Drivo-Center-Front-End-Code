import 'dart:convert';

import 'package:auto_ecole/Examen/Archive_Examens.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Packs/Archive_Page.dart';
import '../Screens/login_screen.dart';
import '../gérer_Candidats/controllers/Candidats.dart';
import '../gérer_Candidats/controllers/Seance.dart';
import 'Examen.dart';
import 'package:http/http.dart' as http;


class Liste_Examens extends StatefulWidget {
  const Liste_Examens({Key? key}) : super(key: key);

  @override
  State<Liste_Examens> createState() => _Liste_ExamensState();
}

class _Liste_ExamensState extends State<Liste_Examens> {

  late Future<List<Examen>> _futureExamen;
  late Future<List<Datum>> _futureCandidat;


  // get Candidats
  Future<List<Datum>> getCandidats() async {
    final user = Provider
        .of<UserProvider>(context, listen: false)
        .user;
    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/select/candidats/${user?.id}'));
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



    //get Examen where date = dateD'aujourd'hui
  Future<List<Examen>> getExamens() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/candidats/examens/${user?.id}'));
    if (response.statusCode == 200) {
      print(user?.id);
      print(response.body);
      final jsonData = json.decode(response.body);
      final examens = <Examen>[];
      for (var item in jsonData) {
        examens.add(Examen.fromJson(item));
      }
      return examens;
    } else {
      throw Exception('Failed to get seances');
    }
  }


  @override
  void initState() {
    super.initState();
    _futureExamen = getExamens();
    _futureCandidat = getCandidats();

  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title:  Text(
            'Liste Examens',
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
        body: FutureBuilder(
            future: Future.wait([getExamens(), getCandidats()]),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Erreur: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                final loggedInUserId = Provider.of<UserProvider>(context, listen: false).user?.id;

                final List<Examen> examens = snapshot.data[0].cast<Examen>();
                final List<Datum> candidats = snapshot.data[1].cast<Datum>();

                return SingleChildScrollView(
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(DateFormat.yMMMMd().format(DateTime.now()),
                                style: TextStyle(fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto')),

                            SizedBox(width: 145,),

                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            Archive_examnes(),
                                      ));
                                },
                                icon: Icon(Icons.history, size: 35,
                                  color: HexColor('4159A2'),)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              children: [
                                Text(
                                  'Liste Examens Conduite:', style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto'),
                                ),
                              ]
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 3.0,
                  ),

                  Container(
                      height: 160,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: examens.where((s) => s.type == "conduite").toList().length,
                          itemBuilder: (BuildContext context, int index) {
                            final Examen examen = examens.where((s) => s.type == "conduite").toList()[index];

                            final List<Datum> matchingCandidats = candidats.where((candidat) => candidat.id == examen.candidatId && candidat.userId == userProvider.user?.id).toList();

                            if (matchingCandidats.isEmpty) {
                              // Handle the case when no matching candidats are found
                              return SizedBox.shrink(); // Return an empty SizedBox to hide the item
                            }


                            final Datum candidat = matchingCandidats.first;
                            return SizedBox(
                                width: 340,
                                child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),

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
                            height: 160,
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
                            '${candidat.nom} ${candidat.prenom}',
                            style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto'
                            ),
                            ),
                            SizedBox(
                            width: 18.0,
                            ),
                              Text(
                                DateFormat.Hm().format(
                                  DateFormat('HH:mm:ss').parse(examen.heure),
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

                              Divider(
                                color: Colors.grey,
                              ),

                              Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                children: [
                                                  Text(
                                                    'Date Examen:',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Roboto'
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 18.0,
                                                  ),
                                                  Text(
                                                    DateFormat('yyyy-MM-dd').format(examen.date),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Roboto',
                                                        fontSize: 17,
                                                        color: Colors.grey
                                                    ),
                                                  ),
                                                ]
                                            ),
                                          ]
                                      )
                                  ),


                                  SizedBox(
                                    height: 10.0,
                                  ),

                                Padding(
                                    padding: const EdgeInsets.only(top: 0.8, bottom: 8.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                              children: [
                                                Text(
                                                  'Type:',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Roboto'
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 18.0,
                                                ),
                                                Text(
                                                  examen.type,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Roboto',
                                                    fontSize: 17,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ]
                                          ),
                            ]
                                    )
                                ),

                                ]

                            )
                            ]
                            )
                            )
                            ]
                            )
                            )
                            )
                            );
                          }
                      )
                  ),


                  //type park
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              children: [
                                Text(
                                  'Liste Examens Park:', style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto'),
                                ),
                              ]
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 3.0,
                  ),
                  Container(
                      height: 160,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: examens.where((s) => s.type == "park").toList().length,
                          itemBuilder: (BuildContext context, int index) {
                            final Examen examen = examens.where((s) => s.type == "park").toList()[index];

                            final List<Datum> matchingCandidats = candidats.where((candidat) => candidat.id == examen.candidatId && candidat.userId == userProvider.user?.id).toList();

                            if (matchingCandidats.isEmpty) {
                              // Handle the case when no matching candidats are found
                              return SizedBox.shrink(); // Return an empty SizedBox to hide the item
                            }

                            final Datum candidat = matchingCandidats.first;
                            return SizedBox(
                                width: 340,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),

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
                                                height: 160,
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
                                                                '${candidat.nom} ${candidat.prenom}',
                                                                style: TextStyle(
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: 'Roboto'
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 18.0,
                                                              ),
                                                              Text(
                                                                DateFormat.Hm().format(
                                                                  DateFormat('HH:mm:ss').parse(examen.heure),
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

                                                        Divider(
                                                          color: Colors.grey,
                                                        ),

                                                        Column(
                                                            children: [
                                                              Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                                                  child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                            children: [
                                                                              Text(
                                                                                'Date Examen:',
                                                                                style: TextStyle(
                                                                                    fontSize: 18,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'Roboto'
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 18.0,
                                                                              ),
                                                                              Text(
                                                                                DateFormat('yyyy-MM-dd').format(examen.date),
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'Roboto',
                                                                                    fontSize: 17,
                                                                                    color: Colors.grey
                                                                                ),
                                                                              ),
                                                                            ]
                                                                        ),
                                                                      ]
                                                                  )
                                                              ),


                                                              SizedBox(
                                                                height: 10.0,
                                                              ),

                                                              Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                                                  child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                            children: [
                                                                              Text(
                                                                                'Type:',
                                                                                style: TextStyle(
                                                                                    fontSize: 18,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'Roboto'
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 18.0,
                                                                              ),
                                                                              Text(
                                                                                examen.type,
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: 'Roboto',
                                                                                  fontSize: 17,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ]
                                                                        ),
                                                                      ]
                                                                  )
                                                              ),
                                                            ]
                                                        )
                                                      ]
                                                  )
                                              )
                                            ]
                                        )
                                    )
                                )
                            );
                          }
                      )
                  ),

             // type code

                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              children: [
                                Text(
                                  'Liste Examens Code:', style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto'),
                                ),
                              ]
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 3.0,
                  ),

                  Container(
                      height: 160,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: examens.where((s) => s.type == "code").toList().length,
                          itemBuilder: (BuildContext context, int index) {
                            final Examen examen = examens.where((s) => s.type == "code").toList()[index];

                            final List<Datum> matchingCandidats = candidats.where((candidat) => candidat.id == examen.candidatId && candidat.userId == userProvider.user?.id).toList();

                            if (matchingCandidats.isEmpty) {
                              // Handle the case when no matching candidats are found
                              return SizedBox.shrink(); // Return an empty SizedBox to hide the item
                            }

                            final Datum candidat = matchingCandidats.first;
                            return SizedBox(
                                width: 340,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),

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
                                                height: 160,
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
                                                                '${candidat.nom} ${candidat.prenom}',
                                                                style: TextStyle(
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: 'Roboto'
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 18.0,
                                                              ),
                                                              Text(
                                                                DateFormat.Hm().format(
                                                                  DateFormat('HH:mm:ss').parse(examen.heure),
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

                                                        Divider(
                                                          color: Colors.grey,
                                                        ),

                                                        Column(
                                                            children: [
                                                              Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                                                  child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                            children: [
                                                                              Text(
                                                                                'Date Examen:',
                                                                                style: TextStyle(
                                                                                    fontSize: 18,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'Roboto'
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 18.0,
                                                                              ),
                                                                              Text(
                                                                                DateFormat('yyyy-MM-dd').format(examen.date),
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'Roboto',
                                                                                    fontSize: 17,
                                                                                    color: Colors.grey
                                                                                ),
                                                                              ),
                                                                            ]
                                                                        ),
                                                                      ]
                                                                  )
                                                              ),


                                                              SizedBox(
                                                                height: 10.0,
                                                              ),

                                                              Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                                                  child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                            children: [
                                                                              Text(
                                                                                'Type:',
                                                                                style: TextStyle(
                                                                                    fontSize: 18,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'Roboto'
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 18.0,
                                                                              ),
                                                                              Text(
                                                                                examen.type,
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: 'Roboto',
                                                                                  fontSize: 17,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ]
                                                                        ),
                                                                      ]
                                                                  )
                                                              ),

                                                            ]

                                                        )
                                                      ]
                                                  )
                                              )
                                            ]
                                        )
                                    )
                                )
                            );
                          }
                      )
                  ),

                  SizedBox(
                    height: 25,
                  ),

                ]
            )
        );
      }else {
        return Center(child: Text('No data available'));
      }
    }
    )
    );
  }
}
