import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; //for currentuser & google signin instance
import 'models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: const Text(
                "Log Out",
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () => {_logout(context)},
              color: Colors.red,
              textColor: Colors.yellow,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    print("logout");
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
}
