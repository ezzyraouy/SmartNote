import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'services/notes_service.dart';
import 'services/search_service.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => NotesService()),

        // SearchService depends on environment variables
        Provider<SearchService>(
          create: (_) => SearchService(
            const String.fromEnvironment('ALGOLIA_APP_ID', defaultValue: 'CWG6L0202M'),
            const String.fromEnvironment('ALGOLIA_SEARCH_KEY', defaultValue: 'a689cbaab3b5ac383f03d45aa8dd2665'),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return MaterialApp(
      title: 'SmartNote',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: authService.isAuthenticated
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
