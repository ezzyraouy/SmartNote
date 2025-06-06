import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? _status;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    emailController.text = authService.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final updated = await authService.updateProfile(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );

                setState(() {
                  _status = updated ? "Profile updated" : "Update failed";
                });
              },
              child: const Text("Update"),
            ),
            if (_status != null) Text(_status!),
          ],
        ),
      ),
    );
  }
}
