import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/account.dart';

class AccountNotifier extends AsyncNotifier<Account?> {
  final _db = DatabaseService();

  @override
  Future<Account?> build() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    if (user.isAnonymous) {
      return Account("", "", false, null, "Guest");
    }
    final profile = await _db.getMyProfile();
    return profile ??
        Account(
          user.displayName ?? '',
          '',
          true,
          user.photoURL,
          user.email ?? '',
        );
  }

  Future<void> refreshProfile() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _db.getMyProfile());
  }

  Future<void> updateImage(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    await _db.updateProfilePhoto(imageUrl);
    await refreshProfile();
  }

  Future<void> createOrUpdateProfile(User user) async {
    state = const AsyncLoading();
    final profile = await _db.getMyProfile();

    if (profile == null) {
      final newAcc = Account(
        user.displayName ?? 'User',
        '',
        true,
        user.photoURL,
        user.email ?? '',
      );
      await _db.createProfile(user.uid, newAcc);
      state = AsyncData(newAcc);
    } else {
      state = AsyncData(profile);
    }
  }
}

final accountProvider = AsyncNotifierProvider<AccountNotifier, Account?>(
  () => AccountNotifier(),
);
