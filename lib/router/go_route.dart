import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/category.dart';
import 'package:mini_redit/models/news.dart';
import 'package:mini_redit/providers/auth.dart';
import 'package:mini_redit/providers/user.dart';
import 'package:mini_redit/screens/add_redit.dart';
import 'package:mini_redit/screens/authentication/logIn.dart';
import 'package:mini_redit/screens/authentication/logup.dart';
import 'package:mini_redit/screens/authentication/logup_name.dart';
import 'package:mini_redit/screens/authentication/start.dart';
import 'package:mini_redit/screens/categories.dart';
import 'package:mini_redit/screens/comments.dart';
import 'package:mini_redit/screens/edit_profile.dart';
import 'package:mini_redit/screens/favorite.dart';
import 'package:mini_redit/screens/redit.dart';
import 'package:mini_redit/screens/redit_choosen.dart';
import 'package:mini_redit/screens/tabs.dart';
import 'package:mini_redit/widgets/redit_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(accountProvider).value?.isLoggedIn ?? false;
  final userData = ref.watch(userDataProvider);
  final firebaseUser = FirebaseAuth.instance.currentUser;
  // final onboardingAsync = ref.watch(onboardingProvider);

  final bool isAnonymous = firebaseUser?.isAnonymous ?? false;
  Future<bool> get() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('see') ?? false;
    return seen;
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: (context, state) async{
      final loggingIn = state.uri.path == '/login';
      final signingUp = state.uri.path == '/signup';
      final signingUpEnd = state.uri.path == '/signup_end';
      print(userData.end);
      print(userData.email);
      final seen = await get();
      if (!seen) return '/onboarding';
      if (isAnonymous) return '/categories';
      if (userData.end) {
        return '/signup_end';
      }
      if (!isLoggedIn && userData.end && signingUpEnd) return null;

      // if (!isLoggedIn && !loggingIn && !signingUp && !signingUpEnd) {
      //   return '/login';
      // }

      if (isLoggedIn && (loggingIn || signingUp || signingUpEnd)) {
        return '/categories';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        name: 'signup_end',
        path: '/signup_end',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EndSignUp(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      ShellRoute(
        builder: (context, state, child) => TabsScreen(),
        routes: [
          GoRoute(
            path: "/add",
            builder: (context, state) => const AddReditScreen(),
          ),
          GoRoute(
            path: "/categories",
            builder: (context, state) => const CategoriesScreen(),
            routes: [
              GoRoute(
                path: "/redit",
                name: "redit",
                parentNavigatorKey: rootNavigatorKey, // правильно
                builder: (context, state) {
                  final category = state.extra as Category;
                  print(category);
                  print("WORK");
                  return ReditScreen(category: category);
                },
              ),
              GoRoute(
                path: "/redit_choosen",
                name: "redit_choosen",
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  final category = extra['category'] as CategoryType;
                  final id = extra['id'] as String;

                  return ReditChoosenScreen(
                    region: "ukr",
                    category: category,
                    id: id,
                  );
                },
                routes: [
                  GoRoute(
                    name: "comments",
                    path: "/comments",
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final redit = state.extra as NewsRedit;
                      return CommentsScreen(news: redit);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: "/favorite",
        name: "favorite",
        builder: (context, state) {
          return FavoriteScreen();
        },
      ),
      GoRoute(
        path: '/redit_choosen_url',
        name: 'redit_url',
        builder: (context, state) {
          final region = state.uri.queryParameters['region'];
          final category = state.uri.queryParameters['category'];
          final id = state.uri.queryParameters['id'];

          if (region == null || category == null || id == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid link: missing parameters')),
            );
          }
          final isLoggedIn =
              ref.watch(accountProvider).value?.isLoggedIn ?? false;

          if (!isLoggedIn) {
            return const Scaffold(
              body: Center(
                child: Text('You must be logged in to view this content'),
              ),
            );
          }
          CategoryType? categoryType;
          try {
            categoryType = CategoryType.values.byName(category);
          } catch (e) {
            // Якщо categoryParam не співпадає з жодним enum
            return Scaffold(
              body: Center(child: Text('Invalid category: $category')),
            );
          }
          return FutureBuilder(
            future: DatabaseService().getMiniRedit(region, category, id),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: Text('No data found')),
                    );
                  }

                  final redit = snapshot.data!;
                  return ReditViewWidget(redit: redit, category: categoryType!);
                default:
                  return const Scaffold(
                    body: Center(child: Text('Unexpected state')),
                  );
              }
            },
          );
        },
      ),
    ],
  );
});
