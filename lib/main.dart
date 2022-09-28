import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:network_info_plus/network_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:text_messenger/data.dart';

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
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _ipaddress = "Loading...";
  Friends _friends;
  String _currentFriend;
  List<DropdownMenuItem<String>> _friendList;
  TextEditingController _nameController, _ipController, _sendController;

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
    String ip = await NetworkInfo().getWifiIP();
    setState(() {
      _ipaddress = "My IP: " + ip;
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

  void updateFriendList(String selectedFriend) {
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
                makeTextEntry(200, "Name", TextInputType.text, _nameController),
                makeTextEntry(
                    200, "IP Address", TextInputType.number, _ipController),
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
        Text(_ipaddress),
        DropdownButton(
          value: _currentFriend,
          items: _friendList,
          onChanged: updateFriendList,
        ),
        historyBox(),
        makeActionText(200, "Send to $_currentFriend", TextInputType.text,
            _sendController, send),
      ],
    );
  }

  Widget makeTextEntry(double width, String label, TextInputType inType,
      TextEditingController controller) {
    return makeActionText(width, label, inType, controller, (s) {});
  }

  Widget makeActionText(double width, String label, TextInputType inType,
      TextEditingController controller, void Function(String) handler) {
    return SizedBox(
        width: width,
        child: TextField(
          controller: controller,
          keyboardType: inType,
          onSubmitted: handler,
          decoration: InputDecoration(labelText: label),
        ));
  }

  Widget historyBox() {
    // Concept from:  https://stackoverflow.com/questions/49638499/how-to-make-the-scrollable-text-in-flutter
    String msg = _friends.hasFriend(_currentFriend)
        ? _friends.historyFor(_currentFriend)
        : "None";
    return Expanded(flex: 1, child: SingleChildScrollView(child: Text(msg)));
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
