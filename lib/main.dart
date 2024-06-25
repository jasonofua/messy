// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messhy/controller/chat_controller.dart';
import 'package:messhy/ui/chat_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatController _chatController = Get.put(ChatController());
    return GetMaterialApp(
      title: 'Offline Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}
