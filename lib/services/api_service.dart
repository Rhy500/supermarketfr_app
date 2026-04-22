/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  // ⚠️ Ganti sesuai server Laravel kamu
  // Emulator Android  : http://10.0.2.2:8000
  // Device fisik      : http://192.168.x.x:8000
  // Production        : https://api.supermarket.com
  static const baseUrl = 'http://192.168.1.2:8000';
  static const apiUrl  = '$baseUrl/api';
}

class ApiService {
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove('user_data');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Future<Map<String, dynamic>> get(String path, {bool auth = false, Map<String, String>? query}) async {
    try {
      var uri = Uri.parse('${AppConfig.apiUrl}$path');
      if (query != null && query.isNotEmpty) uri = uri.replace(queryParameters: query);
      final res = await http.get(uri, headers: await _headers(auth: auth)).timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa internet kamu.'};
    }
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = false}) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiUrl}$path'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa internet kamu.'};
    }
  }

  static Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {bool auth = false}) async {
    try {
      final res = await http.put(
        Uri.parse('${AppConfig.apiUrl}$path'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa internet kamu.'};
    }
  }

  static Future<Map<String, dynamic>> delete(String path, {bool auth = false}) async {
    try {
      final res = await http.delete(
        Uri.parse('${AppConfig.apiUrl}$path'),
        headers: await _headers(auth: auth),
      ).timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa internet kamu.'};
    }
  }

  static Future<Map<String, dynamic>> uploadFile(String path, String filePath, String fieldName, {Map<String, String>? fields}) async {
    try {
      final token   = await getToken();
      final request = http.MultipartRequest('POST', Uri.parse('${AppConfig.apiUrl}$path'));
      request.headers['Accept'] = 'application/json';
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      if (fields != null) request.fields.addAll(fields);
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final res      = await http.Response.fromStream(streamed);
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Upload gagal: $e'};
    }
  }

  static Map<String, dynamic> _parse(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 400 && body['success'] == null) {
        return {'success': false, 'message': body['message'] ?? 'Terjadi kesalahan'};
      }
      return body;
    } catch (_) {
      return {'success': false, 'message': 'Respons server tidak valid (${res.statusCode})'};
    }
  }
}

// Alias untuk kompatibilitas dengan kode lama
class AppConstants {
  static String get baseUrl => AppConfig.baseUrl;
  static String get apiUrl  => AppConfig.apiUrl;
}*/
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_api_service.dart';
import 'app_mode.dart';

class AppConfig {
  static const baseUrl = 'http://10.0.2.2:8000';
  static const apiUrl  = '$baseUrl/api';
}

// Alias agar semua screen tetap jalan
class AppConstants {
  static String get baseUrl => AppConfig.baseUrl;
}

class ApiService {
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove('user_data');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    bool auth = false,
    Map<String, String>? query,
  }) async {
    // ── Mode Mock ──
    if (AppMode.useMock) return _mockGet(path, query: query);

    // ── Mode Real API ──
    try {
      var uri = Uri.parse('${AppConfig.apiUrl}$path');
      if (query != null && query.isNotEmpty) uri = uri.replace(queryParameters: query);
      final res = await http.get(uri, headers: await _headers(auth: auth))
          .timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa internet kamu.'};
    }
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    if (AppMode.useMock) return _mockPost(path, body);

    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiUrl}$path'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa internet kamu.'};
    }
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    if (AppMode.useMock) return {'success': true, 'message': 'Updated (mock)'};

    try {
      final res = await http.put(
        Uri.parse('${AppConfig.apiUrl}$path'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa internet kamu.'};
    }
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = false,
  }) async {
    if (AppMode.useMock) return {'success': true, 'message': 'Deleted (mock)'};

    try {
      final res = await http.delete(
        Uri.parse('${AppConfig.apiUrl}$path'),
        headers: await _headers(auth: auth),
      ).timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa internet kamu.'};
    }
  }

  // ── Mock Router ───────────────────────────────────────
  static Future<Map<String, dynamic>> _mockGet(
    String path, {
    Map<String, String>? query,
  }) async {
    if (path == '/banners')           return MockApiService.getBanners();
    if (path == '/categories')        return MockApiService.getCategories();
    if (path == '/shipping-options')  return MockApiService.getShippingOptions();
    if (path == '/products/featured') return MockApiService.getFeaturedProducts();
    if (path == '/products')          return MockApiService.getProducts(
      search:     query?['search'],
      categoryId: query?['category_id'] != null ? int.tryParse(query!['category_id']!) : null,
      minPrice:   query?['min_price'] != null ? double.tryParse(query!['min_price']!) : null,
      maxPrice:   query?['max_price'] != null ? double.tryParse(query!['max_price']!) : null,
      brand:      query?['brand'],
    );
    if (path.startsWith('/products/')) {
      final id = int.tryParse(path.split('/').last) ?? 0;
      return MockApiService.getProductById(id);
    }
    if (path == '/cart')              return MockApiService.getCart();
    if (path == '/addresses')         return MockApiService.getAddresses();
    if (path == '/orders')            return MockApiService.getUserOrders(status: query?['status']);
    if (path.startsWith('/orders/'))  {
      final id = int.tryParse(path.split('/').last) ?? 0;
      return MockApiService.getOrderDetail(id);
    }
    if (path == '/auth/profile')      return {'success': true, 'data': {'id': 2, 'name': 'John Customer', 'email': 'user@example.com', 'role': 'customer'}};
    if (path == '/admin/dashboard')   return MockApiService.getAdminDashboard();
    if (path == '/admin/orders')      return MockApiService.getAdminOrders(status: query?['status']);
    if (path == '/admin/products')    return MockApiService.getProducts();
    if (path == '/admin/users')       return MockApiService.getAdminUsers();
    if (path == '/admin/categories')  return MockApiService.getCategories();
    if (path == '/admin/products/low-stock') {
      final products = (await MockApiService.getProducts())['data'] as List;
      return {'success': true, 'data': products.where((p) => (p['stock'] as int) <= 10).toList()};
    }
    return {'success': true, 'data': []};
  }

  static Future<Map<String, dynamic>> _mockPost(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (path == '/auth/login')        return MockApiService.login(body['email'] ?? '', body['password'] ?? '');
    if (path == '/auth/register')     return MockApiService.register(body['name'] ?? '', body['email'] ?? '', body['password'] ?? '', body['phone'] ?? '');
    if (path == '/cart')              return MockApiService.addToCart(body['product_id'], body['quantity'] ?? 1);
    if (path == '/orders/checkout')   return MockApiService.checkout(body);
    if (path == '/vouchers/validate') return MockApiService.validateVoucher(body['code'] ?? '');
    if (path == '/addresses')         return MockApiService.addAddress(body);
    return {'success': true, 'message': 'OK (mock)'};
  }

  static Map<String, dynamic> _parse(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 400 && body['success'] == null) {
        return {'success': false, 'message': body['message'] ?? 'Terjadi kesalahan'};
      }
      return body;
    } catch (_) {
      return {'success': false, 'message': 'Respons server tidak valid (${res.statusCode})'};
    }
  }
}