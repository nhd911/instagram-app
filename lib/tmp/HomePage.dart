import 'package:flutter/material.dart';
// import 'package:test_flutter/screens/InstaBody.dart';
// import 'package:test_flutter/InstaStories.dart';

class HomePage extends StatefulWidget{

  const HomePage({Key? key, String title = ''}): super(key: key);

  @override
  _HomePage createState() => _HomePage();

}

class _HomePage extends State<HomePage>{

  int _selectedIndex = 0;

  final AppTopBar = AppBar(
    backgroundColor: Color(0XFFF8faf8),
    elevation: 1.0,
    centerTitle: true,
    leading: Icon(Icons.camera_alt, color: Colors.black,),
    title: SizedBox(
        height: 35.0, child: Image.asset("assets/images/instatexticon.png")),
    actions: const <Widget>[
      Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: Icon(Icons.send, color: Colors.black,),
      )
    ],
  );

  static const List<Widget> _pages = <Widget>[
    Icon(
      Icons.home,
      size: 150,
    ),
    Icon(
      Icons.search,
      size: 150,
    ),
    Icon(
      Icons.add_box,
      size: 150,
    ),
    Icon(
      Icons.favorite,
      size: 150,
    ),
    Icon(
      Icons.person,
      size: 150,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppTopBar,
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.chat),
          //   label: 'Chats',
          // ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
