import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/providers/auth.dart';
import 'package:mini_redit/widgets/image_input.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final db = DatabaseService();

  File? _selectedImage;
  bool _isUploading = false;

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
      ),
      labelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: Colors.orange.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _uploadImage(String email) async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);

    try {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_images/$email.jpg',
      );
      await ref.putFile(_selectedImage!);
      final url = await ref.getDownloadURL();

      await db.updateProfilePhoto(url);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile image updated!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _saveProfile() async {
    db.updateProfile(_nameController.text, _surnameController.text);
    ref.invalidate(accountProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: accountAsync.when(
        data: (account) {
          if (account == null || account.email == "Guest") {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Будь ласка, увійдіть у свій акаунт,\nщоб редагувати профіль.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed('/login');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text("Увійти"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          _nameController.text = account.name;
          _surnameController.text = account.surname;
          _emailController.text = account.email;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ImageInput(
                        onPickImage: (image) async {
                          //
                          final imageRef = FirebaseStorage.instance
                              .ref('images')
                              .child(account.email);

                          final uploadTask = await imageRef.putFile(image);
                          final imageUrl = await uploadTask.ref
                              .getDownloadURL();

                          await ref
                              .watch(accountProvider.notifier)
                              .updateImage(imageUrl);
                          await ref
                              .watch(accountProvider.notifier)
                              .refreshProfile();
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (account.imageUrl != null
                                    ? NetworkImage(account.imageUrl!)
                                          as ImageProvider
                                    : null),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: account.imageUrl != null
                                ? NetworkImage(account.imageUrl!)
                                : null,
                            child: account.imageUrl == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isUploading)
                  const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: buildInputDecoration('Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _surnameController,
                  decoration: buildInputDecoration('Surname'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: buildInputDecoration('Email'),
                  readOnly: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await _uploadImage(account.email);
                    _saveProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
