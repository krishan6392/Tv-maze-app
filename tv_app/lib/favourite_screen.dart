import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tv_app/main.dart';
import 'package:tv_app/profile_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  var collection = FirebaseFirestore.instance.collection("client");
  late List<Map<String, dynamic>> items;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _show();
  }

  _show() async {
    try {
      List<Map<String, dynamic>> tempList = [];
      var data = await collection.get();
      tempList.addAll(data.docs.map((element) => element.data()));
      setState(() {
        items = tempList;
        isLoaded = true;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Favourites")),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfileScreen()));
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
                  MaterialPageRoute(builder: (context) => HomePage()));
            },
            icon: Icon(
              Icons.logout_outlined,
              size: 30,
            ),
          ),
        ],
      ),
      body: Center(
        child: isLoaded
            ? ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var url = items[index]["profileurl"];
                  var date = items[index]["date"];
                  var fullName = items[index]["name"];
                  var defaultImage;
                  defaultImage =
                      AssetImage('assets/images/default_profile.png');

                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: ListTile(
                        selected: true,
                        title: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(60 / 2),
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: url == null
                                      ? defaultImage
                                      : NetworkImage(url['original']),
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
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
