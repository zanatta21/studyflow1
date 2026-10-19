import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'local_storage.dart';

class AuthService extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  String? get userEmail => _user?['email'] as String?;
  String? get userName => _user?['name'] as String?;
  String get userId => _user?['email'] as String? ?? '';

  AuthService() {
    _restoreSession();
  }

  void _restoreSession() {
    final email = LocalStorage.getCurrentUser();
    if (email == null) return;
    final users = LocalStorage.getList('users');
    final found = users.where((u) => u['email'] == email).toList();
    if (found.isNotEmpty) {
      _user = found.first;
      notifyListeners();
    }
  }

  String _hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));

      final users = LocalStorage.getList('users');
      final emailTrim = email.trim().toLowerCase();
      final found = users.where((u) => u['email'] == emailTrim).toList();

      if (found.isEmpty) {
        _errorMessage = 'Usuário não encontrado.';
        return false;
      }
      final user = found.first;
      if (user['password'] != _hash(password)) {
        _errorMessage = 'Senha incorreta.';
        return false;
      }
      _user = user;
      await LocalStorage.setCurrentUser(emailTrim);
      return true;
    } catch (_) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));

      final users = LocalStorage.getList('users');
      final emailTrim = email.trim().toLowerCase();

      if (users.any((u) => u['email'] == emailTrim)) {
        _errorMessage = 'Este e-mail já está em uso.';
        return false;
      }
      if (password.length < 6) {
        _errorMessage = 'A senha deve ter pelo menos 6 caracteres.';
        return false;
      }

      final newUser = {
        'name': name.trim(),
        'email': emailTrim,
        'password': _hash(password),
      };
      users.add(newUser);
      await LocalStorage.setList('users', users);
      _user = newUser;
      await LocalStorage.setCurrentUser(emailTrim);
      return true;
    } catch (_) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await LocalStorage.clearCurrentUser();
    notifyListeners();
  }
}
