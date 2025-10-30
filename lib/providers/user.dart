import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_redit/models/user.dart';



class UserDataNotifier extends StateNotifier<UserData> {
  UserDataNotifier() : super(UserData());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setSurname(String surname) {
    state = state.copyWith(surname: surname);
  }

  void setStart(String? email , String? password) {
    state = state.copyWith(email: email, password: password);
  }

  void setEnd(bool end) {
    state = state.copyWith(end: end);
  }

  void clear() {
    state = UserData();
  }
}

final userDataProvider = StateNotifierProvider<UserDataNotifier, UserData>((
  ref,
) {
  return UserDataNotifier();
});
