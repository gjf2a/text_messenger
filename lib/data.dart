import 'dart:io';

const int ourPort = 4444;

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
    _names2Friends[name].send(message);
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
    _messages = List();
  }

  void receive(String message) {
    _messages.add(Message(_name, message));
  }

  Future<void> send(String message) async {
    _messages.add(Message("Me", message));
    Socket socket = await Socket.connect(_ipAddr, ourPort);
    socket.write(message);
    socket.close();
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