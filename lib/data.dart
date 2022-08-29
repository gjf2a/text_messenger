import 'dart:io';
import 'package:mutex/mutex.dart';

const int ourPort = 8888;
final m = Mutex();

class Friends extends Iterable<String> {
  Map<String,Friend> _names2Friends = {};
  Map<String,Friend> _ips2Friends = {};

  void add(String name, String ip) {
    _names2Friends[name] = Friend(ip, name);
    _ips2Friends[ip] = _names2Friends[name];
  }

  String getName(String ipAddr) => _ips2Friends[ipAddr].name;

  String ipAddr(String name) => _names2Friends[name].ipAddr;

  bool hasFriend(String name) => _names2Friends.containsKey(name);

  String historyFor(String name) => _names2Friends[name].history();

  Future<void> sendTo(String name, String message) async {
    return _names2Friends[name].send(message);
  }

  void receiveFrom(String ip, String message) {
    print("receiveFrom($ip, $message)");
    if (!_ips2Friends.containsKey(ip)) {
      String newFriend = "Friend${_ips2Friends.length}";
      print("Adding new friend");
      add(newFriend, ip);
      print("added $newFriend!");
    }
    _ips2Friends[ip].receive(message);
  }

  @override
  Iterator<String> get iterator => _names2Friends.keys.iterator;
}

class Friend {
  String _ipAddr;
  String _name;
  List<Message> _messages;

  Friend(this._ipAddr, this._name) {
    _messages = [];
  }

  Future<void> send(String message) async {
    Socket socket = await Socket.connect(_ipAddr, ourPort);
    socket.write(message);
    socket.close();
    await _add_message("Me", message);
  }

  Future<void> receive(String message) async {
    return _add_message(_name, message);
  }

  Future<void> _add_message(String name, String message) async {
    await m.protect(() async => _messages.add(Message(name, message)));
  }

  String history() => _messages.map((m) => m.transcript).fold("", (message, line) => message + '\n' + line);

  String get ipAddr => _ipAddr;

  String get name => _name;
}

class Message {
  String _content;
  String _author;

  Message(this._author, this._content);

  String get transcript => '$_author: $_content';
}