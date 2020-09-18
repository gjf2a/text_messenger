import 'dart:io';

const int ourPort = 4444;

class Friends extends Iterable<String> {
  Map<String,Friend> _names2Friends = {};
  Map<String,Friend> _ips2Friends = {};

  void add(String name, String ip) {
    _names2Friends[name] = Friend(ip, name);
    _ips2Friends[ip] = _names2Friends[name];
  }

  String ipAddr(String name) => _names2Friends[name].ipAddr;

  bool hasFriend(String name) => _names2Friends.containsKey(name);

  String historyFor(String name) => _names2Friends[name].history();

  void sendTo(String name, String message) {
    _names2Friends[name].send(message);
  }

  void receiveFrom(String ip, String message) {
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
    _messages = List();
  }

  void receive(String message) {
    _messages.add(Message(_name, message));
  }

  void send(String message) {
    _messages.add(Message("Me", message));
    Future<Socket> connection = Socket.connect(_ipAddr, ourPort);
    connection.then((socket) {socket.write(message); socket.destroy();},
        onError: (error) {print('problem: $error');});
  }

  String history() => _messages.map((m) => m.transcript).fold("", (message, line) => message + '\n' + line);

  String get ipAddr => _ipAddr;
}

class Message {
  String _content;
  String _author;

  Message(this._author, this._content);

  String get transcript => '$_author: $_content';
}