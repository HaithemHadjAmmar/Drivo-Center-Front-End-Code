import 'package:auto_ecole/g%C3%A9rer_Candidats/controllers/Candidats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';


class Details_candidats extends StatefulWidget {

  final String nom;
  final String prenom;
  final String cin;
  final int numTel;
  final String email;
  final String adresse;
  final String px_h;
  final String px_h_c;
  final String px_h_P;
  final int id;
  final DateTime d_n;
  final String avance;
  final int nbHT;
  final int nbHtC;
  final int nbHtP;
  final Datum data;
  const Details_candidats({Key? key,
    required this.nom,
    required this.prenom,
    required this.cin,
    required this.numTel,
    required this.email,
    required this.adresse,
    required this.px_h,
    required this.px_h_c,
    required this.px_h_P,
    required this.id,
    required this.d_n,
    required this.avance,
    required this.data,
    required this.nbHT,
    required this.nbHtC,
    required this.nbHtP,
  }) : super(key: key);



  @override
  State<Details_candidats> createState() => _Details_candidatsState();
}

class _Details_candidatsState extends State<Details_candidats> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<AlignmentGeometry> _animation;
  late Animation<double> _growAnimation;

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

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informations de ${widget.nom} ${widget.prenom}', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: HexColor('4159A2')),),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),color: HexColor('4159A2'),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
    itemCount:1,
    itemBuilder: (BuildContext context, int index) {
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
    height: 500 * _growAnimation.value,
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
      flex: 1,
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
    ]
    ),

      Divider(
        thickness: 2,
        color: Colors.grey,
        indent: 16,
        endIndent: 16,
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Identité:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.id.toString(),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),

Expanded(
    child: Padding(
    padding: EdgeInsets.only(left: 45.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('CIN:', style:
          TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(widget.cin,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
            ),
          )
        ],
      ),
    ),
),


      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Numéro téléphone:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.numTel.toString(),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),

      Expanded(
          child: Padding(
        padding: EdgeInsets.only(left: 45.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('E-mail:', style:
            TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(widget.email,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
              ),
            )
          ],
        ),
      ),
      ),

      Expanded(
          child: Padding(
        padding: EdgeInsets.only(left: 45.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Adresse:', style:
            TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(widget.adresse,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
              ),
            )
          ],
        ),
      ),
      ),

      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Date de naissance:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(DateFormat('yyyy-MM-dd').format(widget.d_n),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),

      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Prix Heure Code:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.px_h_c + 'dt',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),

      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Prix Heure Conduite:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.px_h + 'dt',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),

      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Prix Heure Park:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.px_h_P+ 'dt',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),


      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Avance:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.avance+ 'dt',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),

      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Nombre d\'heure total Code:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.nbHtC.toString(),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),

      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left:45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Nombre d\'heure total Conduite:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.nbHT.toString(),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),

      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 45.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Nombre d\'heure total park:', style:
              TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: 'Ronboto'),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.nbHtP.toString(),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'
                ),
              )
            ],
          ),
        ),
      ),
    ]
    )
    )
    ]
    )
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
    );
}
}