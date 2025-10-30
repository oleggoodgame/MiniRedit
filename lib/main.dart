import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_redit/firebase_options.dart';
import 'package:mini_redit/router/go_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('[main] Flutter binding initialized');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('[main] Firebase initialized');

  final appLinks = AppLinks();
  print('[main] AppLinks instance created');

  final initialUri = await appLinks.getInitialLink();
  print('[main] initialUri received: $initialUri');

  runApp(ProviderScope(child: MainApp(initialUri: initialUri)));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({this.initialUri, super.key});
  final Uri? initialUri;

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _pendingUri;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // Зберігаємо initialUri, щоб обробити його після mount
    _pendingUri = widget.initialUri;

    // Підписка на deep links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        print('[uriLinkStream] received uri = $uri');
        // Зберігаємо у pendingUri і обробимо у didChangeDependencies
        _pendingUri = uri;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleDeepLinkIfReady();
        });
      },
      onError: (err) {
        print('[uriLinkStream] ❌ Error: $err');
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Тут контекст вже "має" GoRouter
    _handleDeepLinkIfReady();
  }

  void _handleDeepLinkIfReady() {
    if (_pendingUri == null) return;

    final uri = _pendingUri!;
    _pendingUri = null; // Щоб не обробляти двічі

    final region = uri.queryParameters['region'];
    final id = uri.queryParameters['id'];
    final category = uri.queryParameters['category'];

    print(
      '[handleDeepLink] params -> region=$region, category=$category, id=$id',
    );

    if (region != null && category != null && id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final router = ref.read(routerProvider);
        router.goNamed(
          'redit_url',
          queryParameters: {'region': region, 'category': category, 'id': id},
          extra: null,
        );
      });
    } else {
      print('[handleDeepLink] ❌ Missing parameters');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.orange,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}
