import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/category.dart';
import 'package:mini_redit/models/news.dart';
import 'package:mini_redit/providers/auth.dart';
import 'package:mini_redit/providers/favorite.dart';
import 'package:mini_redit/providers/liked.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ReditViewWidget extends ConsumerStatefulWidget {
  const ReditViewWidget({
    super.key,
    required this.category,
    required this.redit,
  });

  final NewsRedit redit;
  final CategoryType category;
  @override
  ConsumerState<ReditViewWidget> createState() => _ReditChoosenScreenState();
}

class _ReditChoosenScreenState extends ConsumerState<ReditViewWidget> {
  late int likes;
  final _db = DatabaseService();
  @override
  void initState() {
    super.initState();
    likes = widget.redit.likes;
  }

  @override
  Widget build(BuildContext context) {
    final favoriteRedits = ref.watch(favoriteNewsProvider);
    final likedPosts = ref.watch(likedPostsProvider);

    final isFavorite = favoriteRedits.any((r) => r.id == widget.redit.id);
    final isLiked = likedPosts.contains(widget.redit.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.redit.title),
        actions: [
          IconButton(
            onPressed: () async {
              final wasAdded = await ref
                  .read(favoriteNewsProvider.notifier)
                  .toggleFavorite(widget.redit, widget.category, ref);

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    wasAdded
                        ? 'Added to favorites ❤️'
                        : 'Removed from favorites 💔',
                  ),
                ),
              );
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween<double>(begin: 0.8, end: 1).animate(animation),
                child: child,
              ),
              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                key: ValueKey(isFavorite),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            widget.redit.imageUrl == null
                ? Image.asset('assets/images/miniredit.png')
                : Image.network(
                    widget.redit.imageUrl!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),
            Text(
              widget.redit.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: widget.redit.category
                  .map(
                    (cat) => Chip(
                      label: Text(
                        cat.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.orange.shade200,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.redit.text,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // темно-сірий фон
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 30,
                        icon: Icon(
                          isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          color: isLiked ? Colors.blueAccent : Colors.grey,
                        ),
                        onPressed: () async {
                          final liked = await ref
                              .read(likedPostsProvider.notifier)
                              .toggleLike(
                                widget.redit.id!,
                                widget.redit.category,
                                ref,
                              );

                          setState(() {
                            if (liked) {
                              likes++;
                            } else if (likes > 0) {
                              likes--;
                            }
                          });
                        },
                      ),
                      Text(
                        '$likes',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'likes',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // темно-сірий фон
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 30,
                        icon: const Icon(
                          Icons.comment_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          context.pushNamed("comments", extra: widget.redit);
                        },
                      ),
                      StreamBuilder<int>(
                        stream: _db.getCommentCount(widget.redit.id!),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Text(
                            '$count',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),

                      Text(
                        'comments',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.redit.acount!.email ==
                    ref.read(accountProvider).value?.email) ...[
                  Container(
                    height: 100,
                    width: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), // темно-сірий фон
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _db.deleteMiniRedit(
                              widget.redit.id!,
                              widget.redit.category,
                            );
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // темно-сірий фон
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 30,
                        icon: const Icon(Icons.share, color: Colors.grey),
                        onPressed: () async {
                          final link =
                              'https://url.example.mini_redit?region=ukr&category=${widget.redit.category[0]}&id=${widget.redit.id}';

                          try {
                            await Share.share(link);
                          } catch (e) {
                            await Clipboard.setData(ClipboardData(text: link));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Link copied to clipboard 📋'),
                              ),
                            );
                          }
                        },
                      ),
                      const Text(
                        'Share',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
