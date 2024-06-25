// File: lib/endpoint_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messhy/controller/chat_controller.dart';
import 'chat_screen.dart';

class EndpointListPage extends StatelessWidget {
  final ChatController chatController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connected Endpoints"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              chatController.startDiscovery();
            },
          ),
        ],
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: chatController.connectedEndpoints.length,
          itemBuilder: (context, index) {
            final endpoint = chatController.connectedEndpoints[index];
            return ListTile(
              title: Text(endpoint),
              onTap: () {
                Get.to(() => ChatScreen(),arguments: [endpoint]);
              },
            );
          },
        );
      }),
    );
  }
}
