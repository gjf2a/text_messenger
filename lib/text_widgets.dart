import 'package:flutter/material.dart';

class ActionText extends StatelessWidget {
  const ActionText({
    super.key,
    required this.width,
    required this.label,
    required this.inType,
    required this.controller,
    required this.handler,
  });

  final double width;
  final String label;
  final TextInputType inType;
  final TextEditingController controller;
  final void Function(String) handler;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(6.0),
        child: SizedBox(
            width: this.width,
            child: TextField(
              controller: controller,
              keyboardType: inType,
              onSubmitted: handler,
              decoration: InputDecoration(labelText: label),
            )));
  }
}

class TextEntry extends StatelessWidget {
  const TextEntry({
    super.key,
    required this.width,
    required this.label,
    required this.inType,
    required this.controller,
  });

  final double width;
  final String label;
  final TextInputType inType;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ActionText(
        width: width,
        label: label,
        inType: inType,
        controller: controller,
        handler: (s) {});
  }
}
