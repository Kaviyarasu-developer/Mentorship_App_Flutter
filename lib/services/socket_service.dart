import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

class SocketService {
  static late StompClient stompClient;
  static bool isConnected = false;

  static final Map<String, StompUnsubscribe> _subscriptions = {};

  // ---------------- CONNECT ----------------
  static void connect(Function onConnected) {
    if (isConnected) {
      onConnected();
      return;
    }

    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: "https://practice-app-spring-boot.onrender.com/ws",

        onConnect: (frame) {
          print("Socket Connected");
          isConnected = true;
          onConnected();
        },

        onDisconnect: (frame) {
          print("Socket Disconnected");
          isConnected = false;
        },

        onWebSocketError: (error) {
          print("Socket Error: $error");
        },
      ),
    );

    stompClient.activate();
  }

  // ---------------- SUBSCRIBE ----------------
  static void subscribe({
    required String destination,
    required Function(dynamic) onMessage,
  }) {
    if (_subscriptions.containsKey(destination)) return;

    final unsubscribe = stompClient.subscribe(
      destination: destination,
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          onMessage(data);
        }
      },
    );

    _subscriptions[destination] = unsubscribe;
  }

  // ---------------- UNSUBSCRIBE ----------------
  static void unsubscribe(String destination) {
    _subscriptions[destination]?.call();
    _subscriptions.remove(destination);
  }

  // ---------------- SEND ----------------
  static void send({
    required String destination,
    required Map<String, dynamic> body,
  }) {
    if (!isConnected) {
      print("Socket not connected");
      return;
    }

    stompClient.send(destination: destination, body: jsonEncode(body));
  }

  // ---------------- DISCONNECT ----------------
  static void disconnect() {
    stompClient.deactivate();
    isConnected = false;
    _subscriptions.clear();
  }
}
