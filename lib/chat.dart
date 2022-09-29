import 'package:flutter/material.dart';
import 'package:text_messenger/text_widgets.dart';

import 'data.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.friend});

  final Friend? friend;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _sendController;

  void initState() {
    super.initState();
    _sendController = TextEditingController();
    widget.friend!.addListener(update);
  }

  void dispose() {
    widget.friend!.removeListener(update);
    print("Goodbye");
    super.dispose();
  }

  void update() {
    print("New message!");
    setState(() {});
  }

  Future<void> send(String msg) async {
    await widget.friend!.send(msg).then((value) {
      setState(() {
        _sendController.text = "";
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentFriend = widget.friend!.name;
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with " + widget.friend!.name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScrollText(text: widget.friend!.history()),
          ActionText(
              width: 200,
              label: "Send to $currentFriend",
              inType: TextInputType.text,
              controller: _sendController,
              handler: send),
        ],
      ),
    );
  }
}
