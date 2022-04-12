import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'models/user.dart';
import 'new_feed.dart';
import 'profile.dart';

class SearchPage extends StatefulWidget {
  _SearchPage createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  String name = "";
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            // The search area here
            title: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: TextField(
                  onChanged: (value) => setNameSearch(value),
                  controller: editingController,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          /* Clear the search field */
                          setState(() {
                            editingController.clear();
                            name = ""; //Clear value
                          });
                        },
                      ),
                      hintText: 'Search username ...',
                      border: InputBorder.none),
                ),
              ),
            )),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: name != "" && name != null
                  ? FirebaseFirestore.instance
                      .collection("insta_users")
                      .where(
                        "username",
                        isGreaterThanOrEqualTo: name,
                        isLessThan: name.substring(0, name.length - 1) +
                            String.fromCharCode(
                                name.codeUnitAt(name.length - 1) + 1),
                      )
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("insta_users")
                      .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  // print(snapshot);
                  return Text('Error: ${snapshot.error}');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: Text('Loading...'));
                  default:
                    // print(snapshot.data!.docs[1]["username"]);
                    return ListView(
                      children: snapshot.data!.docs
                          .map((QueryDocumentSnapshot document) {
                        print(document["username"]);
                        return GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(children: <Widget>[
                                // const SizedBox(
                                //   height: 15,
                                // ),
                                Row(
                                  children: [
                                    Container(
                                        height: 40.0,
                                        width: 40.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(
                                                document["photoUrl"]),
                                          ),
                                        )),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      document["username"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                            onTap: () => openProfile(context, document["id"]));
                      }).toList(),
                    );
                }
              }),
        )
        //   ],
        // ),
        );
  }

  void setNameSearch(String value) {
    setState(() {
      name = value.trim();
      // print(name);
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
