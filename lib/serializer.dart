class User {
  String _name;
  String _title;

  User(this._name, this._title);

  bool operator ==(Object other) =>
      other is User && other.name == name && other.title == title;

  String get name => _name;
  String get title => _title;

  Map<String, dynamic> toJson() => {
        'name': _name,
        'title': _title,
      };

  User.fromJson(Map<String, dynamic> json)
      : _name = json['name'],
        _title = json['title'];
}

class UserStampedMessage {
  String _message;
  User _user;

  UserStampedMessage(this._message, this._user);

  bool operator ==(Object other) =>
      other is UserStampedMessage &&
      other.message == message &&
      other.user == user;

  String get message => _message;
  User get user => _user;

  Map<String, dynamic> toJson() =>
      {'message': _message, 'user': _user.toJson()};

  UserStampedMessage.fromJson(Map<String, dynamic> json)
      : _message = json['message'],
        _user = User.fromJson(json['user']);
}
