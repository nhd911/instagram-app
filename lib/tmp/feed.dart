import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_flutter/theme/color.dart';
import 'package:test_flutter/data_test/body_feed.dart';
import 'package:line_icons/line_icons.dart';

class InstaBody extends StatelessWidget {
  final String profileImg;
  final String name;
  final String postImg;
  final String caption;
  final isLoved;
  final String likedBy;
  final String viewCount;
  final String dayAgo;
  const InstaBody({
    Key? key,
    required this.profileImg,
    required this.name,
    required this.postImg,
    required this.isLoved,
    required this.likedBy,
    required this.viewCount,
    required this.dayAgo,
    required this.caption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(name.runtimeType);
    // TODO: implement build
    return Padding(

      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(profileImg),
                              fit: BoxFit.cover)),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            height: 400,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(postImg), fit: BoxFit.cover)),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[

                    isLoved
                        ? SvgPicture.asset(
                            "assets/images/loved_icon.svg",
                            width: 27,
                          )
                        : SvgPicture.asset(
                            "assets/images/love_icon.svg",
                            width: 27,
                            color: Colors.black,
                          ),
                    const SizedBox(
                      width: 20,
                    ),
                    SvgPicture.asset(
                      "assets/images/comment_icon.svg",
                      width: 27,
                      color: Colors.black,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SvgPicture.asset(
                      "assets/images/message_icon.svg",
                      width: 27,
                      color: Colors.black,
                    ),
                  ],
                ),
                SvgPicture.asset(
                  "assets/images/save_icon.svg",
                  width: 27,
                  color: Colors.black,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Text(
              "Liked by $likedBy and other",
              style: TextStyle(
                  color: black.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: "$name ",
                    style:
                        const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),

                TextSpan(
                    text: "$caption",
                    style:
                        const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: black)),
              ]))),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Text(
              "View $viewCount comments",
              style: TextStyle(
                  color: black.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage(profileImg),
                                fit: BoxFit.cover)),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Add a comment...",
                        style: TextStyle(
                            color: black.withOpacity(0.5),
                            fontSize: 15,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "😂",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "😍",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.add_circle,
                        color: Colors.black.withOpacity(0.5),
                        size: 18,

                      )
                    ],
                  )
                ],
              )),
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Text(
              "$dayAgo",
              style: TextStyle(
                  color: black.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }
}

class Feed extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return getBody();
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

  Widget getBody() {
    return Scaffold(
      appBar: AppTopBar,
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
            child: Column(
              children: List.generate(posts.length, (index) {
                return InstaBody(
                  postImg: posts[index]['postImg'],
                  profileImg: posts[index]['profileImg'],
                  name: posts[index]['name'],
                  caption: posts[index]['caption'],
                  isLoved: posts[index]['isLoved'],
                  viewCount: posts[index]['commentCount'],
                  likedBy: posts[index]['likedBy'],
                  dayAgo: posts[index]['timeAgo'],
                );
              }),
            )),
      ),
    );

  }
}
