import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; //for currentuser & google signin instance
import 'models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'log_out.dart';
import 'main.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  final String id;
  const ProfilePage({Key? key, required this.id}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfilePage> {
  var userData = {};
  int postLength = 0;
  int follower = 0;
  int following = 0;
  bool isLoading = false;
  bool isFollowing = false;
  var follower_users;
  var following_users;
  var following_users_1;
  var following_1;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });
    // get infor user
    var userSnap = await FirebaseFirestore.instance
        .collection("insta_users")
        .doc(widget.id)
        .get();

    // get user post
    var postSnap = await FirebaseFirestore.instance
        .collection("insta-post")
        .where('ownerId', isEqualTo: widget.id)
        .get();

    var currSnap = await FirebaseFirestore.instance
        .collection("insta_users")
        .doc(googleSignIn.currentUser!.id)
        .get();

    postLength = postSnap.docs.length;
    userData = userSnap.data()!;
    follower_users = userSnap.data()!['followers'];
    following_users_1 = userSnap.data()!['following'];
    following_users = currSnap.data()!['following'];
    follower = userSnap.data()!['followers'].length;
    following = userSnap.data()!['following'].length;
    following_1 = following_users_1.length;
    isFollowing = userSnap
        .data()!["followers"]
        .keys
        .contains(googleSignIn.currentUser!.id);
    // isFollowing = true;
    // print(isFollowing);
    // print(userData["username"]);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
                title: Text(userData["username"],
                    style: const TextStyle(color: Colors.black)),
                backgroundColor: Colors.white70,
                actions: [
                  (googleSignIn.currentUser!.id == widget.id)
                      ? PopupMenuButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              child: Text("Log out"),
                              value: 1,
                            )
                          ],
                          onSelected: (value) {
                            if (value == 1) {
                              _logout(context);
                            }
                          },
                        )
                      : const Icon(
                          Icons.more_vert,
                          color: Colors.black,
                        )
                ]),
            body: ListView(children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(
                          userData['photoUrl'],
                        ),
                        radius: 40,
                      ),
                      Expanded(
                          flex: 1,
                          child: Column(children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                columnInfor(postLength, "posts"),
                                follower == 0
                                    ? columnInfor(follower, "followers")
                                    : InkWell(
                                        child:
                                            columnInfor(follower, "followers"),
                                        onTap: () {
                                          showFollower(context);
                                        },
                                      ),
                                following_1 == 0
                                    ? columnInfor(following_1, "following")
                                    : InkWell(
                                        child: columnInfor(
                                            following_1, "following"),
                                        onTap: () {
                                          showFollowing(context);
                                        },
                                      ),
                              ],
                            ),
                            (widget.id == googleSignIn.currentUser!.id)
                                ? editButton(context)
                                : isFollowing
                                    ? unfollowButton(context)
                                    : followButton(context)
                          ]))
                    ]),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: Text(
                        userData['displayName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(
                        top: 1,
                      ),
                      child: Text(
                        userData['bio'],
                      ),
                    ),
                  ])),
              const Divider(),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('insta-post')
                      .where('ownerId', isEqualTo: widget.id)
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      // print(snapshot);
                      return Text('Error: ${snapshot.error}');
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        return GridView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 3.5,
                              mainAxisSpacing: 3.5,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (BuildContext ctx, index) {
                              return googleSignIn.currentUser!.id != widget.id
                                  ? Container(
                                      child: Image(
                                      image: NetworkImage(snapshot
                                          .data!.docs[index]["imageUrl"]),
                                      fit: BoxFit.cover,
                                    ))
                                  : GestureDetector(
                                      child: Container(
                                          child: Image(
                                        image: NetworkImage(snapshot
                                            .data!.docs[index]["imageUrl"]),
                                        fit: BoxFit.cover,
                                      )),
                                      onLongPress: () => showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text('Delete image'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => deleteImage(context, snapshot
                                                  .data!.docs[index]["postId"]),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                            });
                    }
                  })
            ]),
          );
  }

  void deleteImage(BuildContext context, String postId) async {
    setState(() {
      postLength = postLength - 1;
    });
    Navigator.pop(context);
    await _db.collection("insta-post").doc(postId).delete();
  }

  void showFollower(BuildContext context) async {
    QuerySnapshot snap = await _db
        .collection("insta_users")
        .where("id", whereIn: follower_users.keys.toList())
        .get();

    var list_follower = snap.docs;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Follower'),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: follower,
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
                                        list_follower[index]["photoUrl"])))),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Text(list_follower[index]["username"]),
                      ],
                    ),
                    onTap: () =>
                        openProfile(context, list_follower[index]["id"]),
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

  void showFollowing(BuildContext context) async {
    // print(following_users);
    QuerySnapshot snap = await _db
        .collection("insta_users")
        .where("id", whereIn: following_users_1.keys.toList())
        .get();

    var list_following = snap.docs;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Following'),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: following_1,
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
                                        list_following[index]["photoUrl"])))),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Text(list_following[index]["username"]),
                      ],
                    ),
                    onTap: () =>
                        openProfile(context, list_following[index]["id"]),
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

  editButton(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: 2),
        child: TextButton(
          onPressed: () => openEdit(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Edit profile",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            width: 250,
            height: 27,
          ),
        ),
      );

  followButton(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: 2),
        child: TextButton(
          onPressed: () => _follow(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(
                color: Colors.blue,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Follow",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            width: 250,
            height: 27,
          ),
        ),
      );

  unfollowButton(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: 2),
        child: TextButton(
          onPressed: () => _unfollow(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Following",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            width: 250,
            height: 27,
          ),
        ),
      );

  void _follow() async {
    following_users[widget.id] = 1;
    follower_users[googleSignIn.currentUser!.id] = 1;

    await _db
        .collection("insta_users")
        .doc(googleSignIn.currentUser!.id)
        .update({"following": following_users});

    await _db
        .collection("insta_users")
        .doc(widget.id)
        .update({"followers": follower_users});

    setState(() {
      follower += 1;
      isFollowing = true;
    });
  }

  void _unfollow() async {
    follower_users
        .removeWhere((key, value) => key == googleSignIn.currentUser!.id);

    following_users.removeWhere((key, value) => key == widget.id);

    await _db
        .collection("insta_users")
        .doc(googleSignIn.currentUser!.id)
        .update({"following": following_users});

    await _db
        .collection("insta_users")
        .doc(widget.id)
        .update({"followers": follower_users});

    setState(() {
      follower -= 1;
      isFollowing = false;
    });
  }

  Column columnInfor(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

void openProfile(BuildContext context, String id) {
  if (googleSignIn.currentUser!.id == id) {
    Navigator.pushNamed(context, "/profile");
  } else {
    Navigator.of(context)
        .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
      return ProfilePage(id: id);
    }));
  }
}

void openEdit(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
    return EditProfile();
  }));
}

void _logout(BuildContext context) async {
  // print("logout");
  await auth.signOut();
  await googleSignIn.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  currentUserModel = null;

  // Navigator.pop(context);
  Navigator.of(context).pushAndRemoveUntil(
    // the new route
    MaterialPageRoute(
      builder: (BuildContext context) => HomePage(),
    ),

    // this function should return true when we're done removing routes
    // but because we want to remove all other screens, we make it
    // always return false
    (Route route) => false,
  );
}
