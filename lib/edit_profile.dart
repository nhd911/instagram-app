import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; //for currentuser & google signin instance
import 'models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EditProfile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: () => _edit(context),
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
  }

  void _edit(BuildContext context) async {

  }
}
