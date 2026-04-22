import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supermarket_app/services/api_service.dart';
import '../../models/models.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  Future<void> _addToCart() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    if (widget.product.stock == 0) return;
    final ok = await context.read<CartProvider>().addToCart(widget.product.id, _qty);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Berhasil ditambahkan ke keranjang!' : 'Stok tidak mencukupi'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(
            background: p.image.isNotEmpty
                ? Image.network(
                    '${AppConfig.baseUrl}/${p.image}',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.background,
                      child: const Icon(Icons.image, size: 80, color: AppColors.divider),
                    ),
                  )
                : Container(
                    color: AppColors.background,
                    child: const Icon(Icons.image, size: 80, color: AppColors.divider),
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (p.brand.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(p.brand, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              const SizedBox(height: 8),
              Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(children: [
                if (p.discountPercent > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                    child: Text('${p.discountPercent}% OFF', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Text(formatRupiah(p.price),
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough)),
                  const SizedBox(width: 8),
                ],
                Text(formatRupiah(p.finalPrice),
                    style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _infoChip(Icons.inventory_2_outlined, 'Stok: ${p.stock} ${p.unit}',
                    color: p.stock <= 5 ? AppColors.error : AppColors.success),
                const SizedBox(width: 8),
                _infoChip(Icons.local_shipping_outlined, 'Tersedia'),
                const SizedBox(width: 8),
                _infoChip(Icons.star, '${p.soldCount} terjual', color: AppColors.accentLight),
              ]),
              if (p.description.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(p.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
              ],
              const SizedBox(height: 20),
              const Text('Jumlah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                _qtyButton(Icons.remove, () { if (_qty > 1) setState(() => _qty--); }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$_qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                _qtyButton(Icons.add, () { if (_qty < p.stock) setState(() => _qty++); }),
                const Spacer(),
                Text('Total: ${formatRupiah(p.finalPrice * _qty)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ]),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          // ignore: deprecated_member_use
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Keranjang'),
              onPressed: p.stock == 0 ? null : _addToCart,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bolt),
              label: const Text('Beli Sekarang'),
              onPressed: p.stock == 0 ? null : _addToCart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    ),
  );

  Widget _infoChip(IconData icon, String label, {Color? color}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      // ignore: deprecated_member_use
      color: (color ?? AppColors.textSecondary).withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color ?? AppColors.textSecondary, fontWeight: FontWeight.w500)),
    ]),
  );
}
