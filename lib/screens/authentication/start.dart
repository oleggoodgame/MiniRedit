import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_redit/providers/onBoardib.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController(); // що це робить?
  int _currentPage = 0;

  final Color orange = Colors.orange;
  final Color bg = Colors.black;

  void _finishOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              // що це таке?
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildFirstPage(),
                _buildSecondPage(),
                _buildThirdPage(),
              ],
            ),
          ),
          _buildPageIndicator(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFirstPage() {
    return _buildBasePage(
      title: "Hello 👋",
      buttonText: "Start",
      onButtonPressed: () => _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildSecondPage() {
    return _buildBasePage(
      title: "MiniRedit",
      subtitle:
          "Your space for thoughts, stories, and experiences. Share with others easily and quickly!",
      buttonText: "Next",
      extraText: "skip", // що це таке?
      onExtraTap: _finishOnboarding, // що це таке
      onButtonPressed: () => _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildThirdPage() {
    return _buildBasePage(
      title: "Let's go now",
      subtitle: "Log in or create an account to continue",
      customContent: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('see', true);
              if (mounted) context.go('/login');
            },
            child: const Text("Log in"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('see', true);
              if (mounted) context.go('/signup');
            },
            child: const Text("Registration"),
          ),
        ],
      ),
    );
  }

  Widget _buildBasePage({
    required String title,
    String subtitle = "",
    String? buttonText,
    String? extraText,
    VoidCallback? onButtonPressed,
    VoidCallback? onExtraTap, // що робить це
    Widget? customContent,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18),
              ),
            const SizedBox(height: 32),
            if (customContent != null)
              customContent
            else if (buttonText != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(180, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onButtonPressed,
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            const SizedBox(height: 16),
            if (extraText != null)
              GestureDetector(
                onTap: onExtraTap,
                child: Text(
                  extraText,
                  style: GoogleFonts.poppins(
                    color: Colors.orangeAccent,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.orange : Colors.orange.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
