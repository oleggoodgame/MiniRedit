import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_redit/models/user.dart';

class UserDataNotifier extends StateNotifier<UserData> {
  UserDataNotifier() : super(UserData());

  Future<void> setName(String name) async {
    state = state.copyWith(name: name);
  }

  Future<void> setSurname(String surname) async {
    state = state.copyWith(surname: surname);
  }

  void setStart(String? email, String? password) {
    state = state.copyWith(email: email, password: password);
  }

  // void setEnd(bool end) {
  //   state = state.copyWith(end: end);
  // }

  void clear() {
    state = UserData();
  }

  void toggle() {
    state = state.copyWith(isSigningUp: true);
  }
}

final userDataProvider = StateNotifierProvider<UserDataNotifier, UserData>((
  ref,
) {
  return UserDataNotifier();
});
