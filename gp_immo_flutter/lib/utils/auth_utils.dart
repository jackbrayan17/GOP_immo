import 'dart:convert';

import 'package:crypto/crypto.dart';

const String _passwordSalt = 'gop_immo_salt';

String hashPassword(String password) {
  final bytes = utf8.encode('$_passwordSalt:$password');
  return sha256.convert(bytes).toString();
}

bool verifyPassword(String password, String storedHash) {
  if (storedHash.isEmpty) return false;
  return hashPassword(password) == storedHash;
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
