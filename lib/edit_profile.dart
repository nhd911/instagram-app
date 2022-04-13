import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; //for currentuser & google signin instance
import 'models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<EditProfile> {
  File? file;
  ImagePicker imagePicker = ImagePicker();
  TextEditingController descriptionController = TextEditingController();
  bool loading = false;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController editingController = TextEditingController();
  bool save = false;
  @override
  Widget build(BuildContext context) {
    return (file == null)
        ? Scaffold(
            appBar: AppBar(
              title: const Text("Edit profile",
                  style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white70,
            ),
            body: Center(
              child: Column(
                children: [
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 50.0,
                    child: RaisedButton.icon(
                      onPressed: () => _changeAvatar(context),
                      icon: const Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      label: const Text(
                        "Change avatar",
                        style: TextStyle(color: Colors.black),
                      ),
                      color: Colors.white,
                      colorBrightness: Brightness.dark,
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white10, width: 1.0)),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 50.0,
                    child: RaisedButton.icon(
                        onPressed: () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: TextField(
                                  controller: editingController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter bio .....'
                                  )),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => _saveBio(),
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.textsms_outlined,
                          color: Colors.black,
                        ),
                        label: const Text(
                          "Add bio .....",
                          style: TextStyle(color: Colors.black),
                        ),
                        color: Colors.white,
                        colorBrightness: Brightness.dark,
                        shape: const RoundedRectangleBorder(
                            side:
                                BorderSide(color: Colors.black12, width: 1.0))),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ))
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
                'Change avatar',
                style: TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () => _saveAvatar(),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ))
              ],
            ),
            body: Column(children: <Widget>[
              loading
                  ? LinearProgressIndicator()
                  : Padding(padding: EdgeInsets.only(top: 0.0)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Center(
                    child: CircleAvatar(
                  radius: 120.0, // Image radius
                  backgroundImage: FileImage(file!),
                ))
              ]),
            ]));
  }

  _changeAvatar(BuildContext parentContext) async {
    // print(currentUserModel!.photoUrl);
    return showDialog(
        context: parentContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Change avatar'),
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

  Future<String> uploadFile(var file) async {
    var uuid = Uuid().v1();
    Reference ref =
        FirebaseStorage.instance.ref().child("test-insta/post_$uuid.jpg");
    UploadTask uploadTask = ref.putFile(file!);

    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  void _saveAvatar() {
    setState(() {
      loading = true;
    });
    uploadFile(file).then((String url) {
      _db
          .collection("insta_users")
          .doc(googleSignIn.currentUser!.id)
          .update({"photoUrl": url});
    }).then((_) {
      setState(() {
        file = null;
        loading = false;
      });
    });
  }

  void _saveBio() async {
    // setState(() {
    //   save = true;
    // });
    // print(editingController);
    await _db
        .collection("insta_users")
        .doc(googleSignIn.currentUser!.id)
        .update({"bio": editingController.text});

    Navigator.pop(context);
    // setState(() {
    //   save = false;
    // });
  }
}
