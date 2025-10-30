import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_redit/data/data.dart';
import 'package:mini_redit/models/category.dart';
import 'package:mini_redit/widgets/grid_view_item.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _selectCategory(BuildContext context, Category category) {
    print("SSS");

    context.pushNamed("redit", extra: category);//ця частина коду не працює

    print("FFF");
  }

  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      children: [
        for (final category in availableCategories)
          CategoryGridItem(
            category: category,
            onSelectCategory: () {
              print("WWW");
              _selectCategory(context, category);
            },
          ),
      ],
    );
  }
}
