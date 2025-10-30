import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
import 'package:mini_redit/database/firebase.dart';
import 'package:mini_redit/models/decoration.dart';
import 'package:mini_redit/providers/auth.dart';
// import 'package:mini_redit/secrets_key_gh.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final db = DatabaseService();

  InputDecoration buildInputPasswordDecoration(String label) {
    return buildInputDecoration(label).copyWith(
      suffixIcon: IconButton(
        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
    );
  }

  Widget buildAvatarButton({
    required String image,
    required String text,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(radius: 30, backgroundImage: AssetImage(image)),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      ref.invalidate(accountProvider);

      try {
        context.go('/categories');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loginAnonymous() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      ref.invalidate(accountProvider);
      context.go('/categories');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Future<void> signInWithGitHub() async {
  //   final clientId = GITHUB_CLIENT_ID;
  //   final clientSecret = GITHUB_CLIENT_SECRET;
  //   final redirectUrl = REDIRECT_URL;

  //   final url =
  //       'https://github.com/login/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUrl&scope=read:user%20user:email';

  //   final result = await FlutterWebAuth2.authenticate(
  //     url: url,
  //     callbackUrlScheme: 'myapp',
  //   );

  //   final code = Uri.parse(result).queryParameters['code'];
  //   final response = await http.post(
  //     Uri.parse('https://github.com/login/oauth/access_token'),
  //     headers: {'Accept': 'application/json'},
  //     body: {
  //       'client_id': clientId,
  //       'client_secret': clientSecret,
  //       'code': code,
  //     },
  //   );

  //   final accessToken = response.body;
  //   print('GitHub access token: $accessToken');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        "Login to Your Account",
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
                            controller: _emailController,
                            decoration: buildInputDecoration('Email'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: buildInputPasswordDecoration(
                              'Password',
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: _loginAnonymous,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange, width: 2),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
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
                      child: const Text('Sign in anonymously'),
                    ),
                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: _login,
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
                      child: const Text('Sign in'),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildAvatarButton(
                          image: 'assets/images/google.jpg',
                          text: 'Log In with Google',
                          onTap: () async {
                            final result = await db.signInWithGoogle(ref);

                            if (result == null) return;

                            if (result.isNewUser) {
                              context.go('/signup_end');
                            } else {
                              context.go('/categories');
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        buildAvatarButton(
                          image: 'assets/images/github.png',
                          text: 'Log In with Github',
                          onTap: () async {
                            // await signInWithGitHub();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: const Text(
                            " Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

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
