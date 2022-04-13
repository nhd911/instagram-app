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

    postLength = postSnap.docs.length;
    userData = userSnap.data()!;
    follower = userSnap.data()!['followers'].length;
    following = userSnap.data()!['following'].length;
    isFollowing = userSnap.data()!["following"].keys.contains(widget.id);
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
                                columnInfor(follower, "followers"),
                                columnInfor(following, "following"),
                              ],
                            ),
                            (widget.id == googleSignIn.currentUser!.id)
                                ? editButton(context)
                                : const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Chưa làm follow"),
                                )
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
                              return Container(
                                  child: Image(
                                image: NetworkImage(
                                    snapshot.data!.docs[index]["imageUrl"]),
                                fit: BoxFit.cover,
                              ));
                            });
                    }
                  })
            ]),
          );
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

void openEdit(BuildContext context){
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
