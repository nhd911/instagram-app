import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'package:uuid/uuid.dart';

class Uploader extends StatefulWidget {
  const Uploader({Key? key}) : super(key: key);

  @override
  State<Uploader> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<Uploader> {
  File? file;
  ImagePicker imagePicker = ImagePicker();
  TextEditingController descriptionController = TextEditingController();
  bool uploading = false;

  @override
  Widget build(BuildContext context) {
    return file == null
        ? Scaffold(
            appBar: AppBar(
              title:
                  const Text("Upload image", style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white70,
            ),
            body: Container(
              alignment: Alignment.center,
              child: Container(
                  //elese show uplaod button
                  child: RaisedButton.icon(
                      onPressed: () {
                        _selectImage(context);
                        //start uploading image
                      },
                      icon: const Icon(
                        Icons.file_upload,
                        color: Colors.black,
                      ),
                      label: const Text(
                        "UPLOAD IMAGE",
                        style: TextStyle(color: Colors.black),
                      ),
                      color: Colors.white,
                      colorBrightness: Brightness.dark,
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black, width: 2.0))
                      //set brghtness to dark, because deepOrangeAccent is darker coler
                      //so that its text color is light
                      )),
            ))
        // IconButton(
        //   icon: const Icon(Icons.file_upload),
        //   onPressed: () => {_selectImage(context)},
        // ))

        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.white70,
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => {
                        setState(() {
                          file = null;
                        })
                      }),
              title: const Text(
                'Post to',
                style: TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: uploadImage,
                    child: const Text(
                      "Post",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ))
              ],
            ),
            body: PostImage(
                imageFile: file, descriptionController: descriptionController, loading: uploading,));
  }

  _selectImage(BuildContext parentContext) async {
    // print(currentUserModel!.photoUrl);
    return showDialog(
        context: parentContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Create a Post'),
            children: <Widget>[
              SimpleDialogOption(
                  child: const Text('Take a photo'),
                  onPressed: () async {
                    Navigator.pop(context);
                    var imageFile = await imagePicker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 1920,
                        maxHeight: 1200,
                        imageQuality: 80);
                    setState(() {
                      file = File(imageFile!.path);
                    });
                  }),
              SimpleDialogOption(
                  child: const Text('Choose from Gallery'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    var imageFile = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1920,
                        maxHeight: 1200,
                        imageQuality: 80);
                    // print(imageFile);
                    setState(() {
                      // print(File(imageFile!.path));
                      file = File(imageFile!.path);
                      // print(file);
                    });
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

  void uploadImage() {
    //to do code
    setState(() {
      uploading = true;
    });
    uploadFile(file).then((String url) {
      postToFireStore(imageUrl: url, description: descriptionController.text);
    }).then((_) {
      setState(() {
        file = null;
        uploading = false;
      });
    });
  }

  Future<String> uploadFile(var file) async {
    var uuid = Uuid().v1();
    Reference ref =
        FirebaseStorage.instance.ref().child("test-insta/post_$uuid.jpg");
    UploadTask uploadTask = ref.putFile(file!);

    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  late List<DocumentSnapshot> list_users;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  var likes = new Map();

  void postToFireStore(
      {required String imageUrl, required String description}) async {
    var reference = FirebaseFirestore.instance.collection('insta-post');
    // QuerySnapshot snap_user = await _db.collection("insta_users").get();
    //
    // list_users = snap_user.docs;
    // for (var user in list_users) {
    //   likes[user["id"]] = 0;
    // }
    reference.add({
      "username": currentUserModel!.username,
      "likes": {},
      "imageUrl": imageUrl,
      "description": description,
      "ownerId": googleSignIn.currentUser!.id,
      "timestamp": DateTime.now(),
      "comments": {},
    }).then((DocumentReference doc) {
      String docId = doc.id;
      reference.doc(docId).update({"postId": docId});
    });
    // print(reference);
  }
}

class PostImage extends StatelessWidget {
  late final imageFile;
  late final TextEditingController descriptionController;
  final bool loading;
  PostImage(
      {this.imageFile,
      required this.descriptionController,
      required this.loading});

  @override
  Widget build(BuildContext context) {
    // print("day la $globalUserModel");
    // TODO: implement build
    return Column(
      children: <Widget>[
        loading
            ? LinearProgressIndicator()
            : Padding(padding: EdgeInsets.only(top: 0.0)),
        // Divider(),
        Container(
          // height: 45.0,
          // width: 45.0,
          child: AspectRatio(
            aspectRatio: 487 / 451,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.fill,
                alignment: FractionalOffset.topCenter,
                image: FileImage(imageFile),
              )),
            ),
          ),
        ),
        Divider(),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CircleAvatar(
                backgroundImage:
                    NetworkImage(currentUserModel!.photoUrl.toString()),
              ),
              Container(
                width: 250.0,
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      hintText: "Write a caption...", border: InputBorder.none),
                ),
              )
            ]),
      ],
    );
  }
}
