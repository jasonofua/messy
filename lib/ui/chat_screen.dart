// File: lib/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messhy/controller/chat_controller.dart';


class ChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final ChatController _chatController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Chat'),
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text(_chatController.status.value)),
          )),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: _chatController.messages.length,
                itemBuilder: (context, index) {
                  Message message = _chatController.messages[index];
                  return ListTile(
                    title: Align(
                      alignment: message.isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                        decoration: BoxDecoration(
                          color: message.isSentByMe
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: message.isSentByMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: message.isSentByMe
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              _chatController
                                  .getFormattedTime(message.timestamp),
                              style: TextStyle(
                                color: message.isSentByMe
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 10.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _controller.text;
                    if (message.isNotEmpty) {
                      _chatController.sendMessage(message);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
