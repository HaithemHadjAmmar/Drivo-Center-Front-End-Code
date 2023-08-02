import 'dart:convert';

import 'package:auto_ecole/Examen/Ajouter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Examen/Examen.dart';
import '../Screens/login_screen.dart';
import '../gérer_Candidats/controllers/Ajouter_New_Seance.dart';
import '../gérer_Candidats/controllers/Candidats.dart';
import '../gérer_Candidats/controllers/Seance.dart';
import 'Succed_Page.dart';

class fiche_Candidat extends StatefulWidget {
  final String nom;
  final String prenom;
  final String heure_Debut;
  final int nbr_Heure;
  final String type;
  final int nbHt;
  final int nbHtC;
  final int nbHtP;
  final int id;
  final DateTime date;
  final List<Seance> seances;
  final List<Datum> data;

  const fiche_Candidat({
    Key? key,
    required this.nom,
    required this.prenom,
    required this.heure_Debut,
    required this.nbr_Heure,
    required this.type,
    required this.id,
    required this.nbHt,
    required this.nbHtC,
    required this.nbHtP,
    required this.date,
    required this.seances,
    required this.data,


  }) : super(key: key);

  @override
  State<fiche_Candidat> createState() => _fiche_CandidatState();
}

class _fiche_CandidatState extends State<fiche_Candidat> with SingleTickerProviderStateMixin{

  late AnimationController _controller;
  late Animation<AlignmentGeometry> _animation;
  late Animation<double> _growAnimation;

  late Future<List<Seance>> _futureSeances;
  late Future<List<Datum>> _futureCandidat;

  bool _isSeanceActive(Seance seance) {
    DateTime debut = DateTime.parse(DateTime.now().toString().substring(0, 10) + " " + seance.heureDebut);
    Duration duree = Duration(hours: seance.nbrHeure);
    DateTime fin = debut.add(duree);

    if (DateTime.now().isBefore(debut)) {
      return false;
    } else if (DateTime.now().isBefore(fin)) {
      return true;
    } else {
      return false;
    }
  }

  bool _seanceEnded(Seance seance) {
    DateTime debut = DateTime.parse(DateTime.now().toString().substring(0, 10) + " " + seance.heureDebut);
    Duration duree = Duration(hours: seance.nbrHeure);

    if (DateTime.now().isAfter(debut.add(duree))) {
      return true;
    } else {
      return false;
    }
  }


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<AlignmentGeometry>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(_controller);

    _growAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _controller.forward();

    _futureSeances = getSeances();
    _futureCandidat = getCandidats();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  //get all Seances
  Future<List<Seance>> getSeances() async {
    try {
      final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/candidats/seances4f'));
      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        if (decodedData is List<dynamic> && decodedData.isNotEmpty) {
          final List<Seance> seances = decodedData.map((x) =>
              Seance.fromJson(x)).toList();
          return seances;
        } else {
          throw Exception('Seances not found');
        }
      } else {
        throw Exception('Failed to load Seances');
      }
    } catch (e) {
      print('Error fetching Seances: $e');
      throw Exception('Il n\'y a aucune séance aujourd\'hui.');
    }
  }

// select the exams by candidatId where exames = exams of today
  Future<List<Examen>> getExamens({required int? candidatId}) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/get/all/exams/$candidatId'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final examens = <Examen>[];
      for (var item in jsonData) {
        examens.add(Examen.fromJson(item));
      }
      return examens;
    } else if (response.statusCode == 204) {
      // No data available, return an empty list
      return [];
    } else {
      throw Exception('Failed to get examens');
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Fiche Candidat',  style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: HexColor('4159A2')
          ),),
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),color: HexColor('4159A2'),
            onPressed: ()
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>  NextPage(),
                  ));
            },
          ),
        ),

        body: FutureBuilder<List<dynamic>>(
            future: Future.wait<List<dynamic>>([_futureSeances, getCandidats(), getExamens(candidatId: widget.id)]),
            builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data![0].isNotEmpty && snapshot.data![1].isNotEmpty) {
                final List<Seance> seances = snapshot.data![0].cast<Seance>();
                final List<Datum> candidats = snapshot.data![1].cast<Datum>();
                final List<Examen> examens = snapshot.data![2].cast<Examen>();

    return Column(
    children: [
    Expanded(
    child: ListView.builder(
      itemCount:1,
      itemBuilder: (BuildContext context, int index) {
        final List<Seance> filteredSeances = [
          ...seances.where((seance) => seance.type == "code" && seance.candidatId == widget.id),
          ...seances.where((seance) => seance.type == "conduite" && seance.candidatId  == widget.id),
          ...seances.where((seance) => seance.type == "park" && seance.candidatId  == widget.id),
        ];
        final Examen examen = examens[index];

        final Seance seance = filteredSeances[index];

        final int nbrHeureCode = filteredSeances
            .where((seance) => seance.type == "code" && seance.candidatId == widget.id)
            .fold(0, (sum, seance) => sum + seance.nbrHeure);

        final int nbrHeureConduite = filteredSeances
            .where((seance) => seance.type == "conduite" && seance.candidatId== widget.id)
            .fold(0, (sum, seance) => sum + seance.nbrHeure);

        final int nbrHeurePark = filteredSeances
            .where((seance) => seance.type == "park" && seance.candidatId== widget.id)
            .fold(0, (sum, seance) => sum + seance.nbrHeure);


        final Datum candidat = candidats.firstWhere(
              (candidat) => candidat.id == seance.candidatId,
        );

    return SingleChildScrollView(
    child: AnimationConfiguration.staggeredList(
    position: index,
    duration: const Duration(milliseconds: 800),
    child: SlideAnimation(
    //verticalOffset: 50.0,
    child: FadeInAnimation(
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Stack(
    alignment: Alignment.center,
    children: <Widget>[
    AnimatedBuilder(
    animation: _growAnimation,
    builder: (BuildContext context, Widget? child) {
    return AnimatedContainer(
    height: 630 * _growAnimation.value,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(35),
    color: HexColor('DDF6DF'),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    spreadRadius: 3,
    blurRadius: 7,
    offset: Offset(0, 3),
    ),
    ],
    ),
    );
    },
    ),
    Positioned(
    right: 0,
    bottom: 0,
    top: 10,
    child: CustomPaint(
    size: Size(100, 150),
    ),
    ),
    Positioned.fill(
    child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Row(
    children: <Widget>[
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    '${widget.nom} ${widget.prenom}',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto'
    ),
    ),
    SizedBox(width: 22.0),
    Text(
    DateFormat.Hm().format(
    DateFormat('HH:mm:ss').parse(widget.heure_Debut),
    ),
    style: TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    fontSize: 18,
    ),
    textAlign: TextAlign.center,
    ),
    ],
    ),
    SizedBox(
    height: 6.0
    ),
        Expanded(
        child: Column(
        children: [
        Padding(
        padding: EdgeInsets.only(left: 65),
        child: Row(
        children: [
        Icon(Icons.alarm, size: 20, color: Colors.grey),
        SizedBox(width: 10),
        Text(
        '${widget.nbr_Heure} heure',
        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 17),
        ),
        ],
        ),
        ),
        SizedBox(height: 8.0),
        Divider(
        thickness: 2,
        color: Colors.grey,
        indent: 16,
        endIndent: 16,
        ),
        Text(
        'Nombre d\'heures de conduite',
        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 18),
        ),
        SizedBox(height: 8.0),
        Padding(
        padding: EdgeInsets.only(left: 65.0),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
        '${nbrHeureConduite}/${widget.nbHt}',
        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 17),
        ),
        ],
        ),
        ),
        SizedBox(height: 8.0),
        ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
        width: 237,
        height: 9,
        child: LinearProgressIndicator(
        value: nbrHeureConduite / 20,
        backgroundColor: HexColor('F3F4F5'),
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60FC00)),
        ),
        ),
        ),
        SizedBox(height: 8.0),
          Padding(
            padding: EdgeInsets.only(left: 65.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date de l\'examen:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                ),
                SizedBox(width: 1.0),
                if (examen.type == "conduite")
                  examen.date != null
                      ? Text(
                    "${examen.date.year}-${examen.date.month.toString().padLeft(2, '0')}-${examen.date.day.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                  )
                      : Text(
                    "Vous n'avez aucun examen de conduite",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                  ),
              ],
            ),
          ),


          SizedBox(height: 8.0),
        Divider(
        thickness: 2,
        color: Colors.grey,
        indent: 16,
        endIndent: 16,
        ),
        Text(
        'Nombre d\'heures de code',
        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 18),
        ),
        SizedBox(height: 8.0),
        Padding(
        padding: EdgeInsets.only(left: 65.0),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
        '${nbrHeureCode}/${widget.nbHtC}',
        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 17),
        ),
        ],
        ),
        ),
        SizedBox(height: 8.0),
        ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
        width: 237,
        height: 9,
        child: LinearProgressIndicator(
        value: nbrHeureCode / 20,
        backgroundColor: HexColor('F3F4F5'),
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60FC00)),
        ),
        ),
        ),
        SizedBox(height: 8.0),
          Padding(
            padding: EdgeInsets.only(left: 65.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date de l\'examen:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                ),
                SizedBox(width: 1.0),
                if (examen.type == "code")
                  examen.date != null
                      ? Text(
                    "${examen.date.year}-${examen.date.month.toString().padLeft(2, '0')}-${examen.date.day.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                  )
                      : Text(
                    "Vous n'avez aucun examen de conduite",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                  ),
              ],
            ),
          ),

          SizedBox(
            height: 8.0,
          ),
          Divider(
            thickness: 2,
            color: Colors.grey,
            indent: 16,
            endIndent: 16,
          ),
          Text(
            'Nombre d\'heures de park',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 18),
          ),
          SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 65.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${nbrHeurePark}/${widget.nbHtP}',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 17),),
                ]
            ),
          ),
          SizedBox(
            height: 8.0,
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 237,
              height: 9,
              child: LinearProgressIndicator(
                value: nbrHeurePark / 20,
                backgroundColor: HexColor('F3F4F5'),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60FC00)),
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 65.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date de l\'examen:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                ),
                SizedBox(width: 1.0),
                if (examen.type == "park")
                  examen.date != null
                      ? Text(
                    "${examen.date.year}-${examen.date.month.toString().padLeft(2, '0')}-${examen.date.day.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                  )
                      : Text(
                    "Vous n'avez aucun examen de conduite",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                  ),
              ],
            ),
          ),

        ],
    ),
    ),
    ],
    )
    )
    ]
    ),
    ),
    ),
    ]
    ),
    )
    )
    )
        )
    );
    },
    ),
    ),
    ]);
    }else {
      return Center(
        child: Text(''),
      );
    }
    }
    )

    );
      }
      }


