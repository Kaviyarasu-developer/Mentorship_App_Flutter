import 'dart:convert';
import 'package:practice_app/services/api_config.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

class SocketService {
  static late StompClient stompClient;

  // --------------------  CONNECT ---------------------------------------------
  static void connect({
    required int communityId,
    required Function(dynamic) onMessage,
  }) {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: "http://10.0.2.2:8080/ws",

        onConnect: (frame) {
          stompClient.subscribe(
            destination: "${ApiConfig.baseUrl}/community/$communityId",
            callback: (frame) {
              if (frame.body != null) {
                onMessage(jsonDecode(frame.body!));
              }
            },
          );
        },
      ),
    );

    stompClient.activate();
  }

  //------------------------- SEND MESSAGE---------------------------------------
  static void sendMessage(Map<String, dynamic> msg) {
    try {
      stompClient.send(
        destination: "${ApiConfig.baseUrl}/community/message",
        body: jsonEncode(msg),
      );
      print("message send from the sentMessage method in socket service");
    } catch (e) {
      print("error on the send message of socket service");
    }
  }

  // ----------------------- DISCONNECT-----------------------------------------
  static void disconnect() {
    stompClient.deactivate();
  }
}
