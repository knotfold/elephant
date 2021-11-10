import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WidgetTester extends StatelessWidget {
  const WidgetTester({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: ErrorConnection(),
    );
  }
}
