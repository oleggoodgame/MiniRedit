import 'package:flutter/material.dart';

enum CategoryType {
  politics,
  food,
  home,
  family,
  outdoor,
  work,
  relationships,
  abroad,
  companies,
  holiday,
  education,
  health,
  sports,
  entertainment,
  technology,
}

class Category {
  final String id;
  final CategoryType type;
  final Color color;
  const Category({
    required this.id,
    required this.type,
    this.color = Colors.orange,
  });

  String get title => type.name[0].toUpperCase() + type.name.substring(1);
}
