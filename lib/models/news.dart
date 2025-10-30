import 'package:mini_redit/models/account.dart';
import 'category.dart';

class NewsRedit {
  final String? id; 
  final List<CategoryType> category;
  final String? imageUrl;
  final String text;
  final String title;
  final int likes;
  final DateTime createdAt;
  final Account? acount;

  NewsRedit({
    this.id, 
    required this.category,
    required this.imageUrl,
    required this.text,
    required this.title,
    required this.acount,
    this.likes = 0,
    
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
