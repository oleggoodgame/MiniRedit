import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/comments.dart';
import 'package:mini_redit/models/decoration.dart';
import 'package:mini_redit/models/news.dart';
import 'package:mini_redit/providers/auth.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({required this.news, super.key});
  final NewsRedit news;
  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _controller = TextEditingController();
  final db = DatabaseService();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Comments>>(
              stream: db.getComments(widget.news),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (ctx, index) {
                    final comment = snapshot.data![index];
                    return ListTile(
                      onTap: () async {
                        if (comment.email ==
                            ref.read(accountProvider).value?.email) {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Comment'),
                              content: const Text(
                                'Are you sure you want to delete this comment?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (shouldDelete == true) {
                            db.deleteComment(comment, widget.news);
                          }
                        }
                      },
                      title: Text(comment.author ?? 'Anonymous'),
                      subtitle: Text(comment.text),
                      trailing: Text(
                        '${comment.createdAt.hour}:${comment.createdAt.minute}',
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: buildInputDecoration("Write a comment"),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    db.addComment(
                      Comments(
                        id: '',
                        text: _controller.text,
                        author:
                            ref.read(accountProvider).value?.name ??
                            'Anonymous',
                        createdAt: DateTime.now(),
                      ),
                      widget.news,
                    );
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
