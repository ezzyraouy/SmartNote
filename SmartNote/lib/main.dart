import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
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
      home: authService.isAuthenticated ? const HomeScreen() : const LoginScreen(),
    );
  }
}
