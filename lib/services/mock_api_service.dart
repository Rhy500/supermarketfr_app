import 'dart:async';

class MockApiService {
  // Simulasi delay jaringan
  static Future<void> _delay() => Future.delayed(const Duration(milliseconds: 800));

  // ── AUTH ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    await _delay();
    if (email == 'admin@supermarket.com' && password == 'admin123') {
      return {
        'success': true,
        'token': 'mock_token_admin_12345',
        'user': {'id': 1, 'name': 'Admin', 'email': email, 'role': 'admin', 'avatar': null},
      };
    }
    if (email == 'user@example.com' && password == 'user123') {
      return {
        'success': true,
        'token': 'mock_token_user_67890',
        'user': {'id': 2, 'name': 'John Customer', 'email': email, 'role': 'customer', 'avatar': null},
      };
    }
    return {'success': false, 'message': 'Email atau password salah'};
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String phone) async {
    await _delay();
    return {
      'success': true,
      'token': 'mock_token_new_user',
      'user': {'id': 3, 'name': name, 'email': email, 'role': 'customer', 'avatar': null},
    };
  }

  // ── BANNERS ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getBanners() async {
    await _delay();
    return {
      'success': true,
      'data': [
        {'id': 1, 'title': 'Promo Ramadan', 'subtitle': 'Diskon hingga 50%', 'image': ''},
        {'id': 2, 'title': 'Belanja Hemat', 'subtitle': 'Gratis ongkir min. Rp50.000', 'image': ''},
        {'id': 3, 'title': 'Produk Segar', 'subtitle': 'Fresh setiap hari', 'image': ''},
      ],
    };
  }

  // ── CATEGORIES ────────────────────────────────────────
  static Future<Map<String, dynamic>> getCategories() async {
    await _delay();
    return {
      'success': true,
      'data': [
        {'id': 1, 'name': 'Makanan',        'icon': '🍔', 'image': '', 'product_count': 12},
        {'id': 2, 'name': 'Minuman',        'icon': '🥤', 'image': '', 'product_count': 8},
        {'id': 3, 'name': 'Kebersihan',     'icon': '🧼', 'image': '', 'product_count': 6},
        {'id': 4, 'name': 'Kesehatan',      'icon': '💊', 'image': '', 'product_count': 5},
        {'id': 5, 'name': 'Frozen Food',    'icon': '🧊', 'image': '', 'product_count': 7},
        {'id': 6, 'name': 'Snack',          'icon': '🍿', 'image': '', 'product_count': 10},
        {'id': 7, 'name': 'Bumbu Masak',    'icon': '🧂', 'image': '', 'product_count': 4},
        {'id': 8, 'name': 'Perawatan Diri', 'icon': '🛁', 'image': '', 'product_count': 9},
      ],
    };
  }

  // ── PRODUCTS ──────────────────────────────────────────
  static final List<Map<String, dynamic>> _products = [
    {'id': 1, 'name': 'Indomie Goreng',     'price': 3500,  'discount_percent': 0,  'stock': 200, 'unit': 'pcs',   'image': '', 'brand': 'Indofood', 'category_id': 1, 'category_name': 'Makanan',    'is_featured': true,  'sold_count': 450, 'description': 'Mie goreng instan rasa original.', 'final_price': 3500},
    {'id': 2, 'name': 'Aqua 600ml',         'price': 4000,  'discount_percent': 0,  'stock': 150, 'unit': 'botol', 'image': '', 'brand': 'Danone',   'category_id': 2, 'category_name': 'Minuman',    'is_featured': true,  'sold_count': 320, 'description': 'Air mineral segar alami.',          'final_price': 4000},
    {'id': 3, 'name': 'Sabun Lifebuoy',     'price': 8000,  'discount_percent': 10, 'stock': 80,  'unit': 'pcs',   'image': '', 'brand': 'Unilever', 'category_id': 3, 'category_name': 'Kebersihan', 'is_featured': false, 'sold_count': 180, 'description': 'Sabun mandi antibakteri.',          'final_price': 7200},
    {'id': 4, 'name': 'Susu Ultra 1L',      'price': 18500, 'discount_percent': 5,  'stock': 60,  'unit': 'liter', 'image': '', 'brand': 'Ultra',    'category_id': 2, 'category_name': 'Minuman',    'is_featured': true,  'sold_count': 210, 'description': 'Susu UHT full cream.',              'final_price': 17575},
    {'id': 5, 'name': 'Chitato 68gr',       'price': 13500, 'discount_percent': 0,  'stock': 100, 'unit': 'pcs',   'image': '', 'brand': 'Indofood', 'category_id': 6, 'category_name': 'Snack',      'is_featured': true,  'sold_count': 395, 'description': 'Keripik kentang renyah.',           'final_price': 13500},
    {'id': 6, 'name': 'Rinso Cair 800ml',   'price': 22000, 'discount_percent': 15, 'stock': 8,   'unit': 'botol', 'image': '', 'brand': 'Unilever', 'category_id': 3, 'category_name': 'Kebersihan', 'is_featured': false, 'sold_count': 120, 'description': 'Detergen cair konsentrat.',         'final_price': 18700},
    {'id': 7, 'name': 'Good Day 3in1',      'price': 3000,  'discount_percent': 0,  'stock': 300, 'unit': 'sachet','image': '', 'brand': 'Santos',   'category_id': 2, 'category_name': 'Minuman',    'is_featured': false, 'sold_count': 280, 'description': 'Kopi susu siap saji.',              'final_price': 3000},
    {'id': 8, 'name': 'Teh Botol Sosro',    'price': 5000,  'discount_percent': 0,  'stock': 120, 'unit': 'botol', 'image': '', 'brand': 'Sosro',    'category_id': 2, 'category_name': 'Minuman',    'is_featured': true,  'sold_count': 500, 'description': 'Teh botol original minuman legendaris.', 'final_price': 5000},
    {'id': 9, 'name': 'Minyak Goreng 2L',   'price': 35000, 'discount_percent': 5,  'stock': 5,   'unit': 'liter', 'image': '', 'brand': 'Bimoli',   'category_id': 7, 'category_name': 'Bumbu Masak','is_featured': false, 'sold_count': 95,  'description': 'Minyak goreng jernih berkualitas.',  'final_price': 33250},
    {'id': 10,'name': 'Pepsodent 190gr',    'price': 15000, 'discount_percent': 0,  'stock': 75,  'unit': 'pcs',   'image': '', 'brand': 'Unilever', 'category_id': 8, 'category_name': 'Perawatan Diri','is_featured': false,'sold_count': 160,'description': 'Pasta gigi fluoride.',             'final_price': 15000},
  ];

  static Future<Map<String, dynamic>> getProducts({String? search, int? categoryId, double? minPrice, double? maxPrice, String? brand}) async {
    await _delay();
    var filtered = List<Map<String, dynamic>>.from(_products);
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((p) =>
        p['name'].toString().toLowerCase().contains(search.toLowerCase()) ||
        p['brand'].toString().toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    if (categoryId != null) filtered = filtered.where((p) => p['category_id'] == categoryId).toList();
    if (minPrice != null)   filtered = filtered.where((p) => (p['price'] as num) >= minPrice).toList();
    if (maxPrice != null)   filtered = filtered.where((p) => (p['price'] as num) <= maxPrice).toList();
    if (brand != null)      filtered = filtered.where((p) => p['brand'] == brand).toList();
    return {'success': true, 'data': filtered, 'pagination': {'total': filtered.length, 'page': 1, 'limit': 20, 'total_pages': 1}};
  }

  static Future<Map<String, dynamic>> getFeaturedProducts() async {
    await _delay();
    final featured = _products.where((p) => p['is_featured'] == true).toList();
    return {'success': true, 'data': featured};
  }

  static Future<Map<String, dynamic>> getProductById(int id) async {
    await _delay();
    final product = _products.firstWhere((p) => p['id'] == id, orElse: () => {});
    if (product.isEmpty) return {'success': false, 'message': 'Produk tidak ditemukan'};
    return {'success': true, 'data': product};
  }

  // ── CART ──────────────────────────────────────────────
  static final List<Map<String, dynamic>> _cart = [];

  static Future<Map<String, dynamic>> getCart() async {
    await _delay();
    double total = 0;
    int count = 0;
    for (final item in _cart) {
      total += (item['final_price'] as num) * (item['quantity'] as num);
      count += item['quantity'] as int;
    }
    return {'success': true, 'data': _cart, 'total': total, 'count': count};
  }

  static Future<Map<String, dynamic>> addToCart(int productId, int qty) async {
    await _delay();
    final product = _products.firstWhere((p) => p['id'] == productId, orElse: () => {});
    if (product.isEmpty) return {'success': false, 'message': 'Produk tidak ditemukan'};
    if ((product['stock'] as int) < qty) return {'success': false, 'message': 'Stok tidak mencukupi'};
    final existing = _cart.indexWhere((c) => c['product_id'] == productId);
    if (existing >= 0) {
      _cart[existing]['quantity'] = (_cart[existing]['quantity'] as int) + qty;
    } else {
      _cart.add({
        'id': _cart.length + 1,
        'product_id': productId,
        'name': product['name'],
        'image': product['image'],
        'price': product['price'],
        'final_price': product['final_price'],
        'discount_percent': product['discount_percent'],
        'unit': product['unit'],
        'quantity': qty,
        'stock': product['stock'],
        'item_total': (product['final_price'] as num) * qty,
      });
    }
    return {'success': true, 'message': 'Produk ditambahkan ke keranjang'};
  }

  static Future<Map<String, dynamic>> updateCart(int id, int qty) async {
    await _delay();
    final idx = _cart.indexWhere((c) => c['id'] == id);
    if (idx < 0) return {'success': false, 'message': 'Item tidak ditemukan'};
    if (qty <= 0) {
      _cart.removeAt(idx);
    } else {
      _cart[idx]['quantity'] = qty;
    }
    return {'success': true, 'message': 'Keranjang diperbarui'};
  }

  static Future<Map<String, dynamic>> removeFromCart(int id) async {
    await _delay();
    _cart.removeWhere((c) => c['id'] == id);
    return {'success': true, 'message': 'Produk dihapus dari keranjang'};
  }

  static Future<Map<String, dynamic>> clearCart() async {
    await _delay();
    _cart.clear();
    return {'success': true, 'message': 'Keranjang dikosongkan'};
  }

  // ── SHIPPING ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getShippingOptions() async {
    await _delay();
    return {
      'success': true,
      'data': [
        {'id': 1, 'name': 'Reguler',      'base_price': 15000, 'estimated_days': '3-5 hari'},
        {'id': 2, 'name': 'Express',      'base_price': 25000, 'estimated_days': '1-2 hari'},
        {'id': 3, 'name': 'Same Day',     'base_price': 45000, 'estimated_days': 'Hari ini'},
        {'id': 4, 'name': 'Ambil Sendiri','base_price': 0,     'estimated_days': 'Sesuai jadwal'},
      ],
    };
  }

  // ── ADDRESSES ─────────────────────────────────────────
  static final List<Map<String, dynamic>> _addresses = [
    {'id': 1, 'label': 'Rumah', 'recipient_name': 'John Customer', 'phone': '081234567890', 'city': 'Jakarta', 'full_address': 'Jl. Merdeka No. 12, Jakarta Pusat, DKI Jakarta', 'is_default': true},
    {'id': 2, 'label': 'Kantor', 'recipient_name': 'John Customer', 'phone': '081234567890', 'city': 'Jakarta', 'full_address': 'Jl. Sudirman No. 45, Jakarta Selatan, DKI Jakarta', 'is_default': false},
  ];

  static Future<Map<String, dynamic>> getAddresses() async {
    await _delay();
    return {'success': true, 'data': _addresses};
  }

  // ...existing code...

  static Future<Map<String, dynamic>> addAddress(Map<String, dynamic> data) async {
    await _delay();
    if (data['is_default'] == true) {
      for (final a in _addresses) { a['is_default'] = false; }
    }
    _addresses.add({...data, 'id': _addresses.length + 1});
    return {'success': true, 'message': 'Alamat ditambahkan'};
  }

// ...existing code...

  static Future<Map<String, dynamic>> deleteAddress(int id) async {
    await _delay();
    _addresses.removeWhere((a) => a['id'] == id);
    return {'success': true, 'message': 'Alamat dihapus'};
  }

  // ── VOUCHER ───────────────────────────────────────────
  static Future<Map<String, dynamic>> validateVoucher(String code) async {
    await _delay();
    final vouchers = {
      'HEMAT20K': {'id': 1, 'code': 'HEMAT20K', 'type': 'fixed',   'value': 20000, 'min_purchase': 100000, 'max_discount': null,  'description': 'Potongan Rp20.000'},
      'DISKON10': {'id': 2, 'code': 'DISKON10', 'type': 'percent', 'value': 10,    'min_purchase': 50000,  'max_discount': 15000, 'description': 'Diskon 10%'},
    };
    if (vouchers.containsKey(code.toUpperCase())) {
      return {'success': true, 'message': 'Voucher valid!', 'data': vouchers[code.toUpperCase()]};
    }
    return {'success': false, 'message': 'Voucher tidak valid'};
  }

  // ── ORDERS ────────────────────────────────────────────
  static int _orderCounter = 1;
  static final List<Map<String, dynamic>> _orders = [];

  static Future<Map<String, dynamic>> checkout(Map<String, dynamic> data) async {
    await _delay();
    final orderNumber = 'SM2024${_orderCounter.toString().padLeft(4, '0')}';
    _orderCounter++;
    double subtotal = 0;
    for (final item in _cart) {
      subtotal += (item['final_price'] as num) * (item['quantity'] as num);
    }
    final shipping = data['shipping_id'] == 1 ? 15000 : data['shipping_id'] == 2 ? 25000 : data['shipping_id'] == 3 ? 45000 : 0;
    final order = {
      'id': _orders.length + 1,
      'order_number': orderNumber,
      'order_status': 'pending',
      'payment_status': 'pending',
      'payment_method': data['payment_method'],
      'subtotal': subtotal,
      'shipping_cost': shipping,
      'discount_amount': 0,
      'total': subtotal + shipping,
      'shipping_name': 'Reguler',
      'full_address': 'Jl. Merdeka No. 12, Jakarta',
      'tracking_number': null,
      'created_at': DateTime.now().toString(),
      'items': List.from(_cart),
    };
    _orders.add(order);
    _cart.clear();
    return {'success': true, 'message': 'Pesanan berhasil dibuat', 'order_id': order['id'], 'order_number': orderNumber, 'total': order['total']};
  }

  static Future<Map<String, dynamic>> getUserOrders({String? status}) async {
    await _delay();
    var orders = List<Map<String, dynamic>>.from(_orders);
    if (status != null) orders = orders.where((o) => o['order_status'] == status).toList();
    return {'success': true, 'data': orders.reversed.toList()};
  }

  static Future<Map<String, dynamic>> getOrderDetail(int id) async {
    await _delay();
    final order = _orders.firstWhere((o) => o['id'] == id, orElse: () => {});
    if (order.isEmpty) return {'success': false, 'message': 'Pesanan tidak ditemukan'};
    return {'success': true, 'data': order};
  }

  // ── ADMIN DASHBOARD ───────────────────────────────────
  static Future<Map<String, dynamic>> getAdminDashboard() async {
    await _delay();
    return {
      'success': true,
      'data': {
        'total_sales':    '4250000',
        'total_orders':   '128',
        'total_products': '64',
        'total_users':    '312',
        'pending_orders': '7',
        'low_stock_count':'3',
        'daily_sales': List.generate(12, (i) => {
          'date':  '2024-04-${(i + 1).toString().padLeft(2, '0')}',
          'total': (500000 + (i * 150000)).toString(),
          'count': (5 + i).toString(),
        }),
        'top_products': _products
          .where((p) => p['sold_count'] > 100)
          .map((p) => {'name': p['name'], 'image': p['image'], 'sold': p['sold_count'], 'revenue': ((p['final_price'] as num) * (p['sold_count'] as num)).toString()})
          .toList()
          ..sort((a, b) => (b['sold'] as int).compareTo(a['sold'] as int)),
      },
    };
  }

  // ── ADMIN ORDERS ──────────────────────────────────────
  static Future<Map<String, dynamic>> getAdminOrders({String? status}) async {
    await _delay();
    final dummyOrders = [
      {'id': 101, 'order_number': 'SM20240001', 'order_status': 'pending',    'payment_status': 'pending', 'payment_method': 'transfer_bank', 'total': 87500,  'customer_name': 'Budi Santoso',  'customer_email': 'budi@email.com',  'shipping_name': 'Reguler', 'created_at': '2024-04-19 10:32'},
      {'id': 102, 'order_number': 'SM20240002', 'order_status': 'processing', 'payment_status': 'paid',    'payment_method': 'e_wallet',       'total': 125000, 'customer_name': 'Siti Rahayu',   'customer_email': 'siti@email.com',  'shipping_name': 'Express', 'created_at': '2024-04-18 14:05'},
      {'id': 103, 'order_number': 'SM20240003', 'order_status': 'shipped',    'payment_status': 'paid',    'payment_method': 'transfer_bank', 'total': 45000,  'customer_name': 'Ahmad Fauzi',   'customer_email': 'ahmad@email.com', 'shipping_name': 'Reguler', 'created_at': '2024-04-17 09:15'},
      {'id': 104, 'order_number': 'SM20240004', 'order_status': 'completed',  'payment_status': 'paid',    'payment_method': 'cod',            'total': 67000,  'customer_name': 'Dewi Lestari',  'customer_email': 'dewi@email.com',  'shipping_name': 'Same Day','created_at': '2024-04-16 16:45'},
    ];
    var orders = List<Map<String, dynamic>>.from(dummyOrders);
    if (status != null) orders = orders.where((o) => o['order_status'] == status).toList();
    return {'success': true, 'data': orders, 'pagination': {'total': orders.length, 'page': 1, 'limit': 20}};
  }

  static Future<Map<String, dynamic>> updateOrderStatus(int id, String status, {String? trackingNumber}) async {
    await _delay();
    return {'success': true, 'message': 'Status pesanan diperbarui'};
  }

  // ── ADMIN USERS ───────────────────────────────────────
  static Future<Map<String, dynamic>> getAdminUsers() async {
    await _delay();
    return {
      'success': true,
      'data': [
        {'id': 1, 'name': 'Budi Santoso',  'email': 'budi@email.com',  'phone': '081111111111', 'is_blocked': false, 'created_at': '2024-01-15'},
        {'id': 2, 'name': 'Siti Rahayu',   'email': 'siti@email.com',  'phone': '082222222222', 'is_blocked': false, 'created_at': '2024-02-20'},
        {'id': 3, 'name': 'Ahmad Fauzi',   'email': 'ahmad@email.com', 'phone': '083333333333', 'is_blocked': true,  'created_at': '2024-03-10'},
        {'id': 4, 'name': 'Dewi Lestari',  'email': 'dewi@email.com',  'phone': '084444444444', 'is_blocked': false, 'created_at': '2024-04-01'},
      ],
      'pagination': {'total': 4, 'page': 1, 'limit': 20},
    };
  }
}