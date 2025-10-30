class UserData {
  final String email;
  final String password;
  final String name;
  final String surname;
  final bool end;

  UserData({
    this.name = '',
    this.surname = '',
    this.email = '',
    this.password = '',
    this.end = false,
  });

  UserData copyWith({
    String? name,
    String? surname,
    String? email,
    String? password,
    bool? end,
  }) {
    return UserData(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      password: password ?? this.password,
      end: end ?? this.end,
    );
  }
}