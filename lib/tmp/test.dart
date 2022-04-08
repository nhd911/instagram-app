// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter/material.dart';
// //
// // import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// //
// // void main() => runApp(MyApp());
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: MyHomePage(),
// //     );
// //   }
// // }
// //
// // class MyHomePage extends StatefulWidget {
// //   @override
// //   _MyHomePageState createState() => _MyHomePageState();
// // }
// //
// // class _MyHomePageState extends State<MyHomePage> {
// //   String _message = 'You are not sign in';
// //
// //   final Future<FirebaseApp> _initialization = Firebase.initializeApp();
// //
// //   late FirebaseAuth _auth;
// //   late GoogleSignIn _googleSignIn;
// //
// //   Future<User> _handleSignIn() async {
// //     final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
// //     final GoogleSignInAuthentication googleAuth =
// //     await googleUser.authentication;
// //
// //     final AuthCredential credential = GoogleAuthProvider.credential(
// //       accessToken: googleAuth.accessToken,
// //       idToken: googleAuth.idToken,
// //     );
// //
// //     final User user = (await _auth.signInWithCredential(credential)).user;
// //     print("signed in " + user.displayName);
// //     setState(() {
// //       // User đã login thì hiển thị đã login
// //       _message = "You are signed in";
// //     });
// //     return user;
// //   }
// //
// //   Future _handleSignOut() async {
// //     await _auth.signOut();
// //     await _googleSignIn.signOut();
// //     setState(() {
// //       // Hiển thị thông báo đã log out
// //       _message = "You are not sign out";
// //     });
// //   }
// //
// //   Future _checkLogin() async {
// //     // Khi mở app lên thì check xem user đã login chưa
// //     final User user = _auth.currentUser;
// //     if (user != null) {
// //       setState(() {
// //         _message = "You are signed in";
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Firebase Login'),
// //       ),
// //       body: FutureBuilder(
// //           future: _initialization,
// //           builder: (context, snapshot) {
// //             if (snapshot.hasError) {
// //               return Text('Something went wrong');
// //             }
// //
// //             if (snapshot.connectionState == ConnectionState.done) {
// //               _auth = FirebaseAuth.instance;
// //               _googleSignIn = GoogleSignIn();
// //               _checkLogin();
// //               return Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: <Widget>[
// //                     Text(_message),
// //                     OutlineButton(
// //                       onPressed: () {
// //                         _handleSignIn();
// //                       },
// //                       child: Text('Login'),
// //                     ),
// //                     OutlineButton(
// //                       onPressed: () {
// //                         _handleSignOut();
// //                       },
// //                       child: Text('Logout'),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             }
// //
// //             return CircularProgressIndicator();
// //           }),
// //     );
// //   }
// // }
//
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SafeArea(
//         child: Scaffold(
//           appBar: AppBar(
//             leading: IconButton(
//               onPressed: () {
//                 // Navigator.pop(context);
//               },
//               icon: Icon(Icons.arrow_back),
//             ),
//             title: Text('Edit Profile'),
//           ),
//           body: ProfilePage(),
//         ),
//       ),
//     );
//   }
// }
//
// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   late File _image;
//
//   Future getImage() async {
//     var image = await ImagePicker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       _image = image as File;
//       print('Image Path: $_image');
//     });
//   }
//
//   Future uploadImage(BuildContext context) async {
//     String fileName = basename(_image.path);
//     StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
//     StorageUploadTask uploadTask = ref.putFile(_image);
//     StorageTaskSnapshot snapshot = await uploadTask.onComplete;
//     bool complete = uploadTask.isComplete;
//
//     complete
//         ? setState(() {
//       print('Pciture uploaded');
//       Scaffold.of(context)
//           .showSnackBar(SnackBar(content: Text('Pciture uploaded')));
//     })
//         : setState(() {
//       Scaffold.of(context)
//           .showSnackBar(SnackBar(content: CircularProgressIndicator()));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (context) => Container(
//         padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
//         child: Column(
//           //* mainAxisAlignment: MainAxisSize.,
//           children: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 CircleAvatar(
//                   radius: 100,
//                   backgroundColor: Colors.lightBlueAccent,
//                   child: ClipOval(
//                     child: SizedBox(
//                       width: 180.0,
//                       height: 180.0,
//                       child: (_image != null)
//                           ? Image.file(
//                         _image,
//                         fit: BoxFit.cover,
//                       )
//                           : Image(
//                         image: NetworkImage(
//                             'https://pointchurch.com/wp-content/uploads/2019/02/Blank-Person-Image.png'),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     getImage();
//                   },
//                   icon: Icon(
//                     FontAwesomeIcons.camera,
//                     color: Colors.grey,
//                     size: 30,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             ListTile(
//               title: Text(
//                 'User Name',
//                 textAlign: TextAlign.center,
//               ),
//               subtitle: Text(
//                 'Tamer Ahmad',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//               trailing: IconButton(
//                 onPressed: () {},
//                 icon: Icon(FontAwesomeIcons.edit),
//               ),
//             ),
//             ListTile(
//               title: Text(
//                 'Birthday',
//                 textAlign: TextAlign.center,
//               ),
//               subtitle: Text(
//                 '16/3/1995',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//               trailing: IconButton(
//                 onPressed: () {},
//                 icon: Icon(FontAwesomeIcons.edit),
//               ),
//             ),
//             ListTile(
//               title: Text(
//                 'Location',
//                 textAlign: TextAlign.center,
//               ),
//               subtitle: Text(
//                 'London, UK',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//               trailing: IconButton(
//                 onPressed: () {},
//                 icon: Icon(FontAwesomeIcons.edit),
//               ),
//             ),
//             ListTile(
//               leading: Icon(
//                 Icons.email,
//                 size: 30,
//               ),
//               title: Text(
//                 'tamer@email.com',
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//             ),
//             SizedBox(
//               height: 30,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: <Widget>[
//                 SizedBox(
//                   width: 100,
//                   height: 50,
//                   child: RaisedButton(
//                     onPressed: () {
//                       // Navigator.pop(context);
//                     },
//                     color: Colors.redAccent,
//                     elevation: 5,
//                     splashColor: Colors.red,
//                     child: Text(
//                       'Cancel',
//                       style: TextStyle(fontSize: 20),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 200,
//                   height: 50,
//                   child: RaisedButton(
//                     onPressed: () {
//                       uploadImage(context);
//                     },
//                     color: Colors.greenAccent,
//                     elevation: 5,
//                     splashColor: Colors.green,
//                     child: Text(
//                       'Submit',
//                       style: TextStyle(fontSize: 20),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }