import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phone = TextEditingController();
  final pass = TextEditingController();

  @override
  void dispose() {
    phone.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk ke SanTix')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === Nomor Handphone ===
            const Text('Nomor Handphone'),
            const SizedBox(height: 6),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              ],
              decoration: const InputDecoration(hintText: '08123xxxxxxx'),
            ),
            const SizedBox(height: 16),

            // === Password ===
            const Text('Password'),
            const SizedBox(height: 6),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Masukkan password'),
            ),
            const SizedBox(height: 12),

            // === Lupa password ===
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.resetPassword),
                child: const Text('Reset Password'),
              ),
            ),
            const SizedBox(height: 8),

            // === Tombol Sign in ===
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: validasi & proses login
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                child: const Text('Masuk'),
              ),
            ),

            const SizedBox(height: 24),

            // === Belum punya akun ===
            const Center(child: Text('Belum punya akun?')),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.register),
                child: const Text('Daftar Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
