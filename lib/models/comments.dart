
class Comments {
  final String? id;
  final String text;
  final String? author;
  final DateTime createdAt;
  final String email;

  Comments({
    this.id,
    required this.text,
    this.author,
    DateTime? createdAt,
    this.email = 'Anonymous',
  }) : createdAt = createdAt ?? DateTime.now();
}