import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/news.dart';
import 'package:mini_redit/widgets/redit_choosen.dart';
import 'package:mini_redit/models/category.dart';

class ReditScreen extends StatelessWidget {
  ReditScreen({super.key, this.category});

  final Category? category;
  final db = DatabaseService();

  void _seletRedit(BuildContext context, String id, CategoryType category) {
    context.pushNamed("redit_choosen", extra: {"id": id, "category": category});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category!.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.orangeAccent, height: 2.0),
        ),
      ),
      body: StreamBuilder<List<NewsRedit>>(
        stream: db.getMiniReditByCategory(category!.type),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final newsList = snapshot.data ?? [];

          if (newsList.isEmpty) {
            return const Center(
              child: Text('No news found for this category.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: newsList.length,
            itemBuilder: (ctx, index) {
              final news = newsList[index];
              return GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ReditChoosenWidget(
                    imagenNetwork: news.imageUrl,
                    text: news.text,
                    title: news.title,
                    accountName: news.acount?.name,
                  ),
                ),
                onTap: () {
                  _seletRedit(context, news.id!, category!.type);
                },
              );
            },
          );
        },
      ),
    );
  }
}
