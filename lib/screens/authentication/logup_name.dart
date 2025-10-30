import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/account.dart';
import 'package:mini_redit/models/decoration.dart';
import 'package:mini_redit/providers/user.dart';

class EndSignUp extends ConsumerStatefulWidget {
  const EndSignUp({super.key});

  @override
  ConsumerState<EndSignUp> createState() => _EndSignUpScreenState();
}

class _EndSignUpScreenState extends ConsumerState<EndSignUp> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final db = DatabaseService();

  Future<void> _onNext() async {
    if (_formKey.currentState!.validate()) {
      try {
        final name = _nameController.text.trim();
        final surname = _surnameController.text.trim();

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('No authenticated user');

        final isGoogleUser = user.providerData.any(
          (p) => p.providerId == 'google.com',
        );

        if (isGoogleUser) {
          final uid = user.uid;
          final email = user.email;

          await db.createProfile(
            uid,
            Account(name, surname, true, null, email!),
          );

          ref.read(userDataProvider.notifier).clear();
          if (context.mounted) context.go('/categories');
        }
        else {
          final userData = ref.read(userDataProvider);
          final email = userData.email;
          final password = userData.password;

          if (email == null || password == null) {
            throw Exception(
              'Missing email or password for normal registration',
            );
          }

          final userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);

          final uid = userCredential.user!.uid;
          await db.createProfile(
            uid,
            Account(name, surname, true, null, email),
          );

          ref.read(userDataProvider.notifier).clear();
          if (context.mounted) context.go('/categories');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.read(userDataProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up - Step 2')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        "Personal Data",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: buildInputDecoration("Name"),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Name is required'
                                : null,
                            onChanged: (val) => userNotifier.setName(val),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _surnameController,
                            decoration: buildInputDecoration("Surname"),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Surname is required'
                                : null,
                            onChanged: (val) => userNotifier.setSurname(val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: _onNext,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange, width: 2),
                        foregroundColor: Colors.orange,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('End registration'),
                    ),
                  ],
                ),
              ),
            ),

            // логотип MiniRedit
            Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    "assets/images/miniredit.png",
                    width: 35,
                    height: 35,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "MiniRedit",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
