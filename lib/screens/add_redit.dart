import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/account.dart';
import 'package:mini_redit/models/category.dart';
import 'package:mini_redit/models/decoration.dart';
import 'package:mini_redit/models/news.dart';
import 'package:mini_redit/providers/auth.dart';

class AddReditScreen extends ConsumerStatefulWidget {
  const AddReditScreen({super.key});

  @override
  ConsumerState<AddReditScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddReditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final _imageUrlController = TextEditingController();

  Set<CategoryType> _selectedCategories = {};
  bool _isAnonymous = false;
  int _likes = 0;

  final _dbService = DatabaseService();

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitNews() async {
    if (!_formKey.currentState!.validate()) return;

    final Account accout = ref.read(accountProvider).value!;
    if (!accout.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add a post')),
      );
      return;
    }

    final imageUrl = await _uploadImage(accout);

    final news = NewsRedit(
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      imageUrl: imageUrl,
      category: _selectedCategories.toList(),
      likes: _likes,
      acount: _isAnonymous ? null : accout,
      createdAt: DateTime.now(),
    );

    await _dbService.addMiniRedit(news, accout);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post added successfully!')));

    setState(() {
      _selectedImage = null;
      _titleController.clear();
      _textController.clear();
      _selectedCategories.clear();
    });
  }

  void _openCategorySheet() async {
    final result = await showModalBottomSheet<Set<CategoryType>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final tempSelected = Set<CategoryType>.from(_selectedCategories);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Select Categories",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: CategoryType.values.map((category) {
                        return CheckboxListTile(
                          title: Text(category.name),
                          value: tempSelected.contains(category),
                          onChanged: (bool? checked) {
                            setModalState(() {
                              if (checked == true) {
                                tempSelected.add(category);
                              } else {
                                tempSelected.remove(category);
                              }
                            });
                          },
                          activeColor: Colors.orange,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, tempSelected);
                    },
                    child: const Text(
                      "Done",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCategories = result;
      });
    }
  }

  Widget customRadioButton({
    required String label,
    required bool value,
    required bool groupValue,
    required ValueChanged<bool> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(Account account) async {
    if (_selectedImage == null) return null;

    try {
      setState(() => _isUploading = true);
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance
          .ref()
          .child('news_images')
          .child('${FirebaseAuth.instance.currentUser!.uid}_$id.jpg');

      await ref.putFile(_selectedImage!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error with uploading image $e')));
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedList = _selectedCategories.toList();
    final buttonDecoration = BoxDecoration(
      color: Colors.orange.shade700,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Mini Reddit Post'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: buildInputDecoration('Title'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _textController,
                decoration: buildInputDecoration('Text'),
                maxLines: 4,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter some text'
                    : null,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.add_a_photo,
                              color: Colors.orange,
                              size: 38,
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openCategorySheet,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: const Icon(
                        Icons.category_outlined,
                        color: Colors.orange,
                        size: 38,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 8,
                children: selectedList.isEmpty
                    ? [const Text("No categories selected")]
                    : selectedList
                          .map(
                            (cat) => Chip(
                              label: Text(
                                cat.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: Colors.orange.shade100,
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategories.remove(cat);
                                });
                              },
                            ),
                          )
                          .toList(),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  customRadioButton(
                    label: 'Anonymous',
                    value: true,
                    groupValue: _isAnonymous,
                    onChanged: (val) => setState(() => _isAnonymous = val),
                  ),
                  customRadioButton(
                    label: 'Public',
                    value: false,
                    groupValue: _isAnonymous,
                    onChanged: (val) => setState(() => _isAnonymous = val),
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _likes = 0;
                        _titleController.clear();
                        _textController.clear();
                        _selectedCategories.clear();
                        _isAnonymous = false;
                        _selectedImage = null;
                      });
                    },
                    child: Container(
                      width: 90,
                      height: 70,
                      decoration: buttonDecoration,
                      child: const Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _submitNews,
                    child: Container(
                      width: 90,
                      height: 70,
                      decoration: buttonDecoration,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
