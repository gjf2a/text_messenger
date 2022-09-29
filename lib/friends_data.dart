import 'dart:io';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

const int ourPort = 8888;
final m = Mutex();

class Friends extends Iterable<String> {
  Map<String, Friend> _names2Friends = {};
  Map<String, Friend> _ips2Friends = {};

  void add(String name, String ip) {
    Friend f = Friend(ipAddr: ip, name: name);
    _names2Friends[name] = f;
    _ips2Friends[ip] = f;
  }

  String? ipAddr(String? name) => _names2Friends[name]?.ipAddr;

  Friend? getFriend(String? name) => _names2Friends[name];

  void receiveFrom(String ip, String message) {
    print("receiveFrom($ip, $message)");
    if (!_ips2Friends.containsKey(ip)) {
      String newFriend = "Friend${_ips2Friends.length}";
      print("Adding new friend");
      add(newFriend, ip);
      print("added $newFriend!");
    }
    _ips2Friends[ip]!.receive(message);
  }

  @override
  Iterator<String> get iterator => _names2Friends.keys.iterator;
}

class Friend extends ChangeNotifier {
  final String ipAddr;
  final String name;
  final List<Message> _messages = [];

  Friend({required this.ipAddr, required this.name});

  Future<void> send(String message) async {
    Socket socket = await Socket.connect(ipAddr, ourPort);
    socket.write(message);
    socket.close();
    await _add_message("Me", message);
  }

  Future<void> receive(String message) async {
    return _add_message(name, message);
  }

  Future<void> _add_message(String name, String message) async {
    await m.protect(() async {
      _messages.add(Message(author: name, content: message));
      notifyListeners();
    });
  }

  String history() => _messages
      .map((m) => m.transcript)
      .fold("", (message, line) => message + '\n' + line);

  Widget bubble_history() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: _messages.map((m) {
        bool is_me = m.author == "Me";
        return BubbleNormal(
          text: m.content,
          isSender: is_me,
          color: is_me ? Color(0xFFE8E8EE) : Color(0xFF1B97F3),
          tail: false,
          textStyle: is_me
              ? TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                )
              : TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
        );
      }).toList(),
    );
  }
}

class Message {
  final String content;
  final String author;

  const Message({required this.author, required this.content});

  String get transcript => '$author: $content';
}
