import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _tabs = ['Semua', 'Pending', 'Diproses', 'Dikirim', 'Selesai'];
  final _statuses = [null, 'pending', 'processing', 'shipped', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: _statuses.map((s) => _OrderTab(status: s)).toList(),
      ),
    );
  }
}

class _OrderTab extends StatefulWidget {
  final String? status;
  const _OrderTab({this.status});
  @override State<_OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends State<_OrderTab> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final query = widget.status != null ? {'status': widget.status!} : null;
    final res = await ApiService.get('/orders', auth: true, query: query);
    setState(() {
      _orders = (res['data'] as List? ?? []).map((o) => Order.fromJson(o)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_orders.isEmpty) return const EmptyState(icon: '📦', title: 'Belum ada pesanan', subtitle: 'Mulai belanja sekarang!');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (_, i) {
          final o = _orders[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id))),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    OrderStatusBadge(status: o.orderStatus),
                  ]),
                  const SizedBox(height: 4),
                  Text(o.createdAt, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const Divider(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total Pembayaran', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text(formatRupiah(o.total), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                    ]),
                    Row(children: [
                      OrderStatusBadge(status: o.paymentStatus),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ]),
                  ]),
                  if (o.orderStatus == 'shipped' && o.trackingNumber != null && o.trackingNumber!.isNotEmpty) ...[
                    const Divider(height: 12),
                    Row(children: [
                      const Icon(Icons.local_shipping, size: 16, color: Colors.purple),
                      const SizedBox(width: 6),
                      Text('Nomor Resi: ${o.trackingNumber}', style: const TextStyle(fontSize: 12)),
                    ]),
                  ],
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.get('/orders/${widget.orderId}', auth: true);
    setState(() {
      _order = res['success'] == true ? Order.fromJson(res['data']) : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const EmptyState(icon: '❌', title: 'Pesanan tidak ditemukan', subtitle: '')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _statusCard(),
                    const SizedBox(height: 12),
                    _addressCard(),
                    const SizedBox(height: 12),
                    _itemsCard(),
                    const SizedBox(height: 12),
                    _paymentCard(),
                  ]),
                ),
    );
  }

  Widget _statusCard() {
    final o = _order!;
    final steps = ['Pending', 'Diproses', 'Dikirim', 'Selesai'];
    final currentStep = {'pending': 0, 'processing': 1, 'shipped': 2, 'completed': 3}[o.orderStatus] ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
            OrderStatusBadge(status: o.orderStatus),
          ]),
          const SizedBox(height: 16),
          Row(
            children: steps.asMap().entries.map((e) {
              final done = e.key <= currentStep;
              return Expanded(child: Column(children: [
                Row(children: [
                  if (e.key > 0) Expanded(child: Container(height: 2, color: e.key <= currentStep ? AppColors.primary : AppColors.divider)),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : AppColors.divider,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: done
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text('${e.key + 1}', style: const TextStyle(fontSize: 12, color: Colors.white))),
                  ),
                  if (e.key < steps.length - 1) Expanded(child: Container(height: 2, color: e.key < currentStep ? AppColors.primary : AppColors.divider)),
                ]),
                const SizedBox(height: 4),
                Text(e.value, style: TextStyle(fontSize: 11, color: done ? AppColors.primary : AppColors.textSecondary)),
              ]));
            }).toList(),
          ),
          if (o.trackingNumber != null && o.trackingNumber!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.local_shipping, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Nomor Resi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(o.trackingNumber!, style: const TextStyle(fontWeight: FontWeight.bold)),
                ])),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _addressCard() {
    final o = _order!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📍 Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(o.fullAddress, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Pengiriman: ${o.shippingName}', style: const TextStyle(fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _itemsCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🛒 Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._order!.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImage.isNotEmpty
                  ? Image.network('${AppConfig.baseUrl}/${item.productImage}',
                      width: 52, height: 52, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 52, height: 52, color: AppColors.background))
                  : Container(width: 52, height: 52, color: AppColors.background, child: const Icon(Icons.image, color: AppColors.divider)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2),
              Text('${item.quantity} × ${formatRupiah(item.price)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Text(formatRupiah(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        )),
      ]),
    ),
  );

  Widget _paymentCard() {
    final o = _order!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('💳 Rincian Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _row('Subtotal', formatRupiah(o.subtotal)),
          _row('Ongkos Kirim', formatRupiah(o.shippingCost)),
          if (o.discountAmount > 0) _row('Diskon', '-${formatRupiah(o.discountAmount)}', color: AppColors.success),
          const Divider(),
          _row('Total', formatRupiah(o.total), bold: true, color: AppColors.primary),
          const SizedBox(height: 8),
          _row('Metode', o.paymentMethod.replaceAll('_', ' ').toUpperCase()),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Status Bayar'),
            OrderStatusBadge(status: o.paymentStatus),
          ]),
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: bold ? null : AppColors.textSecondary)),
      Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: color)),
    ]),
  );
}
