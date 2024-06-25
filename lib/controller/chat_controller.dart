// File: lib/chat_controller.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class Message {
  final String content;
  final DateTime timestamp;
  final bool isSentByMe;
  final String messageId;

  Message({
    required this.content,
    required this.timestamp,
    required this.isSentByMe,
    required this.messageId,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isSentByMe': isSentByMe,
    'messageId': messageId,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
    isSentByMe: json['isSentByMe'],
    messageId: json['messageId'],
  );
}

class ChatController extends GetxController {
  final Strategy strategy = Strategy.P2P_STAR;
  RxList<Message> messages = <Message>[].obs;
  final String userName = 'User_${DateTime.now().millisecondsSinceEpoch}';
  RxBool isConnected = false.obs;
  RxString status = "Disconnected".obs;
  final Set<String> processedMessages = <String>{};
  final RxList<String> connectedEndpoints = <String>[].obs;
  final TextEditingController messageController = TextEditingController();
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    box.writeIfNull('connectedEndpoints', []);
    startAdvertising();
    startDiscovery();
  }

  void startAdvertising() async {
    try {
      await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: onConnectionInitiated,
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            isConnected.value = true;
            connectedEndpoints.add(id);
            box.write('connectedEndpoints', connectedEndpoints);
            this.status.value = "Connected";
          } else {
            isConnected.value = false;
            this.status.value = "Disconnected";
          }
        },
        onDisconnected: (id) {
          isConnected.value = false;
          status.value = "Disconnected";
          connectedEndpoints.remove(id);
          box.write('connectedEndpoints', connectedEndpoints);
        },
      );
    } catch (e) {
      status.value = "Advertising Error: $e";
    }
  }

  void startDiscovery() async {
    try {
      await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          Nearby().requestConnection(
            userName,
            id,
            onConnectionInitiated: onConnectionInitiated,
            onConnectionResult: (id, status) {
              if (status == Status.CONNECTED) {
                isConnected.value = true;
                connectedEndpoints.add(id);
                box.write('connectedEndpoints', connectedEndpoints);
                this.status.value = "Connected";
              } else {
                isConnected.value = false;
                this.status.value = "Disconnected";
              }
            },
            onDisconnected: (id) {
              isConnected.value = false;
              status.value = "Disconnected";
              connectedEndpoints.remove(id);
              box.write('connectedEndpoints', connectedEndpoints);
            },
          );
        },
        onEndpointLost: (id) {},
      );
    } catch (e) {
      status.value = "Discovery Error: $e";
    }
  }

  void onConnectionInitiated(String id, ConnectionInfo info) {
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endid, payload) async {
        if (payload.type == PayloadType.BYTES) {
          String receivedData = String.fromCharCodes(payload.bytes!);
          Map<String, dynamic> data = jsonDecode(receivedData);

          String messageId = data['messageId'];
          if (!processedMessages.contains(messageId)) {
            processedMessages.add(messageId);

            String content = data['content'];
            DateTime timestamp = DateTime.parse(data['timestamp']);
            bool isSentByMe = data['isSentByMe'];

            Message newMessage = Message(
              content: content,
              timestamp: timestamp,
              isSentByMe: isSentByMe,
              messageId: messageId,
            );

            messages.add(newMessage);
            _saveMessage(endid, newMessage);

            // Forward the message to other connected devices
            await forwardMessage(receivedData, endid);
          }
        }
      },
    );
  }

  void sendMessage(String message) async {
    if (message.isNotEmpty) {
      String messageId = DateTime.now().millisecondsSinceEpoch.toString();
      DateTime timestamp = DateTime.now();

      Message newMessage = Message(
        content: message,
        timestamp: timestamp,
        isSentByMe: true,
        messageId: messageId,
      );

      messages.add(newMessage);
      processedMessages.add(messageId);

      Map<String, dynamic> data = {
        'content': message,
        'timestamp': timestamp.toIso8601String(),
        'isSentByMe': true,
        'messageId': messageId,
      };

      String jsonData = jsonEncode(data);
      await _sendToAllEndpoints(jsonData);
      _saveMessage('local', newMessage); // Save message locally as well
    }
  }

  Future<void> forwardMessage(String message, String senderId) async {
    await _sendToAllEndpoints(message, excludeEndpoint: senderId);
  }

  Future<void> _sendToAllEndpoints(String payload, {String? excludeEndpoint}) async {
    for (String endpoint in connectedEndpoints) {
      if (endpoint != excludeEndpoint) {
        try {
          await Nearby().sendBytesPayload(endpoint, Uint8List.fromList(payload.codeUnits));
        } catch (e) {
          print(e);
          // Handle the error if needed
        }
      }
    }
  }

  void _saveMessage(String endpointId, Message message) {
    List<String> messagesJson = box.read<List<String>>(endpointId) ?? [];
    messagesJson.add(jsonEncode(message.toJson()));
    box.write(endpointId, messagesJson);
  }

  List<Message> getMessages(String endpointId) {
    List<String> messagesJson = box.read<List<String>>(endpointId) ?? [];
    return messagesJson.map((msg) => Message.fromJson(jsonDecode(msg))).toList();
  }

  String getFormattedTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  String getRelativeTime(DateTime timestamp) {
    return timeago.format(timestamp);
  }

  void onShake() {
    // Action to perform on shake
    print("Device shaken!");
  }
}
