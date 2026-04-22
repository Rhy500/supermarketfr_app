import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Address> _addresses = [];
  List<Map<String, dynamic>> _shippingOptions = [];
  Address? _selectedAddress;
  Map<String, dynamic>? _selectedShipping;
  String _paymentMethod = 'transfer_bank';
  Map<String, dynamic>? _voucher;
  final _voucherCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.get('/addresses', auth: true),
      ApiService.get('/shipping-options'),
    ]);
    setState(() {
      _addresses = (results[0]['data'] as List? ?? []).map((a) => Address.fromJson(a)).toList();
      _shippingOptions = List<Map<String, dynamic>>.from(results[1]['data'] ?? []);
      _selectedAddress = _addresses.isNotEmpty ? _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first) : null;
      _selectedShipping = _shippingOptions.isNotEmpty ? _shippingOptions.first : null;
      _loading = false;
    });
  }

  Future<void> _validateVoucher() async {
    if (_voucherCtrl.text.isEmpty) return;
    final res = await ApiService.post('/vouchers/validate', {'code': _voucherCtrl.text}, auth: true);
    setState(() => _voucher = res['success'] == true ? res['data'] : null);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['message'] ?? (res['success'] == true ? 'Voucher valid!' : 'Voucher tidak valid')),
      backgroundColor: res['success'] == true ? AppColors.success : AppColors.error,
    ));
  }

  double get _shippingCost => double.tryParse(_selectedShipping?['base_price']?.toString() ?? '0') ?? 0;
  
  double get _discount {
    if (_voucher == null) return 0;
    final cart = context.read<CartProvider>();
    if (_voucher!['type'] == 'percent') {
      double d = cart.total * double.parse(_voucher!['value'].toString()) / 100;
      final max = double.tryParse(_voucher!['max_discount']?.toString() ?? '');
      if (max != null && d > max) d = max;
      return d;
    }
    return double.tryParse(_voucher!['value'].toString()) ?? 0;
  }

  Future<void> _checkout() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih alamat pengiriman')));
      return;
    }
    setState(() => _submitting = true);
    final res = await ApiService.post('/orders/checkout', {
      'address_id': _selectedAddress!.id,
      'shipping_id': int.tryParse(_selectedShipping?['id']?.toString() ?? ''),
      'payment_method': _paymentMethod,
      'voucher_code': _voucherCtrl.text,
      'notes': _notesCtrl.text,
    }, auth: true);
    setState(() => _submitting = false);
    if (!mounted) return;
    if (res['success'] == true) {
      context.read<CartProvider>().clearCart();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pesanan berhasil dibuat!'), backgroundColor: AppColors.success));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        (route) => route.isFirst,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Gagal membuat pesanan'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.total + _shippingCost - _discount;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionCard('📍 Alamat Pengiriman', _buildAddressSection()),
                const SizedBox(height: 16),
                _sectionCard('📦 Ringkasan Produk', _buildOrderSummary(cart)),
                const SizedBox(height: 16),
                _sectionCard('🚚 Pilih Pengiriman', _buildShippingSection()),
                const SizedBox(height: 16),
                _sectionCard('💳 Metode Pembayaran', _buildPaymentSection()),
                const SizedBox(height: 16),
                _sectionCard('🎁 Voucher', _buildVoucherSection()),
                const SizedBox(height: 16),
                _sectionCard('📝 Catatan', TextField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(hintText: 'Catatan untuk penjual (opsional)', border: InputBorder.none),
                  maxLines: 2,
                )),
                const SizedBox(height: 16),
                _buildPriceDetail(cart, total),
                const SizedBox(height: 80),
              ]),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _checkout,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Buat Pesanan · ${formatRupiah(total < 0 ? 0 : total)}'),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(String title, Widget child) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        child,
      ]),
    ),
  );

  Widget _buildAddressSection() {
    if (_addresses.isEmpty) return const Text('Belum ada alamat', style: TextStyle(color: AppColors.textSecondary));
    return Column(
      children: _addresses.map((a) => RadioListTile<int>(
        value: a.id,
        groupValue: _selectedAddress?.id,
        onChanged: (v) => setState(() => _selectedAddress = a),
        title: Text('${a.label} - ${a.recipientName}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(a.fullAddress),
        activeColor: AppColors.primary,
        contentPadding: EdgeInsets.zero,
      )).toList(),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) => Column(
    children: cart.items.map((item) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text('${item.name} x${item.quantity}', maxLines: 1, overflow: TextOverflow.ellipsis)),
        Text(formatRupiah(item.itemTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    )).toList(),
  );

  Widget _buildShippingSection() => Column(
    children: _shippingOptions.map((s) => RadioListTile<String>(
      value: s['id'].toString(),
      groupValue: _selectedShipping?['id']?.toString(),
      onChanged: (v) => setState(() => _selectedShipping = s),
      title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${s['estimated_days']} · ${formatRupiah(double.tryParse(s['base_price'].toString()) ?? 0)}'),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    )).toList(),
  );

  Widget _buildPaymentSection() => Column(
    children: [
      RadioListTile(value: 'transfer_bank', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!),
          title: const Text('Transfer Bank'), secondary: const Icon(Icons.account_balance), activeColor: AppColors.primary, contentPadding: EdgeInsets.zero),
      RadioListTile(value: 'e_wallet', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!),
          title: const Text('E-Wallet'), secondary: const Icon(Icons.account_balance_wallet), activeColor: AppColors.primary, contentPadding: EdgeInsets.zero),
      RadioListTile(value: 'cod', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!),
          title: const Text('COD (Bayar di Tempat)'), secondary: const Icon(Icons.money), activeColor: AppColors.primary, contentPadding: EdgeInsets.zero),
    ],
  );

  Widget _buildVoucherSection() => Row(children: [
    Expanded(child: TextField(
      controller: _voucherCtrl,
      decoration: const InputDecoration(hintText: 'Masukkan kode voucher', border: InputBorder.none),
      textCapitalization: TextCapitalization.characters,
    )),
    ElevatedButton(onPressed: _validateVoucher, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)), child: const Text('Pakai')),
  ]);

  Widget _buildPriceDetail(CartProvider cart, double total) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _priceRow('Subtotal', cart.total),
        _priceRow('Ongkos Kirim', _shippingCost),
        if (_discount > 0) _priceRow('Diskon Voucher', -_discount, color: AppColors.success),
        const Divider(height: 20),
        _priceRow('Total', total < 0 ? 0 : total, bold: true, color: AppColors.primary, size: 18),
      ]),
    ),
  );

  Widget _priceRow(String label, double amount, {bool bold = false, Color? color, double size = 14}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      Text(formatRupiah(amount), style: TextStyle(fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.w600, color: color)),
    ]),
  );
}
