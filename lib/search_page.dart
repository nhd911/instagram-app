import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'models/user.dart';

class SearchPage extends StatefulWidget {
  _SearchPage createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  String name = "";
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // TextEditingController editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            onChanged: (value) => setNameSearch(value),
          ),
        ),
        body:
            // body: Container(
            //   child: Column(
            //     children: <Widget>[
            //       const SizedBox(
            //         height: 15.0,
            //       ),
            //       Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: Flexible(
            //             child: TextField(
            //               onChanged: (value) => setNameSearch(value),
            //
            //               // controller: editingController,
            //               decoration: const InputDecoration(
            //                   labelText: "Search",
            //                   hintText: "Search",
            //                   prefixIcon: Icon(
            //                     Icons.search,
            //                     color: Colors.black,
            //                   ),
            //                   border: OutlineInputBorder(
            //                       borderRadius:
            //                           BorderRadius.all(Radius.circular(25.0)),
            //                       borderSide:
            //                           BorderSide(color: Colors.black, width: 2.0))),
            //             ),
            //           )),
            StreamBuilder<QuerySnapshot>(
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
                      return const Text('Loading...');
                    default:
                      // print(snapshot.data!.docs[1]["username"]);
                      return ListView(
                        children: snapshot.data!.docs
                            .map((QueryDocumentSnapshot document) {
                          print(document["username"]);
                          return ListTile(
                            title: Text(document['username']),
                          );
                        }).toList(),
                      );
                  }
                }));
    //       ],
    //     ),
    //   // ),
    // );
  }

  void setNameSearch(String value) {
    setState(() {
      name = value.toLowerCase().trim();
      // print(name);
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
