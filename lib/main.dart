
import 'package:flutter/material.dart';
import 'package:test_flutter/tmp/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as FBA;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import 'models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'create_account.dart';

import 'tmp/feed.dart';
import 'activity_feed.dart';
import 'profile.dart';
import 'search_page.dart';
import 'uploader.dart';
import 'new_feed.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

final auth = FBA.FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();
final ref = FirebaseFirestore.instance.collection('insta_users');
User? currentUserModel;
GoogleSignInAccount? user;

Future<void> _ensureLoggedIn(BuildContext context) async {
  user = googleSignIn.currentUser;
  // print("day la user $user");
  if (user == null) {
    user = await googleSignIn.signInSilently();
  }
  // print(user!.photoUrl);
  // print("day la sdsdsdsd $user");
  // print(auth);
  if (user == null) {
    await googleSignIn.signIn();
    await tryCreateUserRecord(context);
  }

  if (auth.currentUser == null) {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final FBA.OAuthCredential credential = FBA.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );


    await auth.signInWithCredential(credential);
  }
}

Future<Null> _silentLogin(BuildContext context) async {
  GoogleSignInAccount? user = googleSignIn.currentUser;

  if (user == null) {
    user = await googleSignIn.signInSilently();
    await tryCreateUserRecord(context);
  }

  if (await auth.currentUser == null && user != null) {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final FBA.OAuthCredential credential = FBA.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await auth.signInWithCredential(credential);
  }
}

// Future<Null> _setUpNotifications() async {
//   if (Platform.isAndroid) {
//     _firebaseMessaging.getToken().then((token) {
//       print("Firebase Messaging Token: " + token!);
//
//       FirebaseFirestore.instance
//           .collection("insta_users")
//           .doc(currentUserModel?.id)
//           .update({"androidNotificationToken": token});
//     });
//   }
// }

Future<void> tryCreateUserRecord(BuildContext context) async {
  GoogleSignInAccount? user = googleSignIn.currentUser;
  if (user == null) {
    return null;
  }
  DocumentSnapshot userRecord = await ref.doc(user.id).get();
  if (userRecord.data() == null) {
    // no user record exists, time to create

    String userName = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Center(
                child: Scaffold(
                    appBar: AppBar(
                      leading: Container(),
                      title: const Text('Fill out missing data',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.white,
                    ),
                    body: ListView(
                      children: <Widget>[
                        Container(
                          child: CreateAccount(),
                        ),
                      ],
                    )),
              )),
    );

    if (userName != null || userName.length != 0) {
      ref.doc(user.id).set({
        "id": user.id,
        "username": userName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "followers": {},
        "following": {},
      });
    }

    userRecord = await ref.doc(user.id).get();
    // print(userRecord);
  }

  currentUserModel = User.fromDocument(userRecord);
  return null;
}

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // after upgrading flutter this is now necessary

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
          // counter didn't reset back to zero; the application is not restarted.
          primarySwatch: Colors.blue,
          buttonColor: Colors.pink,
          primaryIconTheme: const IconThemeData(color: Colors.black)),
      home: HomePage(title: 'Instagram'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title = ''}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

PageController? pageController;

class _HomePageState extends State<HomePage> {
  int _page = 0;
  bool triedSilentLogin = false;
  bool setupNotifications = false;
  bool firebaseInitialized = false;

  Scaffold buildLoginPage() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100, left: 0.0),
                    child: Container(
                        alignment: Alignment.center,
                        child: const Image(
                          image: AssetImage('assets/images/instatexticon.png'),
                          height: 75.0,
                        )),
                  ),
                ),
                // SafeArea(
                //   child: Padding(
                //     padding: EdgeInsets.all(18.0),
                //     child: Container(
                //         alignment: Alignment.centerLeft,
                //         child: const Text(
                //           "Please sign in to continue ...",
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Colors.grey,
                //           ),
                //         )),
                //   ),
                // )
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, right: 12.0),
              child: Image(
                width: 200.0,
                height: 200.0,
                image: AssetImage('assets/images/Instagram_logo_2016.svg.webp'),
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Container(
                  width: 260.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(1, 3), // changes position of shadow
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/images/google_signin_button.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  final AppTopBar = AppBar(
    backgroundColor: Color(0XFFF8faf8),
    elevation: 1.0,
    centerTitle: true,
    leading: Icon(
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

  @override
  Widget build(BuildContext context) {
    if (triedSilentLogin == false) {
      silentLogin(context);
    }

    // if (setupNotifications == false && currentUserModel != null) {
    //   setUpNotifications();
    // }

    if (!firebaseInitialized) return CircularProgressIndicator();

    auth.authStateChanges().listen((event) {
      if (event == null) {
        silentLogin(context);
      }
    });
    // print(googleSignIn.currentUser);
    // print("day la  curr $currentUserModel");
    // print("day la sdsdsdsd $googleSignIn.currentUser");
    return (googleSignIn.currentUser == null && currentUserModel == null)
        ? buildLoginPage()
        : Scaffold(
            body: PageView(
              children: [
                Container(
                  color: Colors.white,
                  child: NewFeed(),
                ),
                Container(color: Colors.white, child: SearchPage()),
                Container(
                  color: Colors.white,
                  child: Uploader(),
                ),
                Container(color: Colors.white, child: ActivityFeedPage()),
                Container(color: Colors.white, child: ProfilePage()),
              ],
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: onPageChanged,
            ),
            bottomNavigationBar: CupertinoTabBar(
              iconSize: 30.0,
              backgroundColor: Colors.white,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.home,
                        color: (_page == 0) ? Colors.black : Colors.grey),
                    label: '',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search,
                        color: (_page == 1) ? Colors.black : Colors.grey),
                    label: '',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle,
                        color: (_page == 2) ? Colors.black : Colors.grey),
                    label: '',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Icons.star,
                        color: (_page == 3) ? Colors.black : Colors.grey),
                    label: '',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person,
                        color: (_page == 4) ? Colors.black : Colors.grey),
                    label: '',
                    backgroundColor: Colors.white),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          );
  }

  void login() async {
    await _ensureLoggedIn(context);
    setState(() {
      triedSilentLogin = true;
      // globalUserModel = currentUserModel;
    });
  }

  // void setUpNotifications() {
  //   _setUpNotifications();
  //   setState(() {
  //     setupNotifications = true;
  //   });
  // }

  void silentLogin(BuildContext context) async {
    await _silentLogin(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController?.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((_) {
      setState(() {
        firebaseInitialized = true;
      });
    });
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController?.dispose();
  }
}