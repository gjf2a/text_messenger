import 'package:flutter_test/flutter_test.dart';
import 'package:text_messenger/data.dart';

void main() {
  test('one', () {
    Friends f = Friends();
    f.add("Self", "127.0.0.1");
    expect(f.ipAddr("Self"), "127.0.0.1");
  });
}