import 'package:flutter/material.dart';
import 'package:test_flutter/tmp/InstaList.dart';

class InstaBody extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: InstaList(),
        )
      ],
    );
  }
}