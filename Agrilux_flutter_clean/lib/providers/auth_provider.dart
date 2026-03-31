// lib/providers/auth_provider.dart
// Equivalente a src/lib/AuthContext.jsx

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = true;

  // Equivalente a: const { user, loading } = useAuth()
  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  final _db = FirebaseFirestore.instance;

  AuthProvider() {
    _loadFromStorage();
  }

  // Equivalente a useEffect(() => localStorage.getItem('agrilux_user'))
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('agrilux_user');
    if (stored != null) {
      _user = UserModel.fromJson(jsonDecode(stored));
    }
    _loading = false;
    notifyListeners();
  }

  // Equivalente a login()
  Future<void> _saveToStorage(UserModel u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agrilux_user', jsonEncode(u.toJson()));
  }

  void _setUser(UserModel u) {
    _user = u;
    _saveToStorage(u);
    notifyListeners();
  }

  // Equivalente a logout()
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('agrilux_user');
    _user = null;
    notifyListeners();
  }

  // Equivalente a registerUser()
  Future<UserModel> registerUser(Map<String, dynamic> data) async {
    final code = _generateCode();
    final docRef = await _db.collection('usuarios').add({
      ...data,
      'createdAt': DateTime.now().toIso8601String(),
      'tipo': data['tipo'] ?? 'agricultor',
      'codigo': code,
    });
    final u = UserModel.fromJson({'id': docRef.id, ...data, 'codigo': code});
    _setUser(u);
    return u;
  }

  // Equivalente a loginWithCode()
  Future<UserModel> loginWithCode(String whatsapp, String code) async {
    final snap = await _db
        .collection('usuarios')
        .where('whatsapp', isEqualTo: whatsapp)
        .where('codigo', isEqualTo: code)
        .get();

    if (snap.docs.isEmpty) {
      throw Exception('Código incorrecto o número no registrado');
    }

    final u = UserModel.fromJson({
      'id': snap.docs.first.id,
      ...snap.docs.first.data(),
    });
    _setUser(u);
    return u;
  }

  // Genera código aleatorio de 6 caracteres
  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      6,
      (i) => chars[(rand ~/ (i + 1)) % chars.length],
    ).join();
  }
}
