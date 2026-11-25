import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// Memastikan pengguna sudah login; jika belum, mengarahkan ke [LoginScreen].
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) {
    return true;
  }
  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute<bool>(builder: (_) => const LoginScreen()),
  );
  return loggedIn ?? false;
}
