import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_redit/providers/auth.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(accountProvider).value;
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: user?.imageUrl != null
                          ? NetworkImage(user!.imageUrl!)
                          : const AssetImage('assets/images/miniredit.png')
                                as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => context.push('/editProfile'),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.shade700,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.edit,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'MiniReddit User',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user != null ? 'View profile' : 'Login / Register',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.newspaper,
              color: currentRoute == '/categories'
                  ? Colors.orange
                  : Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'News',
              style: TextStyle(
                color: currentRoute == '/categories'
                    ? Colors.orange
                    : Theme.of(context).colorScheme.onBackground,
                fontWeight: currentRoute == '/categories'
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 20,
              ),
            ),
            onTap: () {
              if (currentRoute != '/categories') {
                context.go('/categories');
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: currentRoute == '/favorites'
                  ? Colors.orange
                  : Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Favorites',
              style: TextStyle(
                color: currentRoute == '/favorite'
                    ? Colors.orange
                    : Theme.of(context).colorScheme.onBackground,
                fontWeight: currentRoute == '/favorite'
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 20,
              ),
            ),
            onTap: () {
              if (currentRoute != '/favorite') {
                context.push('/favorite');
              }
            },
          ),
          Container(height: 1, color: Colors.grey),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: currentRoute == '/settings'
                  ? Colors.orange
                  : Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: currentRoute == '/settings'
                    ? Colors.orange
                    : Theme.of(context).colorScheme.onBackground,
                fontWeight: currentRoute == '/settings'
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 20,
              ),
            ),
            onTap: () {
              if (currentRoute != '/settings') {
                context.go('/settings');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined),
            title: Text(
              'Sign out',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              ref.invalidate(accountProvider);
            },
          ),
        ],
      ),
    );
  }
}
