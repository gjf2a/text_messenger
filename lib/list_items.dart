import 'package:flutter/material.dart';
import 'package:text_messenger/friends_data.dart';

typedef FriendListChatCallback = Function(Friend item);
typedef FriendListEditCallback = Function(Friend item);

class FriendListItem extends StatelessWidget {
  FriendListItem({
    required this.friend,
    required this.onListTapped,
    required this.onListEdited,
  }) : super(key: ObjectKey(friend));

  final Friend friend;
  final FriendListChatCallback onListTapped;
  final FriendListEditCallback onListEdited;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      onTap: () {
        onListTapped(friend);
      },
      onLongPress: () {
        onListEdited(friend);
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(friend.name[0].toUpperCase()),
      ),
      title: Text(
        friend.name,
      ),
      subtitle: Text(friend.ipAddr),
    ));
  }
}
