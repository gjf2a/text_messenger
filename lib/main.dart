import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:network_info_plus/network_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:text_messenger/data.dart';
import 'package:text_messenger/text_widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Network Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _ipaddress = "Loading...";
  late Friends _friends;
  String? _currentFriend;
  late List<DropdownMenuItem<String>> _friendList;
  late TextEditingController _nameController, _ipController, _sendController;

  void initState() {
    super.initState();
    _friends = Friends();
    _friends.add("Self", "127.0.0.1");
    _currentFriend = "Self";
    print("currentFriend: $_currentFriend");
    _nameController = TextEditingController(text: _currentFriend);
    _ipController =
        TextEditingController(text: _friends.ipAddr(_currentFriend));
    _sendController = TextEditingController();
    _setupServer();
    _findIPAddress();
  }

  Future<void> _findIPAddress() async {
    // Thank you https://stackoverflow.com/questions/52411168/how-to-get-device-ip-in-dart-flutter
    String? ip = await NetworkInfo().getWifiIP();
    setState(() {
      _ipaddress = "My IP: " + ip!;
    });
  }

  Future<void> _setupServer() async {
    try {
      ServerSocket server =
          await ServerSocket.bind(InternetAddress.anyIPv4, ourPort);
      server.listen(_listenToSocket); // StreamSubscription<Socket>
    } on SocketException catch (e) {
      _sendController.text = e.message;
    }
  }

  void _listenToSocket(Socket socket) {
    socket.listen((data) {
      setState(() {
        _handleIncomingMessage(socket.remoteAddress.address, data);
      });
    });
  }

  void _handleIncomingMessage(String ip, Uint8List incomingData) {
    String received = String.fromCharCodes(incomingData);
    print("Received '$received' from '$ip'");
    _friends.receiveFrom(ip, received);
    _currentFriend = _friends.getName(ip);
  }

  // From https://medium.com/@boldijar.paul/comboboxes-in-flutter-cabc9178cc95
  List<DropdownMenuItem<String>> makeFriendList() {
    print("making friend list");
    List<DropdownMenuItem<String>> items = [];
    for (String friend in _friends) {
      items.add(DropdownMenuItem(value: friend, child: Text(friend)));
    }
    print("${items.length} friends");
    return items;
  }

  void updateFriendList(String? selectedFriend) {
    setState(() {
      _currentFriend = selectedFriend;
    });
  }

  void addNew() {
    setState(() {
      _friends.add(_nameController.text, _ipController.text);
      _currentFriend = _nameController.text;
    });
  }

  final ButtonStyle yesStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), backgroundColor: Colors.green);
  final ButtonStyle noStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), backgroundColor: Colors.red);

  Future<void> _displayTextInputDialog(BuildContext context) async {
    print("Loading Dialog");
    _nameController.text = "";
    _ipController.text = "";
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add A Friend'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextEntry(
                    width: 200,
                    label: "Name",
                    inType: TextInputType.text,
                    controller: _nameController),
                TextEntry(
                    width: 200,
                    label: "IP Address",
                    inType: TextInputType.number,
                    controller: _ipController),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                key: const Key("CancelButton"),
                style: noStyle,
                child: const Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                key: const Key("OKButton"),
                style: yesStyle,
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    addNew();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _mainScreen(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog(context);
        },
        tooltip: 'Add Friend',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _mainScreen(BuildContext context) {
    _friendList = makeFriendList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 10.0),
        Text(_ipaddress!),
        DropdownButton(
          value: _currentFriend,
          items: _friendList,
          onChanged: updateFriendList,
        ),
        ScrollText(text: _friends.historyFor(_currentFriend)),
        ActionText(
            width: 200,
            label: "Send to $_currentFriend",
            inType: TextInputType.text,
            controller: _sendController,
            handler: send),
      ],
    );
  }

  Future<void> send(String msg) async {
    String response = await _sendToCurrentFriend(msg);
    setState(() {
      _sendController.text = response;
    });
  }

  Future<String> _sendToCurrentFriend(String msg) async {
    if (_friends.hasFriend(_currentFriend)) {
      return _friends
          .sendTo(_currentFriend, msg)
          .then((value) => "")
          .catchError((e) => "Error: $e");
    } else {
      return "Can't send to $_currentFriend";
    }
  }
}
