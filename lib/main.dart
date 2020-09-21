import 'dart:io';

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
      theme: ThemeData(primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  Friends _friends;
  String _currentFriend;
  List<DropdownMenuItem<String>> _friendList;
  TextEditingController _nameController, _ipController, _sendController;
  Widget Function(BuildContext) _screenFunction;

  void initState() {
    super.initState();
    _screenFunction = _mainScreen;
    _friends = Friends();
    _friends.add("Self", "0.0.0.0");
    _currentFriend = "Self";
    print("currentFriend: $_currentFriend");
    _nameController = TextEditingController(text: _currentFriend);
    _ipController = TextEditingController(text: _friends.ipAddr(_currentFriend));
    ServerSocket.bind(InternetAddress.anyIPv4, ourPort)
        .then((server) => server.listen((socket) {
          socket.listen((data) {
            setState(() {
              String ip = socket.remoteAddress.toString();
              String received = String.fromCharCodes(data);
              print("Received '$received' from '$ip'");
              _friends.receiveFrom(ip, received);
              _currentFriend = _friends.getName(ip);
            });
          });
    }));
  }

  // From https://medium.com/@boldijar.paul/comboboxes-in-flutter-cabc9178cc95
  List<DropdownMenuItem<String>> makeFriendList() {
    print("making friend list");
    List<DropdownMenuItem<String>> items = new List();
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

  void addFriend() {
    setState(() {
      _nameController.text = "";
      _ipController.text = "";
      _screenFunction = _newFriendScreen;
    });
  }

  void addNew() {
    setState(() {
      _friends.add(_nameController.text, _ipController.text);
      _currentFriend = _nameController.text;
      _screenFunction = _mainScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _screenFunction(context),
        ),
    );
  }

  Widget _mainScreen(BuildContext context) {
    _friendList = makeFriendList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DropdownButton(
          value: _currentFriend,
          items: _friendList,
          onChanged: updateFriendList,
        ),
        RaisedButton(child: Text("Add Friend"), onPressed: addFriend,),
        historyBox(),
        makeActionText(200, "Send to $_currentFriend", _sendController, send),
      ],
    );
  }

  Widget _newFriendScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget> [
        makeTextEntry(100, "Name", _nameController),
        makeTextEntry(100, "IP Address", _ipController),
        RaisedButton(child: Text("Add"), onPressed: addNew),
      ],
    );
  }

  Widget makeTextEntry(double width, String label, TextEditingController controller) {
    return makeActionText(width, label, controller, (s) {});
  }

  Widget makeActionText(double width, String label, TextEditingController controller, void Function(String) handler) {
    return SizedBox(width: width,
        child: TextField(controller: controller, onSubmitted: handler,
          decoration: InputDecoration(labelText: label),));
  }

  Widget historyBox() {
    // Concept from:  https://stackoverflow.com/questions/49638499/how-to-make-the-scrollable-text-in-flutter
    String msg = _friends.hasFriend(_currentFriend) ? _friends.historyFor(_currentFriend) : "None";
    return Expanded(flex: 1, child: SingleChildScrollView(child: Text(msg)));
  }

  void send(String msg) {
    if (_friends.hasFriend(_currentFriend)) {
      print("Sending '$msg' to '$_currentFriend'");
      _friends.sendTo(_currentFriend, msg);
      setState(() {
        _sendController.text = "";
      });
    } else {
      print("Can't send to $_currentFriend");
      setState(() {
        _sendController.text = "Can't send to $_currentFriend";
      });
    }
  }
}
