import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Armazenamento local (tipo localStorage) usando SharedPreferences.
class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('LocalStorage não inicializado. Chame LocalStorage.init() no main.');
    }
    return _prefs!;
  }

  // ─── String simples ─────────────────────────────────────
  static Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static String? getString(String key) => prefs.getString(key);

  static Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  // ─── Lista de mapas (JSON) ──────────────────────────────
  static Future<void> setList(String key, List<Map<String, dynamic>> list) async {
    final encoded = jsonEncode(list);
    await prefs.setString(key, encoded);
  }

  static List<Map<String, dynamic>> getList(String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ─── Sessão do usuário logado ───────────────────────────
  static Future<void> setCurrentUser(String email) async {
    await prefs.setString('current_user', email);
  }

  static String? getCurrentUser() => prefs.getString('current_user');

  static Future<void> clearCurrentUser() async {
    await prefs.remove('current_user');
  }
}
