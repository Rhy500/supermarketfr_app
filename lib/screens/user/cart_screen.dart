import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supermarket_app/services/api_service.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Keranjang')),
        body: EmptyState(
          icon: '🛒',
          title: 'Masuk Dulu Yuk!',
          subtitle: 'Login untuk melihat keranjang belanja kamu',
          actionLabel: 'Masuk',
          onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        ),
      );
    }
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang (${cart.count})'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Kosongkan Keranjang?'),
                    content: const Text('Semua produk akan dihapus dari keranjang'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                );
                if (ok == true) cart.clearCart();
              },
              child: const Text('Kosongkan', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: cart.loading
          ? const Center(child: CircularProgressIndicator())
          : cart.items.isEmpty
              ? const EmptyState(icon: '🛒', title: 'Keranjang Kosong', subtitle: 'Yuk tambahkan produk favorit kamu')
              : RefreshIndicator(
                  onRefresh: cart.loadCart,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: item.image.isNotEmpty
                                  ? Image.network(
                                      '${AppConfig.baseUrl}/${item.image}',
                                      width: 76, height: 76, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _noImage(),
                                    )
                                  : _noImage(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              if (item.discountPercent > 0)
                                Text(formatRupiah(item.price), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough)),
                              Text(formatRupiah(item.finalPrice), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(children: [
                                _qtyBtn(Icons.remove, () {
                                  if (item.quantity > 1) cart.updateCart(item.id, item.quantity - 1);
                                  else _confirmDelete(item.id);
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                _qtyBtn(Icons.add, () {
                                  if (item.quantity < item.stock) cart.updateCart(item.id, item.quantity + 1);
                                }),
                                const Spacer(),
                                Text(formatRupiah(item.itemTotal),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ]),
                            ])),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _confirmDelete(item.id),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: cart.items.isEmpty ? null : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total Belanja:', style: TextStyle(fontSize: 16)),
            Text(formatRupiah(cart.total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
              child: const Text('Lanjut Checkout'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _noImage() => Container(
    width: 76, height: 76, color: AppColors.background,
    child: const Icon(Icons.image, color: AppColors.divider),
  );

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16),
    ),
  );

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text('Produk akan dihapus dari keranjang'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && mounted) context.read<CartProvider>().removeFromCart(id);
  }
}
