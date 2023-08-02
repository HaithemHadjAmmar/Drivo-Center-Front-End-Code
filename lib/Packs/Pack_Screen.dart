import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_ecole/Packs/pack.dart';
import 'package:auto_ecole/Screens/home_Screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hexcolor/hexcolor.dart';

import '../rounded_button.dart';
import 'Succed_Page.dart';



class gold_pack extends StatefulWidget {

  final String nom;
  final int prix;
  final String image;
  final String description;
  gold_pack({Key? key, required Datum data, required this.nom, required this.prix, required this.image, required this.description}) : super(key: key);

  @override
  _gold_packState createState() => _gold_packState();
}

class _gold_packState extends State<gold_pack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<AlignmentGeometry> _animation;
  late Animation<double> _growAnimation;

  //varibales necessaire lel backend haseb formulaire eli eendi
  String cardNumber = '';
  String cardHolderName='';
  String Packtype = 'Pack Gold';
  String id = '1';
  String description = '';



  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // use Image Provider because the image is stored with the type Text in the DB
  ImageProvider _buildImageProvider(String base64Image) {
    try {
      // Decode the base64-encoded image string
      Uint8List decodedBytes = base64Decode(base64Image);

      // Create a MemoryImage from the decoded bytes
      return MemoryImage(decodedBytes);
    } catch (e) {
      // Error handling
      print('Error decoding base64 image: $e');
      return AssetImage('path/to/placeholder_image.png');
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title:  Text('${widget.nom}',style: TextStyle(fontFamily: 'Roboto'),),
        backgroundColor: HexColor('4159A2'),
        centerTitle: true,
        leading: IconButton(
          onPressed: ()
          {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ListPacks(),
                ));
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
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
                                    height: 320 * _growAnimation.value,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      image: DecorationImage(
                                        image: _buildImageProvider(widget.image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: child,
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
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    // flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          'Description: ${widget.description}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 140,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                            ],
                          ),
                        ),
                      ),
                    )
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0), // Add desired padding here
            child: Column(
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Numéro Carte',
                    labelText: 'Entrer la numéro de votre Carte',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  onChanged: (value){
                    cardNumber = value;
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'nom du titulaire de la carte',
                    labelText: 'Entre le nom du titulaire de la carte',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  onChanged: (value){
                    cardHolderName = value;
                  },
                ),
                SizedBox(height: 16),

                RoundedButton(
                    btnText: 'Parceed',
                    onBtnPressed:() {}
                ),

                SizedBox(
                  height: 4,
                ),
                Stack(
                  children: [
                    Divider(
                      thickness: 2,
                      color: Colors.grey,
                      indent: 16,
                      endIndent: 210,
                    ),

                    Center(
                      child: Text('OU',style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    Divider(
                      thickness: 2,
                      color: Colors.grey,
                      indent: 210,
                      endIndent: 16,
                    )
                  ],
                ),

                SizedBox(
                  height: 10,
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Entrer votre Jeton',
                    labelText: 'Entrer la Jeton de votre forfait',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  onChanged: (value){
                    cardNumber = value;
                  },
                ),

                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'prix: ${widget.prix} dt',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 180),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black,width: 2),// Set the width of the border
                      ),
                      child: TextButton(
                        child: Text(
                          'Payez',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: ()
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => const Succed_Page(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

