import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_ecole/Packs/Pack_Screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;

import '../Packs/pack.dart';


class ListPacks extends StatefulWidget {
  const ListPacks({Key? key}) : super(key: key);

  @override
  State<ListPacks> createState() => _ListPacksState();
}

class _ListPacksState extends State<ListPacks> {
  late Future<List<Datum>> _futurePack;


  @override
  void initState() {
    super.initState();
    _futurePack = getPacks();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr ?'),
        content: const Text('Voulez-vous quitter l\'application'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Non')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Oui'))
        ],
      ),
    )) ??
        false;
  }

// select tous les packs enregistré dans la base de données
  Future<List<Datum>> getPacks() async {
    try {
      final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/get/pack'));

      if (response.statusCode == 200) {
        dynamic decodedData = jsonDecode(response.body);
        if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('data')) {
          final List<dynamic> dataList = decodedData['data'];
          final List<Datum> clist = dataList.map((e) => Datum.fromJson(e))
              .toList();
          return clist;
        } else {
          throw Exception('Failed to load Packs');
        }
      } else {
        throw Exception('Failed to load Packs');
      }
    } catch (e) {
      print('Error fetching packs: $e');
      throw Exception('Failed to load packs');
    }
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
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
      appBar: AppBar(
        title: Text('List packs', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),),
        backgroundColor: HexColor('4159A2'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Datum>>(
        future: _futurePack,
        builder: (BuildContext context, AsyncSnapshot<List<Datum>> snapshot) {
          if (snapshot.hasData) {
            return Center(  // Wrap the ListView.builder with a Center widget
              child: Column(
                children: [
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 800),
                            child: SlideAnimation(
                              verticalOffset: 100.0,
                              child: FadeInAnimation(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            gold_pack(
                                              nom: snapshot.data![index].nom,
                                              prix: snapshot.data![index].prix,
                                              image: snapshot.data![index].image,
                                              description: snapshot.data![index].description,
                                              data: snapshot.data![index],
                                            ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10.0),
                                      ),
                                      child: Center(
                                        child: Card(
                                          shadowColor: Colors.black,
                                          elevation: 2,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: _buildImageProvider(snapshot.data![index].image),
                                                fit: BoxFit.cover,
                                              ),

                                          borderRadius: BorderRadius
                                                  .circular(10.0),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      8.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${snapshot
                                                              .data![index]
                                                              .nom}',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'prix: ${snapshot
                                                            .data![index]
                                                            .prix} dt',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight
                                                              .bold,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          'Ajouter Pack',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                          ),
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
                              ),
                            ),
                          );
                        }
    ),
            ),
                  )
                ,]
    )
    );
    } else {
            return Center(
                child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ),
    );
  }
}
