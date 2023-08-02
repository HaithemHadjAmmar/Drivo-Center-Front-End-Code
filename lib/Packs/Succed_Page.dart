import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:auto_ecole/Examen/prochaine_Examen.dart';
import 'package:auto_ecole/Packs/prochaine_S%C3%A9ance.dart';
import 'package:collection/collection.dart';

import 'package:auto_ecole/Examen/Ajouter_test.dart';
import 'package:auto_ecole/Examen/listeSeances.dart';
import 'package:auto_ecole/Packs/Archive_Page.dart';
import 'package:auto_ecole/Packs/User.dart';
import 'package:auto_ecole/g%C3%A9rer_Candidats/paiment/Paiment.dart';
import 'package:auto_ecole/Packs/fiche_candidat.dart';
import 'package:auto_ecole/g%C3%A9rer_Candidats/controllers/Ajouter_New_Seance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Screens/login_screen.dart';
import '../Services/globals.dart';
import '../gérer_Candidats/controllers/Candidats.dart';
import '../gérer_Candidats/controllers/Seance.dart';

import '../gérer_Candidats/controllers/listCandidats.dart';
import '../rounded_button.dart';
import '../gérer_Candidats/controllers/alert_page.dart';
import '../gérer_Candidats/paiment/Ajouter Paiement.dart';
import 'Service.dart';





class Succed_Page extends StatefulWidget {
  const Succed_Page({Key? key}) : super(key: key);

  @override
  State<Succed_Page> createState() => _Succed_PageState();
}

class _Succed_PageState extends State<Succed_Page> {

  @override
    void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NextPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: HexColor('4159A2'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.done_all_rounded,
              size: 140,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Success!!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class NextPage extends StatefulWidget {
  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  // for the alert icon
  bool hasAlert = false;

  int _selectedIndex = 0;

  late Future<Data> _userData;
  late List<Widget> _pages;

  Future<Data> getUserById(int? userId) async {
    final user = Provider
        .of<UserProvider>(context, listen: false)
        .user;
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:8000/api/select/user/${user?.id.toString()}'));
    if (response.statusCode == 200) {
      print(user?.id);
      print(response.body);
      final jsonData = json.decode(response.body);
      final data = jsonData['data'];
      final autoecole = Data.fromJson(data);
      return autoecole;
    } else {
      throw Exception('Failed to get auto école data');
    }
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      Home(),
      Liste_Paiements(),
      Profile(),
    ];
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr ?'),
        content: const Text('Voulez-vous déconnecter l\'application'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Non')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (BuildContext context) => LoginScreen())
                );
              },
              child: const Text('Oui')
          )
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final userId = user?.id;
    return WillPopScope(
        onWillPop: _onWillPop,
      child:Scaffold(
appBar: AppBar(
  title: Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto'),),
  backgroundColor: HexColor('4159A2'),
  centerTitle: true,
  actions: [
    IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AlertPage(title: '', message: '',),
          ),
        );
      },
      icon: Stack(
        children: [
          Icon(
            Icons.notifications_none,
            color: Colors.white,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasAlert ? Colors.red : Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    ),

    IconButton(
      onPressed: ()
      {
        Navigator.of(context).push(
            MaterialPageRoute(
            builder: (BuildContext context) => AjouterSeance ()));
      },
      icon: Icon(
        Icons.add,
        color: Colors.white,
      ),
    ),
  ],
),
        drawer: Drawer(

            child: AnimationLimiter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      HexColor('4159A2'),
                      HexColor('5F60FF'),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ListView(
                  children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 800),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                       UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          HexColor('4159A2'),
                          HexColor('5F60FF'),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    accountName: FutureBuilder<Data>(
                      future: getUserById(userId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data!.nomAgence,
                            style: TextStyle(fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.bold),
                          );
                        } else {
                          return Text('Loading...');
                        }
                      },
                    ),
                    accountEmail: FutureBuilder<Data>(
                      future: getUserById(userId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data!.email,
                            style: TextStyle(fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.bold),
                          );
                        } else {
                          return Text('Loading...');
                        }
                      },
                    ),
                    currentAccountPicture: CircleAvatar(
                     // backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/images/1.png'),
                    ),
                  ),

      AnimationConfiguration.staggeredList(
    position: 1,
    duration: const Duration(milliseconds: 500),
    child: ListTile(
    title: Text(
    'Gérer Candidats',
    style: TextStyle(
      fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.bold,
      fontFamily: 'Roboto'

    ),
    ),
    trailing: Icon(
    Icons.group,
    color:Colors.white
    ),
    onTap: () => Navigator.of(context).push(
    MaterialPageRoute(
    builder: (BuildContext context) => ListCandidats(),
    ),
    ),
    ),
    ),

                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),

      ListTile(
        title: Text(
          'Ajouter Examen',
          style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto'

          ),
        ),
        trailing: Icon(
          Icons.edit_calendar,
          color: Colors.white,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => Ajouter_Test(),
          ),
        ),
      ),

                        ListTile(
                          title: Text(
                            'Ajouter Paiement',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto'

                            ),
                          ),
                          trailing: Icon(
                            Icons.edit_calendar,
                            color: Colors.white,
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => Ajouter_Paiement(candidatId: 1,)
                            ),
                          ),
                        ),

                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
      ListTile(
        title: Text(
          'Liste Examen',
          style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto'

          ),
        ),
        trailing: Icon(
          Icons.list_alt,
          color: Colors.white,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => Liste_Examens(),
          ),
        ),
      ),
                      Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      ListTile(
                        title: Text(
                          'Prochaines Séances',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto'

                          ),
                        ),
                        trailing: Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => prochaine_Seance(),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Prochaines Examens',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto'

                          ),
                        ),
                        trailing: Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => prochaine_Examen(),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                        ListTile(
                          title: Text(
                            'Déconnexion',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto'

                            ),
                          ),
                          trailing: Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        onTap: ()
                        {
// function deconnexion
                        },
                        ),
    ],
    ),
    ),
    ),
    )
      ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: HexColor('4159A2'),
          buttonBackgroundColor: HexColor('4159A2'),
          height: 55,
          items: <Widget>[
            Icon(Icons.home, size: 30, color: Colors.white),
            Icon(Icons.monetization_on_outlined, size: 30, color: Colors.white),
            Icon(Icons.person, size: 30, color: Colors.white),
          ],
          index: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
        },
      ),
    ),
    );
  }
}



           //    ** class Home **
class Home extends StatefulWidget {

  const Home({Key? key,}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin{

  late Future<List<Seance>> _futureSeances;
  late Future<List<Seance>> _futureallSeances;
  late Future<List<Datum>> _futureCandidat;
  late Future <List<Seance>> _futureProchaineSeance;

  List<Seance> codeSeances = [];
  List<Seance> conduiteSeances = [];


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
    _futureSeances = getSeances();
    _futureCandidat = getCandidats();
    _futureallSeances = getallSeances();

  }

  // get the seances where date > date d'aujourd'hui and whe user_id == user.id for the prochaine séance
  Future<List<Seance>> getProchaineSeances() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/candidats/prochaines/seances/${user?.id}'));
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
// get prochain séance pour chaque candidat by ID



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


// get the seances where date == date d'aujourd'hui and whe user_id == user.id
  Future<List<Seance>> getSeances() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/candidats/seances/${user?.id}'));
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

  //get all Seances
  Future<List<Seance>> getallSeances() async {
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;

    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([getSeances(), getCandidats(), getProchaineSeances()]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final List<Seance> seances = snapshot.data[0].cast<Seance>();
            final List<Datum> candidats = snapshot.data[1].cast<Datum>();
            final List<Seance> Pseance = snapshot.data[2].cast<Seance>();

            return SingleChildScrollView(
            child: Column(
                children: [
            Padding(
            padding: const EdgeInsets.all(8.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
          children: [
            Text('Bienvenue', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
          ],
          ),
          SizedBox(height: 8),
          Row(
          children: [
          Text(DateFormat.yMMMMd().format(DateTime.now()), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),

            SizedBox(width: 145,),

            IconButton(
                onPressed: ()
                {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>  Archive(),
                      ));
                },
                icon: Icon(Icons.history, size: 35, color: HexColor('4159A2'),)
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
    children:[
      Row(
     children: [
       Text(
         'Liste Séances Conduite:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
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
    height: 200,
       child: ListView.builder(
           scrollDirection: Axis.horizontal,
           itemCount: seances.where((s) => s.type == "conduite").toList().length,
           itemBuilder: (BuildContext context, int index) {
             final Seance seance = seances.where((s) => s.type == "conduite").toList()[index];

             DateTime today = DateTime.now();
             DateTime nextSeanceDate;


             final List<Datum> matchingCandidats = candidats.where((candidat) => candidat.id == seance.candidatId && candidat.userId == userProvider.user?.id).toList();

             if (matchingCandidats.isEmpty) {
               // Handle the case when no matching candidats are found
               return SizedBox.shrink(); // Return an empty SizedBox to hide the item
             }

             final Datum candidat = matchingCandidats.first;
        return SizedBox(
          width: 345,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            fiche_Candidat(
                              nom: candidat.nom,
                              prenom: candidat.prenom,
                              nbHt: candidat.nbrHeureTotal,
                              nbHtC: candidat.nbrHeureTotalCode,
                              nbHtP: candidat.nbrHeureTotalPark,
                              heure_Debut: seance.heureDebut,
                              nbr_Heure: seance.nbrHeure,
                              type: seance.type,
                              date: seance.date,
                              id: seance.candidatId,
                              seances: [seance],
                              data: [candidat],
                            ),
                      ),
                    );
                  },
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
                                color: _isSeanceActive(seance) ? HexColor(
                                    '00D43B') : (_seanceEnded(seance)
                                    ? HexColor('4159A2')
                                    : HexColor('B5B5B5')),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(35),
                                  bottomLeft: Radius.circular(35),
                                ),
                              ),
                              height: 200,
                            ),
                            SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: [
                                    Row(
                                        children: [
                                          Text(
                                            '${candidat.nom} ${candidat
                                                .prenom}',
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
                                              DateFormat('HH:mm:ss').parse(
                                                  seance.heureDebut),
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
                                          Row(
                                            children: [
                                              Text('${seance
                                                  .nbrHeure} heure',
                                                style: TextStyle(
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    fontFamily: 'Roboto',
                                                    fontSize: 17),
                                              ),

                                              SizedBox(
                                                  width: 20.0
                                              ),

                                              if (_isSeanceActive(seance))
                                                Positioned(
                                                  left: 0,
                                                  top: 90,
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: HexColor(
                                                          '00D43B'),
                                                      shape: BoxShape
                                                          .circle,
                                                    ),
                                                  ),
                                                )
                                              else
                                                if (_seanceEnded(seance))
                                                  Positioned(
                                                    left: 0,
                                                    top: 90,
                                                    child: Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: HexColor(
                                                            '4159A2'),
                                                        shape: BoxShape
                                                            .circle,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Positioned(
                                                    left: 0,
                                                    top: 90,
                                                    child: Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: HexColor(
                                                            'B5B5B5'),
                                                        shape: BoxShape
                                                            .circle,
                                                      ),
                                                    ),
                                                  ),
                                              SizedBox(width: 8),
                                              Text(
                                                _isSeanceActive(seance)
                                                    ? "Maintenant"
                                                    : _seanceEnded(seance)
                                                    ? "Terminé"
                                                    : "Prochaine",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    fontFamily: 'Roboto'),
                                              ),
                                            ],
                                          ),
                                        ]),

                                    Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),

                                    Text('Prochaine Séance:', style:
                                    TextStyle(fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto'),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    // Get the next session date
                                    Text(
                                      seance.date != null
                                          ? DateFormat('yyyy-MM-dd').format(seance.date)
                                          : 'Aucune séance programmée',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),
                                    Text(seance.type, style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto'
                                    ),
                                    ),
                                  ]
                              ),
                            )
                          ]
                      )
                  )
              )
          ),
        );
      }

    ),
    ),


                  // liste Séances conduite
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Row(
                              children: [
                                Text(
                                  'Liste Séances Park:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
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
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: seances.where((s) => s.type == "park").toList().length,
                        itemBuilder: (BuildContext context, int index) {
                          final Seance seance = seances.where((s) => s.type == "park").toList()[index];

                          final List<Datum> matchingCandidats = candidats.where((candidat) => candidat.id == seance.candidatId && candidat.userId == userProvider.user?.id).toList();

                          if (matchingCandidats.isEmpty) {
                            // Handle the case when no matching candidats are found
                            return SizedBox.shrink(); // Return an empty SizedBox to hide the item
                          }

                          final Datum candidat = matchingCandidats.first;
                          return SizedBox(
                              width: 345,
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                fiche_Candidat(
                                                  nom: candidat.nom,
                                                  prenom: candidat.prenom,
                                                  heure_Debut: seance.heureDebut,
                                                  nbHt: candidat.nbrHeureTotal,
                                                  nbHtC: candidat.nbrHeureTotalCode,
                                                  nbHtP: candidat.nbrHeureTotalPark,
                                                  nbr_Heure: seance.nbrHeure,
                                                  type: seance.type,
                                                  id: seance.candidatId,
                                                  date: seance.date,
                                                  seances: [seance],
                                                  data: [candidat],
                                                ),
                                          ),
                                        );
                                      },
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
                                                    color: _isSeanceActive(
                                                        seance)
                                                        ? HexColor('00D43B')
                                                        : (_seanceEnded(seance)
                                                        ? HexColor('4159A2')
                                                        : HexColor('B5B5B5')),
                                                    borderRadius: BorderRadius
                                                        .only(
                                                      topLeft: Radius.circular(
                                                          35),
                                                      bottomLeft: Radius
                                                          .circular(35),
                                                    ),
                                                  ),
                                                  height: 200,
                                                ),
                                                SizedBox(width: 8),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      8.0),
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Row(
                                                            children: [
                                                              Text(
                                                                '${candidat
                                                                    .nom} ${candidat
                                                                    .prenom}',
                                                                style: TextStyle(
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    fontFamily: 'Roboto'
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 18.0,
                                                              ),
                                                              Text(
                                                                DateFormat.Hm()
                                                                    .format(
                                                                  DateFormat(
                                                                      'HH:mm:ss')
                                                                      .parse(
                                                                      seance
                                                                          .heureDebut),
                                                                ),
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontFamily: 'Roboto',
                                                                  fontSize: 18,
                                                                ),
                                                                textAlign: TextAlign
                                                                    .center,
                                                              ),
                                                            ]
                                                        ),

                                                        Divider(
                                                          color: Colors.grey,
                                                        ),

                                                        Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text('${seance
                                                                      .nbrHeure} heure',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        fontFamily: 'Roboto',
                                                                        fontSize: 17),
                                                                  ),

                                                                  SizedBox(
                                                                      width: 20.0
                                                                  ),

                                                                  if (_isSeanceActive(
                                                                      seance))
                                                                    Positioned(
                                                                      left: 0,
                                                                      top: 90,
                                                                      child: Container(
                                                                        width: 10,
                                                                        height: 10,
                                                                        decoration: BoxDecoration(
                                                                          color: HexColor(
                                                                              '00D43B'),
                                                                          shape: BoxShape
                                                                              .circle,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  else
                                                                    if (_seanceEnded(
                                                                        seance))
                                                                      Positioned(
                                                                        left: 0,
                                                                        top: 90,
                                                                        child: Container(
                                                                          width: 10,
                                                                          height: 10,
                                                                          decoration: BoxDecoration(
                                                                            color: HexColor(
                                                                                '4159A2'),
                                                                            shape: BoxShape
                                                                                .circle,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    else
                                                                      Positioned(
                                                                        left: 0,
                                                                        top: 90,
                                                                        child: Container(
                                                                          width: 10,
                                                                          height: 10,
                                                                          decoration: BoxDecoration(
                                                                            color: HexColor(
                                                                                'B5B5B5'),
                                                                            shape: BoxShape
                                                                                .circle,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                    _isSeanceActive(
                                                                        seance)
                                                                        ? "Maintenant"
                                                                        : _seanceEnded(
                                                                        seance)
                                                                        ? "Terminé"
                                                                        : "Prochaine",
                                                                    style: TextStyle(
                                                                        fontSize: 16,
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        fontFamily: 'Roboto'),
                                                                  ),
                                                                ],
                                                              ),
                                                            ]),

                                                        Divider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                        ),
                                                        Text(
                                                          'Prochaine Séance:',
                                                          style:
                                                          TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight
                                                                  .bold,
                                                              fontFamily: 'Roboto'),
                                                        ),
                                                        SizedBox(
                                                          height: 8.0,
                                                        ),
                                                        // Get the next session date
                                                        Text(
                                                          DateFormat('yyyy-MM-dd').format(
                                                            DateFormat('yyyy-MM-dd').parse(
                                                              '${seance.date}',
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            fontFamily: 'Roboto',
                                                            fontSize: 18,
                                                          ),
                                                          textAlign: TextAlign
                                                              .center,
                                                        ),

                                                        Divider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                        ),
                                                        Text(seance.type,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight
                                                                  .bold,
                                                              fontFamily: 'Roboto'
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                )
                                              ]
                                          )
                                      )
                                  )
                              )
                          );

                      }
                      ),
                  ),

                  // liste Séances conduite
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Row(
                              children: [
                                Text(
                                  'Liste Séances Code:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
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
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: seances.where((s) => s.type == "code").toList().length,
                        itemBuilder: (BuildContext context, int index) {
                          final Seance seance = seances.where((s) => s.type == "code").toList()[index];

                          final List<Datum> matchingCandidats = candidats.where((candidat) => candidat.id == seance.candidatId && candidat.userId == userProvider.user?.id).toList();

                          if (matchingCandidats.isEmpty) {
                            // Handle the case when no matching candidats are found
                            return SizedBox.shrink(); // Return an empty SizedBox to hide the item
                          }


                          final Datum candidat = matchingCandidats.first;

                          return SizedBox(
                              width: 345,
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                fiche_Candidat(
                                                  nom: candidat.nom,
                                                  prenom: candidat.prenom,
                                                  heure_Debut: seance.heureDebut,
                                                  nbHt: candidat.nbrHeureTotal,
                                                  nbHtC: candidat.nbrHeureTotalCode,
                                                  nbHtP: candidat.nbrHeureTotalPark,
                                                  nbr_Heure: seance.nbrHeure,
                                                  type: seance.type,
                                                  id: seance.candidatId,
                                                  date: seance.date,
                                                  seances: [seance],
                                                  data: [candidat],
                                                ),
                                          ),
                                        );
                                      },
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
                                                    color: _isSeanceActive(
                                                        seance)
                                                        ? HexColor('00D43B')
                                                        : (_seanceEnded(seance)
                                                        ? HexColor('4159A2')
                                                        : HexColor('B5B5B5')),
                                                    borderRadius: BorderRadius
                                                        .only(
                                                      topLeft: Radius.circular(
                                                          35),
                                                      bottomLeft: Radius
                                                          .circular(35),
                                                    ),
                                                  ),
                                                  height: 200,
                                                ),
                                                SizedBox(width: 8),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      8.0),
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Row(
                                                            children: [
                                                              Text(
                                                                '${candidat
                                                                    .nom} ${candidat
                                                                    .prenom}',
                                                                style: TextStyle(
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    fontFamily: 'Roboto'
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 18.0,
                                                              ),
                                                              Text(
                                                                DateFormat.Hm()
                                                                    .format(
                                                                  DateFormat(
                                                                      'HH:mm:ss')
                                                                      .parse(
                                                                      seance
                                                                          .heureDebut),
                                                                ),
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontFamily: 'Roboto',
                                                                  fontSize: 18,
                                                                ),
                                                                textAlign: TextAlign
                                                                    .center,
                                                              ),
                                                            ]
                                                        ),

                                                        Divider(
                                                          color: Colors.grey,
                                                        ),

                                                        Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text('${seance
                                                                      .nbrHeure} heure',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        fontFamily: 'Roboto',
                                                                        fontSize: 17),
                                                                  ),

                                                                  SizedBox(
                                                                      width: 20.0
                                                                  ),

                                                                  if (_isSeanceActive(
                                                                      seance))
                                                                    Positioned(
                                                                      left: 0,
                                                                      top: 90,
                                                                      child: Container(
                                                                        width: 10,
                                                                        height: 10,
                                                                        decoration: BoxDecoration(
                                                                          color: HexColor(
                                                                              '00D43B'),
                                                                          shape: BoxShape
                                                                              .circle,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  else
                                                                    if (_seanceEnded(
                                                                        seance))
                                                                      Positioned(
                                                                        left: 0,
                                                                        top: 90,
                                                                        child: Container(
                                                                          width: 10,
                                                                          height: 10,
                                                                          decoration: BoxDecoration(
                                                                            color: HexColor(
                                                                                '4159A2'),
                                                                            shape: BoxShape
                                                                                .circle,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    else
                                                                      Positioned(
                                                                        left: 0,
                                                                        top: 90,
                                                                        child: Container(
                                                                          width: 10,
                                                                          height: 10,
                                                                          decoration: BoxDecoration(
                                                                            color: HexColor(
                                                                                'B5B5B5'),
                                                                            shape: BoxShape
                                                                                .circle,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                    _isSeanceActive(
                                                                        seance)
                                                                        ? "Maintenant"
                                                                        : _seanceEnded(
                                                                        seance)
                                                                        ? "Terminé"
                                                                        : "Prochaine",
                                                                    style: TextStyle(
                                                                        fontSize: 16,
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        fontFamily: 'Roboto'),
                                                                  ),
                                                                ],
                                                              ),
                                                            ]),

                                                        Divider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                        ),
                                                        Text(
                                                          'Prochaine Séance:',
                                                          style:
                                                          TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight
                                                                  .bold,
                                                              fontFamily: 'Roboto'),
                                                        ),
                                                        SizedBox(
                                                          height: 8.0,
                                                        ),
                                                        // Get the next session date
                                                        Text(
                                                          DateFormat('yyyy-MM-dd').format(
                                                            DateFormat('yyyy-MM-dd').parse(
                                                              '${seance.date}',
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            fontFamily: 'Roboto',
                                                            fontSize: 18,
                                                          ),
                                                          textAlign: TextAlign
                                                              .center,
                                                        ),

                                                        Divider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                        ),
                                                        Text(seance.type,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight
                                                                  .bold,
                                                              fontFamily: 'Roboto'
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                )
                                              ]
                                          )
                                      )
                                  )
                              )
                          );

                      }
                      ),
                  ),
                  SizedBox(
                    height: 25,
                  ),


                ]
            )
            );
    } else {
    return Center(child: Text('No data available'));
    }
    },
    ),
    );
  }
}
//     ** fin du class Home **








//class ListePaiement 
class Liste_Paiements extends StatefulWidget {
  const Liste_Paiements({Key? key}) : super(key: key);

  @override
  State<Liste_Paiements> createState() => _Liste_PaiementsState();
}

class _Liste_PaiementsState extends State<Liste_Paiements> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';

  late Future<List<Paiement>> _futurPaiement;
  late Future<List<Datum>> _futureCandidat;

  Future<void> _performSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _futurPaiement = recherchePaiement(_searchQuery);
    });
  }

  // get the paiements where  user_id == user.id
  Future<List<Paiement>> getPaiement() async {
    final user = Provider
        .of<UserProvider>(context, listen: false)
        .user;
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:8000/api/candidats/select/paiement/${user?.id}'));
    if (response.statusCode == 200) {
      print(user?.id);
      print(response.body);
      final jsonData = json.decode(response.body);
      final paiements = <Paiement>[];
      for (var item in jsonData) {
        paiements.add(Paiement.fromJson(item));
      }
      return paiements;
    } else {
      throw Exception('Failed to get seances');
    }
  }

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

  Future<List<Paiement>> recherchePaiement(String query) async {
    try {
      final user = Provider
          .of<UserProvider>(context, listen: false)
          .user;
      final userId = user?.id; // Assuming the user object has an "id" property

      final response = await http.get(
          Uri.parse(
              'http://10.0.2.2:8000/api/recherche/examens/$userId?query=$query'));

      if (response.statusCode == 200) {
        dynamic decodedData = jsonDecode(response.body);
        if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('data')) {
          final List<dynamic> dataList = decodedData['data'];
          final List<Paiement> paiements = dataList.map((e) =>
              Paiement.fromJson(e)).toList();
          return paiements;
        } else {
          throw Exception('Failed to load Paiments');
        }
      } else {
        throw Exception('Failed to load seances');
      }
    } catch (e) {
      print('Error fetching seances: $e');
      throw Exception('Failed to load seances');
    }
  }


  @override
  void initState() {
    _futurPaiement = getPaiement();
    _futureCandidat = getCandidats();
    _futurPaiement = recherchePaiement(_searchQuery);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: SingleChildScrollView(
            child: FutureBuilder<List<dynamic>>(
                future: Future.wait<List<dynamic>>(
                    [getPaiement(), getCandidats()]),
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData &&
                      snapshot.data![0].isNotEmpty &&
                      snapshot.data![1].isNotEmpty) {
                    final List<Paiement> paiements = snapshot.data![0].cast<
                        Paiement>();
                    final List<Datum> candidats = snapshot.data![1].cast<
                        Datum>();


    Map<String, Map<String,
    List<Datum>>> candidatesByDateAndTypeAndId = {};

    for (Paiement paiement in paiements) {
    final String key = '${paiement.datePaiement}';
    final List<Datum> candidatesForSeance = candidats
        .where((candidat) => candidat.id == paiement.candidatId)
        .toList();

    if (candidatesByDateAndTypeAndId.containsKey(key)) {
    final Map<String, List<Datum>> candidatesById =
    candidatesByDateAndTypeAndId[key]!;

    if (candidatesById.containsKey(
    paiement.candidatId.toString())) {
    candidatesById[paiement.candidatId.toString()]!
        .addAll(candidatesForSeance);
    } else {
    candidatesById[paiement.candidatId.toString()] =
    candidatesForSeance;
    }
    } else {
    candidatesByDateAndTypeAndId[key] = {
    paiement.candidatId.toString(): candidatesForSeance
    };
    }
    }
    return Column(
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
                _futurPaiement = recherchePaiement(value);
              });
            },
          ),
        ),
        ...candidatesByDateAndTypeAndId.entries.map((entry) => Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat.yMMMMd().format(DateTime.parse(entry.key)),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
            ...entry.value.entries.map((subEntry) => Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: subEntry.value.length,
                  itemBuilder: (BuildContext context, int index) {
                    final candidate = subEntry.value[index];
                    final Paiement paiement = paiements[index];
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
                                      color: HexColor('#e6b400'),
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
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            SizedBox(width: 20.0),
                                            Text(
                                              '${paiement.montant}dt',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                                color: paiement.montant > 0 ? Colors.green : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.0),
                                        Row(
                                          children: [
                                            Text(
                                              DateFormat('yyyy-MM-dd').format(paiement.datePaiement),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                                fontSize: 17,
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
                                                  color: HexColor('#e6b400'),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Text(
                                              'Montant Total: ${candidate.avance} dt',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                                fontSize: 17,
                                              ),
                                            ),
                                          ],
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
                    );
                  },
                ),
              ],
            )),
          ],
        )).toList(),
      ],
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








//modifier compte utilisateur
class Profile extends StatefulWidget {


  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late ImageProvider<Object> _image = AssetImage('assets/images/default_profile.png');

  late Future<Data> _userData;
  late TextEditingController _nomAgenceController;
  late TextEditingController _codeAgenceController;
  late TextEditingController _adresseuserController;
  late TextEditingController _numTelController;
  late TextEditingController _matriFiscController;
  late TextEditingController _emailController;



  Future<Data> getUserById() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/select/user/${user?.id.toString()}'));
    if (response.statusCode == 200) {
      print(user?.id);
      print(response.body);
      final jsonData = json.decode(response.body);
      final data = jsonData['data'];
      final autoecole = Data.fromJson(data);
      return autoecole;
    } else {
      throw Exception('Failed to get auto école data');
    }
  }



  void _updateUser() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final userId = user?.id;
    print('Updating user...');
    bool emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text);
    if (emailValid) {
      final dbHelper = UserServices();
      final updatedUser = Data(
        id: userId ?? 0!,
        nomAgence: _nomAgenceController.text,
        codeAgence: _codeAgenceController.text,
        email: _emailController.text,
        adresse: _adresseuserController.text,
        numTel: _numTelController.text!,
        matriFisc: _matriFiscController.text!,
      );

      final http.Response response = (await UserServices.updateUserById(

        user?.id ?? 0,
        _nomAgenceController.text,
        _codeAgenceController.text,
        _emailController.text,
        _adresseuserController.text,
        _numTelController.text,
        _matriFiscController.text,
      )) as http.Response;


      if (response.statusCode == 200) {
        final rowsUpdated = int.parse(response.body);
        if (rowsUpdated > 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => NextPage(),
            ),
          );
        } else {
          errorSnackBar(context, 'Error updating user');
        }
      } else {
        errorSnackBar(context, 'Error updating user');
      }
    } else {
      errorSnackBar(context, 'E-mail non valid');
    }
  }

  @override
  void initState() {
    super.initState();
    _userData = getUserById();
    _nomAgenceController = TextEditingController();
    _codeAgenceController = TextEditingController();
    _emailController = TextEditingController();
    _adresseuserController = TextEditingController();
    _matriFiscController = TextEditingController();
    _numTelController = TextEditingController();
  }

  @override
  void dispose() {
    _nomAgenceController.dispose();
    _codeAgenceController.dispose();
    _emailController.dispose();
    _adresseuserController.dispose();
    _numTelController.dispose();
    _matriFiscController.dispose();
    super.dispose();
  }

  //for the image of profile
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path) as ImageProvider<Object>;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<Data>(
          future: _userData,
          builder: (BuildContext context, AsyncSnapshot<Data> snapshot) {
            if (snapshot.hasData) {
              _nomAgenceController.text = snapshot.data!.nomAgence;
              _codeAgenceController.text = snapshot.data!.codeAgence.toString();
              _adresseuserController.text = snapshot.data!.adresse;
              _emailController.text = snapshot.data!.email;
              _matriFiscController.text = snapshot.data!.matriFisc.toString();
              _numTelController.text = snapshot.data!.numTel.toString();
              return SingleChildScrollView(
                  child: Container(
                      alignment: Alignment.topCenter,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 40),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                   backgroundImage: AssetImage('assets/images/1.png'),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 30,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                            SingleChildScrollView(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                              suffixIcon: Icon(Icons.person),
                                              labelText: 'Nom Agence',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                              )
                                          ),
                                          controller: _nomAgenceController,
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                              suffixIcon: Icon(Icons.security),
                                              labelText: 'Code Agence',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                              )
                                          ),
                                          controller: _codeAgenceController,
                                          enabled: false,
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        TextField(
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
                                              suffixIcon: Icon(Icons.maps_home_work_outlined),
                                              labelText: 'Adresse',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                              )
                                          ),
                                          controller: _adresseuserController,
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                              suffixIcon: Icon(Icons.info_outline),
                                              labelText: 'Matricule Fiscale',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                              )
                                          ),
                                          controller: _matriFiscController,
                                          enabled: false, // add this line to disable the TextField
                                        ),
                                        SizedBox(
                                          height:15,
                                        ),
                                        TextField(
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
                                          height: 25,
                                        ),
                                        RoundedButton(
                                          btnText: 'Mettre a jour ',
                                          onBtnPressed: () => _updateUser(),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    )
                                )
                            )]
                      )
                  )
              );
            } else if (snapshot.hasError) {
              return Text('Error fetching user data: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}