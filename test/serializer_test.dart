import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:text_messenger/serializer.dart';

void main() {
  test('convert', () {
    UserStampedMessage msg = UserStampedMessage("This is a test", User("Gabriel Ferrer", "Professor"));
    Map<String,dynamic> msgJson = msg.toJson();
    String msgStr = jsonEncode(msgJson);
    // Send it over a network, receive it, rebuild it.
    Map<String,dynamic> decodedMap = jsonDecode(msgStr);
    expect(msgJson, decodedMap);
    UserStampedMessage recovered = UserStampedMessage.fromJson(decodedMap);
    expect(recovered, msg);
  });
}