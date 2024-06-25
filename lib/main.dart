// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:messhy/controller/chat_controller.dart';
import 'package:messhy/ui/chat_list.dart';
import 'package:messhy/ui/chat_screen.dart';


void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatController _chatController = Get.put(ChatController());
    return GetMaterialApp(
      title: 'Messy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EndpointListPage(),
    );
  }
}
