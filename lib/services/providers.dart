import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      _user = User.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _loading = true; notifyListeners();
    final res = await ApiService.post('/auth/login', {'email': email, 'password': password});
    _loading = false;
    if (res['success'] == true) {
      await ApiService.saveToken(res['token']);
      _user = User.fromJson(res['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(res['user']));
    }
    notifyListeners();
    return res;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String phone) async {
    _loading = true; notifyListeners();
    final res = await ApiService.post('/auth/register', {'name': name, 'email': email, 'password': password, 'phone': phone});
    _loading = false;
    if (res['success'] == true) {
      await ApiService.saveToken(res['token']);
      _user = User.fromJson(res['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(res['user']));
    }
    notifyListeners();
    return res;
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    _user = null;
    notifyListeners();
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _loading = false;
  double _total = 0;

  List<CartItem> get items => _items;
  bool get loading => _loading;
  double get total => _total;
  int get count => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> loadCart() async {
    _loading = true; notifyListeners();
    final res = await ApiService.get('/cart', auth: true);
    _loading = false;
    if (res['success'] == true) {
      _items = (res['data'] as List).map((i) => CartItem.fromJson(i)).toList();
      _total = double.tryParse(res['total']?.toString() ?? '0') ?? 0;
    }
    notifyListeners();
  }

  Future<bool> addToCart(int productId, int qty) async {
    final res = await ApiService.post('/cart', {'product_id': productId, 'quantity': qty}, auth: true);
    if (res['success'] == true) await loadCart();
    return res['success'] == true;
  }

  Future<bool> updateCart(int id, int qty) async {
    final res = await ApiService.put('/cart/$id', {'quantity': qty}, auth: true);
    if (res['success'] == true) await loadCart();
    return res['success'] == true;
  }

  Future<bool> removeFromCart(int id) async {
    final res = await ApiService.delete('/cart/$id', auth: true);
    if (res['success'] == true) await loadCart();
    return res['success'] == true;
  }

  Future<void> clearCart() async {
    await ApiService.delete('/cart', auth: true);
    _items = []; _total = 0; notifyListeners();
  }
}
