import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mini_redit/models/account.dart';
import 'package:mini_redit/models/category.dart';
import 'package:mini_redit/models/comments.dart';
import 'package:mini_redit/models/news.dart';
import 'package:mini_redit/providers/liked.dart';
import 'package:mini_redit/providers/user.dart';
import 'package:mini_redit/secrets_key_gh.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> addMiniRedit(NewsRedit news, Account account) async {
    final id = _db.collection('miniRedit').doc().id;

    for (final ctg in news.category) {
      final docRef = _db
          .collection("miniRedit")
          .doc("ukr")
          .collection(ctg.name)
          .doc(id);

      await docRef.set({
        'id': id,
        'title': news.title,
        'text': news.text,
        'imageUrl': news.imageUrl,
        'category': news.category.map((c) => c.name).toList(),
        'likes': news.likes,
        'createdAt': news.createdAt.toIso8601String(),
        'account': {
          'name': account.name,
          'surname': account.surname,
          'email': account.email,
          'isLoggedIn': account.isLoggedIn,
          'imageUrl': account.imageUrl,
        },
      });
    }
  }

  List<CategoryType> _mapListToCategory(List<dynamic> categories) {
    return categories.map((ctg) {
      return CategoryType.values.firstWhere(
        (c) => c.name == ctg,
        orElse: () => CategoryType.politics,
      );
    }).toList();
  }

  Stream<List<NewsRedit>> getMiniReditByCategory(CategoryType category) {
    return _db
        .collection("miniRedit")
        .doc("ukr")
        .collection(category.name)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final accountData = data['account'] ?? {};
            return NewsRedit(
              id: data['id'] ?? doc.id,
              title: data['title'] ?? '',
              text: data['text'] ?? '',
              imageUrl: data['imageUrl'],
              category: _mapListToCategory(
                List<String>.from(data['category'] ?? []),
              ),
              likes: data['likes'] ?? 0,
              createdAt:
                  DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
              acount: Account(
                accountData['name'] ?? 'Unknown',
                accountData['surname'] ?? '',
                accountData['isLoggedIn'] ?? false,
                accountData['imageUrl'],
                accountData['email'] ?? '',
              ),
            );
          }).toList();
        });
  }

  Future<Account?> getMyProfile() async {
    final userId = user?.uid;

    return _db.collection("users").doc(userId).get().then((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        return Account(
          data['name'] ?? 'Unknown',
          data['surname'] ?? '',
          data['isLoggedIn'] ?? false,
          data['imageUrl'],
          data['email'] ?? '',
        );
      } else {
        return null;
      }
    });
  }

  Future<void> createProfile(String uid, Account account) async {
    await _db.collection("users").doc(uid).set({
      'name': account.name,
      'surname': account.surname,
      'email': account.email,
      'isLoggedIn': account.isLoggedIn,
      'imageUrl': account.imageUrl,
    });
  }

  Future<void> updateProfilePhoto(String image) async {
    final userId = user?.uid;

    await _db.collection("users").doc(userId).set({
      "imageUrl": image,
    }, SetOptions(merge: true));
  }

  Future<void> updateProfile(String name, String surname) async {
    final userId = user?.uid;

    await _db.collection("users").doc(userId).set({
      "name": name,
      "surname": surname,
    }, SetOptions(merge: true));
  }

  Future<void> likeMiniRedit(
    String id,
    List<CategoryType> categories,
    WidgetRef ref,
  ) async {
    final isLiked = ref.read(likedPostsProvider.notifier).isLiked(id);
    if (isLiked) {
      for (final ctg in categories) {
        final docRef = _db
            .collection("miniRedit")
            .doc("ukr")
            .collection(ctg.name)
            .doc(id);

        await _db.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (!snapshot.exists) {
            throw Exception("Document does not exist!");
          }

          final currentLikes = snapshot.get('likes') ?? 0;
          transaction.update(docRef, {'likes': currentLikes + 1});
        });
      }

      await _db.collection("users").doc(user?.uid).set({
        "likedMiniRedit": FieldValue.arrayUnion([id]),
      }, SetOptions(merge: true));
    } else {
      for (final ctg in categories) {
        final docRef = _db
            .collection("miniRedit")
            .doc("ukr")
            .collection(ctg.name)
            .doc(id);

        await _db.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (!snapshot.exists) {
            throw Exception("Document does not exist!");
          }

          final currentLikes = snapshot.get('likes') ?? 0;
          transaction.update(docRef, {'likes': currentLikes - 1});
        });
      }
      await _db.collection("users").doc(user?.uid).set({
        "likedMiniRedit": FieldValue.arrayRemove([id]),
      }, SetOptions(merge: true));
    }
  }

  Future<List<String>> getLikedMiniRedit() async {
    final userId = user?.uid;

    final doc = await _db.collection("users").doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return List<String>.from(data['likedMiniRedit'] ?? []);
    } else {
      return [];
    }
  }

  Future<void> deleteMiniRedit(String id, List<CategoryType> category) async {
    for (final ctg in category) {
      final docRef = _db
          .collection("miniRedit")
          .doc("ukr")
          .collection(ctg.name)
          .doc(id);

      await docRef.delete();
    }
  }

  Stream<List<Comments>> getComments(NewsRedit news) {
    return _db
        .collection("comments")
        .doc(news.id)
        .collection("comments")
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Comments(
              id: data['id'] ?? doc.id,
              text: data['text'] ?? '',
              author: data['author'] ?? 'Anonymous',
              email: data['authorEmail'] ?? 'Anonymous',
              createdAt:
                  DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
            );
          }).toList();
        });
  }

  Future<void> addComment(Comments comments, NewsRedit news) async {
    final commentsCollection = _db
        .collection("comments")
        .doc(news.id)
        .collection("comments");

    final docRef = commentsCollection.doc();
    final countRef = commentsCollection.doc("commentsCount");

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(countRef);
      final currentCount = snapshot.exists
          ? (snapshot.data()?['comments'] ?? 0)
          : 0;

      transaction.set(docRef, {
        'id': docRef.id,
        'text': comments.text,
        'author': comments.author,
        'authorEmail': user?.email ?? 'Anonymous',
        'createdAt': comments.createdAt.toIso8601String(),
      });

      transaction.set(countRef, {'comments': currentCount + 1});
    });
  }

  Future<void> deleteComment(Comments comment, NewsRedit news) async {
    final commentsCollection = _db
        .collection("comments")
        .doc(news.id)
        .collection("comments");

    final docRef = commentsCollection.doc(comment.id);
    final countRef = commentsCollection.doc("commentsCount");

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(countRef);
      final currentCount = snapshot.exists
          ? (snapshot.data()?['comments'] ?? 0)
          : 0;

      transaction.delete(docRef);

      transaction.set(countRef, {
        'comments': currentCount > 0 ? currentCount - 1 : 0,
      });
    });
  }

  Stream<int> getCommentCount(String newsId) {
    final countRef = _db
        .collection("comments")
        .doc(newsId)
        .collection("comments")
        .doc("commentsCount");

    return countRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return 0;
      return snapshot.data()?['comments'] ?? 0;
    });
  }

  Future<NewsRedit> getMiniRedit(
    String region,
    String category,
    String id,
  ) async {
    final docSnap = await _db
        .collection("miniRedit")
        .doc(region)
        .collection(category)
        .doc(id)
        .get();

    if (!docSnap.exists) {
      throw Exception("NewsRedit not found");
    }

    final data = docSnap.data() as Map<String, dynamic>;

    final accountData = data['account'] ?? {};

    final account = Account(
      accountData['name'] ?? 'Unknown',
      accountData['surname'] ?? '',
      accountData['isLoggedIn'] ?? false,
      accountData['imageUrl'],
      accountData['email'] ?? '',
    );

    final categories =
        (data['category'] as List<dynamic>?)
            ?.map(
              (ctg) => CategoryType.values.firstWhere(
                (c) => c.name == ctg,
                orElse: () => CategoryType.politics,
              ),
            )
            .toList() ??
        [];

    return NewsRedit(
      id: data['id'] ?? docSnap.id,
      title: data['title'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      category: categories,
      likes: data['likes'] ?? 0,
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      acount: account,
    );
  }

  Future<void> updateFavoriteNews(
    String category,
    String id,
    bool addToFavorites,
  ) async {
    final userId = user?.uid;
    if (userId == null) return;

    final field = 'favoriteMiniRedit';
    final favoriteObj = {'region': 'ukr', 'category': category, 'id': id};

    if (addToFavorites) {
      await _db.collection("users").doc(userId).set({
        field: FieldValue.arrayUnion([favoriteObj]),
      }, SetOptions(merge: true));
    } else {
      await _db.collection("users").doc(userId).set({
        field: FieldValue.arrayRemove([favoriteObj]),
      }, SetOptions(merge: true));
    }
  }

  Future<List<NewsRedit>> getFavoriteNews() async {
    final userId = user?.uid;
    if (userId == null) return [];

    final doc = await _db.collection("users").doc(userId).get();
    if (!doc.exists) return [];

    final data = doc.data()!;
    final favoritesData = List<Map<String, dynamic>>.from(
      data['favoriteMiniRedit'] ?? [],
    );

    final List<NewsRedit> favorites = [];
    for (var fav in favoritesData) {
      final region = fav['region'] as String;
      final category = fav['category'] as String;
      final id = fav['id'] as String;

      final redit = await getMiniRedit(region, category, id);
      favorites.add(redit);
    }

    return favorites;
  }

  Future<
    ({UserCredential userCredential, bool isNewUser})?
  > // сюди додати ref, і через ref передати дані про емейл, і додати перевірку у edit Profile, чи акаунт через гугл чи ні
  signInWithGoogle(WidgetRef ref) async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            Google,
      );

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();
      if (googleUser == null) {
      print("ℹ️ Користувач скасував вхід через Google");
      return null;
    }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final uid = userCredential.user?.uid;
      bool isNewUser = false;

      if (uid != null) {
        final userDoc = await _db.collection('users').doc(uid).get();
        if (!userDoc.exists) {
          ref.read(userDataProvider.notifier).setEnd(true);
          ref.read(userDataProvider.notifier).setStart(userCredential.user?.email, null);
          isNewUser = true;
        }
      }

      return (userCredential: userCredential, isNewUser: isNewUser);
    } catch (e, st) {
      print("❌ Google sign-in error: $e");
      rethrow;
    }
  }
}
