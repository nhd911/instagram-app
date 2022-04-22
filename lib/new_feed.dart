import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'dart:async';
import 'models/user.dart';
import 'theme/color.dart';
import 'uploader.dart';
import 'profile.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'comment_page.dart';

class NewFeed extends StatefulWidget {
  @override
  // _FeedPageState createState() => _FeedPageState();
  State<NewFeed> createState() => _NewFeed();
}

class _NewFeed extends State<NewFeed>
    with AutomaticKeepAliveClientMixin<NewFeed> {
  bool _isLoading = true;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late List<DocumentSnapshot> posts;
  late List<DocumentSnapshot> list_users;
  var id_avatar = new Map();
  var like_tmp = new Map();
  var check_like = List<bool>.filled(100, false, growable: true);
  var total_like = List<int>.filled(100, 0, growable: true);

  bool isloadingLike = true;

  @override
  void initState() {
    _getPosts();
    super.initState();
  }

  Future<void> _getPosts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      var following_users = List<String>.filled(0, '0', growable: true);
      following_users.add(googleSignIn.currentUser!.id);

      var followingSnap = await _db
          .collection("insta_users")
          .doc(googleSignIn.currentUser!.id)
          .get();

      var tmp = followingSnap.data()!["following"].keys;

      for (var i in tmp) {
        following_users.add(i);
      }

      // print("111111 $following_users");
      // print(following_users.runtimeType);
      QuerySnapshot snap = await _db
          .collection("insta-post")
          .where("ownerId", whereIn: following_users)
          .orderBy("timestamp", descending: true)
          .get();
      // print(snap);
      // print(snap.docs);
      QuerySnapshot snap_user = await _db
          .collection("insta_users")
          .where("id", whereIn: following_users)
          .get();

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
          appBar: AppBar(
            backgroundColor: Color(0XFFF8faf8),
            elevation: 1.0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.camera_alt),
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Uploader()),
                );
              },
            ),
            title: const SizedBox(
                height: 35.0,
                child: Text("Dynogram",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Billabong",
                        fontSize: 30.0))),
            actions: const <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.send,
                  color: Colors.black,
                ),
              )
            ],
          ),
          body: Container(
            child: LinearProgressIndicator(),
          ));
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0XFFF8faf8),
          elevation: 1.0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.camera_alt),
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Uploader()),
              );
            },
          ),
          title: const SizedBox(
              height: 38.0,
              child: Text("Dynogram",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Billabong",
                      fontSize: 30.0))),
          actions: const <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.send,
                color: Colors.black,
              ),
            )
          ],
        ),
        body: Container(
            child: RefreshIndicator(
          onRefresh: _getPosts,
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
                    GestureDetector(
                      child: Row(
                        children: [
                          // Container(
                          //   height: 40.0,
                          //   width: 40.0,
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     image: DecorationImage(
                          //         fit: BoxFit.fill,
                          //         image: NetworkImage(
                          //             id_avatar[posts[i]["ownerId"]])),
                          //   ),
                          // ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(id_avatar[posts[i]["ownerId"]]),
                            radius: 18,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            posts[i]["username"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => openProfile(context, posts[i]["ownerId"]),
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
                                width: 10,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.mode_comment_outlined,
                                  color: black,
                                  size: 27,
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
                                    return CommentPage(postId: posts[i]["postId"]);
                                  }));
                                },
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              // SvgPicture.asset(
                              //   "assets/images/message_icon.svg",
                              //   width: 27,
                              //   color: Colors.black,
                              // ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_horiz_outlined,
                              color: Colors.black,
                              size: 27,
                            ),
                            onPressed: () =>
                                downloadImage(context, posts[i]["imageUrl"]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    total_like[i] == 0
                        ? Padding(
                            padding: const EdgeInsets.only(left: 0, right: 0),
                            child: Text(
                              "${total_like[i]} likes",
                              style: TextStyle(
                                  color: black.withOpacity(0.5),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        : GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0, right: 0),
                              child: Text(
                                "${total_like[i]} likes",
                                style: TextStyle(
                                    color: black.withOpacity(0.5),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            onTap: () {
                              showLike(context, posts[i]["postId"]);
                            },
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

  void showLike(BuildContext context, String postId) async {
    // print(following_users);
    setState(() {
      isloadingLike = true;
    });


    var snap = await _db
        .collection("insta-post")
        .where("postId", isEqualTo: postId)
        .get();

    // print(snap.docs[0].data());

    var idLike = snap.docs[0].data()["likes"].keys.toList();

    QuerySnapshot snap_user_like =
        await _db.collection("insta_users").where("id", whereIn: idLike).get();



    var listLike = snap_user_like.docs;
    // print(listLike);

    setState(() {

      isloadingLike = false;
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Like'),
            content: isloadingLike ?
            Container(
              child: LinearProgressIndicator(),
            )
                : Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: listLike.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        listLike[index]["photoUrl"])))),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Text(listLike[index]["username"]),
                      ],
                    ),
                    onTap: () => openProfile(context, listLike[index]["id"]),
                  );
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        });

  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  downloadImage(BuildContext parentContext, String path) async {
    // print(currentUserModel!.photoUrl);
    return showDialog(
        context: parentContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Download image'),
            children: <Widget>[
              SimpleDialogOption(
                  child: const Text('Save'),
                  onPressed: () async {
                    Navigator.pop(context);
                    print(path);
                    _saveImage(path);
                  }),
              SimpleDialogOption(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void _saveImage(String path) async {
    String albumName = 'Media';
    GallerySaver.saveImage(path, albumName: albumName);
  }
}
