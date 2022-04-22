import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/theme/color.dart';
class CommentPage extends StatefulWidget {
  final postId;
  const CommentPage({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentPage> {
  TextEditingController commentEditingController = TextEditingController();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var username;
  var photoUrl;
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    setState(() {
      _isloading = true;
    });
    var userSnap = await _db
        .collection("insta_users")
        .doc(googleSignIn.currentUser!.id)
        .get();
    username = userSnap.data()!["username"];
    photoUrl = userSnap.data()!["photoUrl"];
    // print(userSnap.data());
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return _isloading
        ? Scaffold(
            appBar: AppBar(
              title:
                  const Text("Comments", style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white70,
            ),
            body: Container(
              child: LinearProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title:
                  const Text("Comments", style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white70,
            ),
            bottomNavigationBar: SafeArea(
                child: Container(
                    height: kToolbarHeight,
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(photoUrl),
                          radius: 18,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            child: TextField(
                              controller: commentEditingController,
                              decoration: InputDecoration(
                                hintText: 'Comment as $username',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => postComment(widget.postId,
                              commentEditingController.text, username),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: const Text(
                              'Post',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        )
                      ],
                    ))),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('insta-post')
                    .doc(widget.postId)
                    .collection('comments')
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (ctx, index) =>
                          // children: [
                          //   Text(snapshot.data!.docs[index].data()["username"]),
                          //   const SizedBox(width: 15.0,),
                          //   Text(snapshot.data!.docs[index].data()["text"])
                          // ],
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: RichText(
                              softWrap: true,
                              text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: snapshot.data!.docs[index].data()["username"],
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black),
                                    ),
                                    TextSpan(
                                        text: " ${snapshot.data!.docs[index].data()["text"]}",
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: black)),
                                  ]),
                            ),
                          ),

                      );
                }));
  }

  Future<String> postComment(
      String postId, String text, String username) async {
    // print(postId);
    // print(text);
    String res = "";

    setState(() {
      commentEditingController.clear();
    });

    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _db
            .collection('insta-post')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'username': username,
          'text': text,
          'commentId': commentId,
          'timestamp': DateTime.now(),
        });
        res = 'Done';
      } else {
        res = "Text empty";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
