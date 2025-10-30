import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/category.dart';
import 'package:mini_redit/models/news.dart';
import 'package:mini_redit/widgets/redit_view.dart';

class ReditChoosenScreen extends ConsumerStatefulWidget {
  const ReditChoosenScreen({
    super.key,
    required this.region,
    required this.category,
    required this.id,
  });

  final String region;
  final CategoryType category;
  final String id;

  @override
  ConsumerState<ReditChoosenScreen> createState() => _ReditChoosenScreenState();
}

class _ReditChoosenScreenState extends ConsumerState<ReditChoosenScreen> {
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NewsRedit>(
      future: _db.getMiniRedit(widget.region, widget.category.name, widget.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
        return ReditViewWidget(redit: redit, category: widget.category,);
      },
    );
  }
}
