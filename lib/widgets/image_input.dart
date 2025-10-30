import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onPickImage,
    this.child,
  });

  final void Function(File image) onPickImage;
  final Widget? child;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _checkPermissionsAndPick(ImageSource source) async {
     var cameraStatus = await Permission.camera.request();
    // var storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted) {
      _pickImage(source);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera or Storage permission denied")),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 80,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
  }

  void _chooseSource() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            // ListTile(
            //   leading: const Icon(Icons.camera_alt),
            //   title: const Text("Take a picture"),
            //   onTap: () {
            //     Navigator.of(ctx).pop();
            //     _checkPermissionsAndPick(ImageSource.camera);
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Choose from gallery"),
              onTap: () {
                Navigator.of(ctx).pop();
                _checkPermissionsAndPick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_selectedImage != null) {
      content = CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_selectedImage!),
      );
    } else if (widget.child != null) {
      content = widget.child!;
    } else {
      content = const Icon(Icons.person, size: 50);
    }

    return GestureDetector(
      onTap: _chooseSource,
      child: content,
    );
  }
}

