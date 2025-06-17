import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:get/get.dart';

class TalkerDebugScreen extends StatelessWidget {
  const TalkerDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final talker = Get.find<Talker>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Talker Logs')),
      child: SafeArea(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: TalkerScreen(talker: talker),
        ),
      ),
    );
  }
}
