import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController();
    final phone = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar SanTix')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: name,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(hintText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Nomor Handphone'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Buat Akun'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
