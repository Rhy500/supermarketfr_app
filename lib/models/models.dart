// ============== PRODUCT MODEL ==============
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double finalPrice;
  final int discountPercent;
  final int stock;
  final String unit;
  final String image;
  final String brand;
  final int categoryId;
  final String categoryName;
  final bool isFeatured;
  final int soldCount;

  Product({
    required this.id, required this.name, required this.description,
    required this.price, required this.finalPrice, required this.discountPercent,
    required this.stock, required this.unit, required this.image,
    required this.brand, required this.categoryId, required this.categoryName,
    required this.isFeatured, required this.soldCount,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    name: j['name'] ?? '',
    description: j['description'] ?? '',
    price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
    finalPrice: double.tryParse(j['final_price']?.toString() ?? j['price']?.toString() ?? '0') ?? 0,
    discountPercent: int.tryParse(j['discount_percent']?.toString() ?? '0') ?? 0,
    stock: int.tryParse(j['stock']?.toString() ?? '0') ?? 0,
    unit: j['unit'] ?? 'pcs',
    image: j['image'] ?? '',
    brand: j['brand'] ?? '',
    categoryId: int.tryParse(j['category_id']?.toString() ?? '0') ?? 0,
    categoryName: j['category_name'] ?? '',
    isFeatured: j['is_featured'] == '1' || j['is_featured'] == true,
    soldCount: int.tryParse(j['sold_count']?.toString() ?? '0') ?? 0,
  );
}

// ============== CATEGORY MODEL ==============
class Category {
  final int id;
  final String name;
  final String icon;
  final String image;
  final int productCount;

  Category({required this.id, required this.name, required this.icon, required this.image, required this.productCount});

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    name: j['name'] ?? '',
    icon: j['icon'] ?? '🛒',
    image: j['image'] ?? '',
    productCount: int.tryParse(j['product_count']?.toString() ?? '0') ?? 0,
  );
}

// ============== CART ITEM ==============
class CartItem {
  final int id;
  final int productId;
  final String name;
  final String image;
  final double price;
  final double finalPrice;
  final int discountPercent;
  final String unit;
  int quantity;
  final int stock;

  CartItem({
    required this.id, required this.productId, required this.name,
    required this.image, required this.price, required this.finalPrice,
    required this.discountPercent, required this.unit,
    required this.quantity, required this.stock,
  });

  double get itemTotal => finalPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    productId: int.tryParse(j['product_id']?.toString() ?? '0') ?? 0,
    name: j['name'] ?? '',
    image: j['image'] ?? '',
    price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
    finalPrice: double.tryParse(j['final_price']?.toString() ?? j['price']?.toString() ?? '0') ?? 0,
    discountPercent: int.tryParse(j['discount_percent']?.toString() ?? '0') ?? 0,
    unit: j['unit'] ?? 'pcs',
    quantity: int.tryParse(j['quantity']?.toString() ?? '1') ?? 1,
    stock: int.tryParse(j['stock']?.toString() ?? '0') ?? 0,
  );
}

// ============== ORDER ==============
class Order {
  final int id;
  final String orderNumber;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final double subtotal;
  final double shippingCost;
  final double discountAmount;
  final double total;
  final String createdAt;
  final String shippingName;
  final String fullAddress;
  final String? trackingNumber;
  List<OrderItem> items;

  Order({
    required this.id, required this.orderNumber, required this.orderStatus,
    required this.paymentStatus, required this.paymentMethod,
    required this.subtotal, required this.shippingCost, required this.discountAmount,
    required this.total, required this.createdAt, required this.shippingName,
    required this.fullAddress, this.trackingNumber, this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    orderNumber: j['order_number'] ?? '',
    orderStatus: j['order_status'] ?? 'pending',
    paymentStatus: j['payment_status'] ?? 'pending',
    paymentMethod: j['payment_method'] ?? '',
    subtotal: double.tryParse(j['subtotal']?.toString() ?? '0') ?? 0,
    shippingCost: double.tryParse(j['shipping_cost']?.toString() ?? '0') ?? 0,
    discountAmount: double.tryParse(j['discount_amount']?.toString() ?? '0') ?? 0,
    total: double.tryParse(j['total']?.toString() ?? '0') ?? 0,
    createdAt: j['created_at'] ?? '',
    shippingName: j['shipping_name'] ?? '',
    fullAddress: j['full_address'] ?? '',
    trackingNumber: j['tracking_number'],
    items: (j['items'] as List<dynamic>? ?? []).map((i) => OrderItem.fromJson(i)).toList(),
  );
}

class OrderItem {
  final int id;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double subtotal;
  final int discountPercent;

  OrderItem({
    required this.id, required this.productName, required this.productImage,
    required this.price, required this.quantity, required this.subtotal,
    required this.discountPercent,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    productName: j['product_name'] ?? '',
    productImage: j['product_image'] ?? '',
    price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
    quantity: int.tryParse(j['quantity']?.toString() ?? '1') ?? 1,
    subtotal: double.tryParse(j['subtotal']?.toString() ?? '0') ?? 0,
    discountPercent: int.tryParse(j['discount_percent']?.toString() ?? '0') ?? 0,
  );
}

// ============== ADDRESS ==============
class Address {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String city;
  final String fullAddress;
  final bool isDefault;

  Address({
    required this.id, required this.label, required this.recipientName,
    required this.phone, required this.city, required this.fullAddress,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> j) => Address(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    label: j['label'] ?? 'Rumah',
    recipientName: j['recipient_name'] ?? '',
    phone: j['phone'] ?? '',
    city: j['city'] ?? '',
    fullAddress: j['full_address'] ?? '',
    isDefault: j['is_default'] == '1' || j['is_default'] == true,
  );
}

// ============== USER ==============
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;

  User({required this.id, required this.name, required this.email, this.phone, this.avatar, required this.role});

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    phone: j['phone'],
    avatar: j['avatar'],
    role: j['role'] ?? 'customer',
  );

  bool get isAdmin => role == 'admin';
}

// ============== PROMO BANNER ==============
class PromoBanner {
  final int id;
  final String title;
  final String subtitle;
  final String image;

  PromoBanner({required this.id, required this.title, required this.subtitle, required this.image});

  factory PromoBanner.fromJson(Map<String, dynamic> j) => PromoBanner(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    title: j['title'] ?? '',
    subtitle: j['subtitle'] ?? '',
    image: j['image'] ?? '',
  );
}
