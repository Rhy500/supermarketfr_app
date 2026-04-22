import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

// ── Format currency ───────────────────────────────────────────────────────────
String formatRupiah(double amount) {
  return NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(amount);
}

// ── Product Card ──────────────────────────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              AspectRatio(
                aspectRatio: 1,
                child: product.image.isNotEmpty
                    ? Image.network(
                        '${AppConfig.baseUrl}/${product.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _noImagePlaceholder(),
                      )
                    : _noImagePlaceholder(),
              ),
              if (product.discountPercent > 0)
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${product.discountPercent}%',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (product.stock == 0)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: const Text('Habis',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (product.discountPercent > 0)
                  Text(formatRupiah(product.price),
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough)),
                Text(formatRupiah(product.finalPrice),
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    'Stok: ${product.stock}',
                    style: TextStyle(
                        fontSize: 11,
                        color: product.stock <= 5
                            ? AppColors.error
                            : AppColors.textSecondary),
                  ),
                  if (onAddToCart != null && product.stock > 0)
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, size: 18, color: Colors.white),
                      ),
                    ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noImagePlaceholder() => Container(
    color: AppColors.background,
    child: const Center(child: Icon(Icons.image, size: 48, color: AppColors.divider)),
  );
}

// ── Order Status Badge ────────────────────────────────────────────────────────
class OrderStatusBadge extends StatelessWidget {
  final String status;
  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$2.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.$2.withOpacity(0.4)),
      ),
      child: Text(config.$1,
          style: TextStyle(
              color: config.$2, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  (String, Color) _statusConfig(String s) => switch (s) {
    'pending'    => ('Menunggu', AppColors.warning),
    'processing' => ('Diproses', Colors.blue),
    'shipped'    => ('Dikirim', Colors.purple),
    'completed'  => ('Selesai', AppColors.success),
    'cancelled'  => ('Dibatalkan', AppColors.error),
    'paid'       => ('Lunas', AppColors.success),
    'failed'     => ('Gagal', AppColors.error),
    _            => (s, AppColors.textSecondary),
  };
}

// ── Empty State ───────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String icon, title, subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel ?? 'OK')),
            ],
          ],
        ),
      ),
    );
  }
}