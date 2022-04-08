import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'dart:async';
import 'models/user.dart';
import 'theme/color.dart';

class NewFeed extends StatefulWidget {
  @override
  // _FeedPageState createState() => _FeedPageState();
  State<NewFeed> createState() => _NewFeed();
}

class _NewFeed extends State<NewFeed> with AutomaticKeepAliveClientMixin<NewFeed> {
  final AppTopBar = AppBar(
    backgroundColor: Color(0XFFF8faf8),
    elevation: 1.0,
    centerTitle: true,
    leading: const Icon(
      Icons.camera_alt,
      color: Colors.black,
    ),
    title: SizedBox(
        height: 35.0, child: Image.asset("assets/images/instatexticon.png")),
    actions: const <Widget>[
      Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: Icon(
          Icons.send,
          color: Colors.black,
        ),
      )
    ],
  );

  bool _isLoading = true;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late List<DocumentSnapshot> posts;
  late List<DocumentSnapshot> list_users;
  var id_avatar = new Map();
  var like_tmp = new Map();
  var check_like = List<bool>.filled(100, false, growable: true);
  var total_like = List<int>.filled(100, 0, growable: true);

  @override
  void initState() {
    _fetchPosts();
    super.initState();
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() {
        _isLoading = true;
      });
      QuerySnapshot snap = await _db
          .collection("insta-post")
          .orderBy("timestamp", descending: true)
          .get();
      QuerySnapshot snap_user = await _db.collection("insta_users").get();

      list_users = snap_user.docs;
      for (var user in list_users) {
        id_avatar[user["id"]] = user["photoUrl"];
      }
      print(id_avatar);
      setState(() {
        posts = snap.docs;

        _isLoading = false;

        for (var i = 0; i < posts.length; i++) {
          if (posts[i]["likes"][googleSignIn.currentUser!.id] != null) {
            check_like[i] = true;
          } else {
            check_like[i] = false;
          }
        }

        for (var i = 0; i < posts.length; i++) {
          total_like[i] = posts[i]["likes"].length;
        }

        // print(check_like);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (_isLoading) {
      return Scaffold(
          appBar: AppTopBar,
          body: Container(
            child: LinearProgressIndicator(),
          ));
    }
    return Scaffold(
        appBar: AppTopBar,
        body: Container(
            child: RefreshIndicator(
          onRefresh: _fetchPosts,
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (ctx, i) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        color: Color(0x22000000),
                        offset: Offset(0, 4),
                      ),
                    ]),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                                    id_avatar[posts[i]["ownerId"]])),
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          posts[i]["username"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FadeInImage(
                        placeholder:
                            const AssetImage("assets/images/placeholder.png"),
                        image: NetworkImage(posts[i]["imageUrl"]),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0, right: 0, top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  check_like[i]
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      check_like[i] ? Colors.red : Colors.black,
                                  size: 33,
                                ),
                                onPressed: () {
                                  like_tmp = posts[i]["likes"];
                                  if (!check_like[i]) {
                                    setState(() {
                                      like_tmp[googleSignIn.currentUser!.id] =
                                          1;
                                      print(like_tmp);
                                      _db
                                          .collection("insta-post")
                                          .doc(posts[i]["postId"])
                                          .update({"likes": like_tmp});
                                      check_like[i] = true;
                                      total_like[i] = total_like[i] + 1;
                                      like_tmp = {};
                                    });
                                  } else {
                                    setState(() {
                                      like_tmp.removeWhere((key, value) =>
                                          key == googleSignIn.currentUser!.id);
                                      _db
                                          .collection("insta-post")
                                          .doc(posts[i]["postId"])
                                          .update({"likes": like_tmp});
                                      check_like[i] = false;
                                      total_like[i] = total_like[i] - 1;
                                      like_tmp = {};
                                    });
                                  }
                                },
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                              SvgPicture.asset(
                                "assets/images/comment_icon.svg",
                                width: 27,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              SvgPicture.asset(
                                "assets/images/message_icon.svg",
                                width: 27,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            "assets/images/save_icon.svg",
                            width: 27,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0, right: 0),
                      child: Text(
                        "${total_like[i]} likes",
                        style: TextStyle(
                            color: black.withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                      softWrap: true,
                      text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: posts[i]["username"],
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            ),
                            TextSpan(
                                text: " ${posts[i]["description"]}",
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: black)),
                          ]),
                    ),
                  ],
                ),
              );
            },
          ),
        )));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
