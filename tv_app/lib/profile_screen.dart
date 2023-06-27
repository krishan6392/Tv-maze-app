import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tv_app/favourite_screen.dart';
import 'package:tv_app/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final database = FirebaseDatabase.instance;

  List users = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    this.fetchUser();
  }

  fetchUser() async {
    var url = "https://api.tvmaze.com/search/shows?q=documentary";
    var response = await http.get(Uri.parse(url));
    //print("${reponse.body}");
    if (response.statusCode == 200) {
      var items = json.decode(response.body);
      //print(items);
      setState(() {
        users = items;
      });
    } else {
      setState(() {
        users = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("TV Shows")),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomePage()));
          },
          icon: Icon(
            Icons.arrow_back,
            size: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => FavouriteScreen()));
            },
            icon: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 36,
            ),
          )
        ],
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return getCard(users[index]);
        });
  }

  Widget getCard(index) {
    var defaultImage;
    defaultImage = AssetImage('assets/images/default_profile.png');
    var fullName = index['show']['name'];
    var date = index['show']['premiered'];
    var profileUrl = index['show']['image'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          selected: true,
          trailing: FavoriteButton(
            iconSize: 30,
            valueChanged: (_isFavourite) {
              print('is Favourite: $_isFavourite');
              if (_isFavourite == true) {
                CollectionReference collRef =
                    FirebaseFirestore.instance.collection('client');
                collRef.add({
                  'name': fullName,
                  'profileurl': profileUrl,
                  'date': date,
                });
              } else {
                // Get the reference to the show in Firebase Firestore.
                DocumentReference docRef = FirebaseFirestore.instance
                    .collection('client')
                    .doc(fullName);

                // Delete the show from Firebase Firestore.
                docRef.delete().then((_) {
                  print("Document deleted");
                }).catchError((error) {
                  print(error);
                });
              }
            },
          ),
          onTap: () {},
          title: Row(
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(60 / 2),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: profileUrl == null
                        ? defaultImage
                        : NetworkImage(profileUrl['medium'].toString()),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${fullName.substring(0, 7)}...",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    date.toString(),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
