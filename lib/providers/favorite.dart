import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/category.dart';
import 'package:mini_redit/models/news.dart';

class FavoriteNewsNotifier extends StateNotifier<List<NewsRedit>> {
  final DatabaseService _db;

  FavoriteNewsNotifier(this._db) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favorites = await _db.getFavoriteNews(); 
    state = favorites;
  }

  Future<bool> toggleFavorite(NewsRedit redit,CategoryType category, WidgetRef ref) async {
    final updated = [...state];
    bool isFavorite;

    final index = updated.indexWhere((item) => item.id == redit.id);
    if (index != -1) {
      updated.removeAt(index);
      isFavorite = false;
    } else {
      updated.add(redit);
      isFavorite = true;
    }

    state = updated;

    await _db.updateFavoriteNews(category.name,redit.id!, isFavorite); 
    return isFavorite;
  }

  bool isFavorite(String postId) => state.any((item) => item.id == postId);
}

final favoriteNewsProvider =
    StateNotifierProvider<FavoriteNewsNotifier, List<NewsRedit>>((ref) {
  final db = DatabaseService();
  return FavoriteNewsNotifier(db);
});
