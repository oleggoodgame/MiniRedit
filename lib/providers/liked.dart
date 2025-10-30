import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/category.dart';

class LikedPostsNotifier extends StateNotifier<Set<String>> {
  final DatabaseService _db;
  LikedPostsNotifier(this._db) : super({});

  /// Ініціалізація лайків з Firebase
  Future<void> loadLikedPosts() async {
    final likedIds = await _db.getLikedMiniRedit();
    state = likedIds.toSet();
  }

  /// Перемикає лайк і одразу оновлює Firebase
  Future<bool> toggleLike(String postId, List<CategoryType> categories, WidgetRef ref) async {
    final updated = {...state};
    bool liked;

    if (updated.contains(postId)) {
      updated.remove(postId);
      liked = false;
    } else {
      updated.add(postId);
      liked = true;
    }

    state = updated;

    // оновлення у Firebase
    await _db.likeMiniRedit(postId, categories, ref);

    return liked;
  }

  bool isLiked(String postId) => state.contains(postId);
}

final likedPostsProvider =
    StateNotifierProvider<LikedPostsNotifier, Set<String>>((ref) {
  final db = DatabaseService();
  final notifier = LikedPostsNotifier(db);
  notifier.loadLikedPosts(); // одразу підтягує лайки користувача
  return notifier;
});
