import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});
  @override State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.get('/admin/products', auth: true),
      ApiService.get('/categories'),
    ]);
    setState(() {
      _products = (results[0]['data'] as List? ?? []).map((p) => Product.fromJson(p)).toList();
      _categories = (results[1]['data'] as List? ?? []).map((c) => Category.fromJson(c)).toList();
      _loading = false;
    });
  }

  void _showProductForm({Product? product}) {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toStringAsFixed(0) ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final discCtrl = TextEditingController(text: product?.discountPercent.toString() ?? '0');
    final brandCtrl = TextEditingController(text: product?.brand ?? '');
    final imageCtrl = TextEditingController(text: product?.image ?? '');
    final unitCtrl = TextEditingController(text: product?.unit ?? 'pcs');
    int? selectedCategoryId = product?.categoryId;
    bool isFeatured = product?.isFeatured ?? false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(children: [
              AppBar(
                title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
                automaticallyImplyLeading: false,
                actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))],
              ),
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(children: [
                    TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk*'), validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 3),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextFormField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga*', prefixText: 'Rp '), keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null)),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stok*'), keyboardType: TextInputType.number)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextFormField(controller: discCtrl, decoration: const InputDecoration(labelText: 'Diskon (%)', suffixText: '%'), keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Satuan'))),
                    ]),
                    const SizedBox(height: 12),
                    TextFormField(controller: brandCtrl, decoration: const InputDecoration(labelText: 'Brand')),
                    const SizedBox(height: 12),
                    TextFormField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'Path Gambar')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) => setDialog(() => selectedCategoryId = v),
                    ),
                    CheckboxListTile(
                      value: isFeatured,
                      onChanged: (v) => setDialog(() => isFeatured = v!),
                      title: const Text('Produk Populer'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ]),
                ),
              )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final body = {
                        'name': nameCtrl.text, 'description': descCtrl.text,
                        'price': double.tryParse(priceCtrl.text) ?? 0,
                        'stock': int.tryParse(stockCtrl.text) ?? 0,
                        'discount_percent': int.tryParse(discCtrl.text) ?? 0,
                        'unit': unitCtrl.text, 'brand': brandCtrl.text,
                        'image': imageCtrl.text, 'category_id': selectedCategoryId,
                        'is_featured': isFeatured,
                      };
                      final res = product == null
                          ? await ApiService.post('/admin/products', body, auth: true)
                          : await ApiService.put('/admin/products/${product.id}', body, auth: true);
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(res['message'] ?? ''),
                          backgroundColor: res['success'] == true ? AppColors.success : AppColors.error,
                        ));
                        if (res['success'] == true) _load();
                      }
                    },
                    child: Text(product == null ? 'Tambah' : 'Simpan'),
                  )),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Hapus "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      final res = await ApiService.delete('/admin/products/${p.id}', auth: true);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? ''))); _load(); }
    }
  }

  void _showStockUpdate(Product p) {
    final ctrl = TextEditingController();
    String type = 'in';
    String reason = '';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text('Update Stok: ${p.name}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Stok saat ini: ${p.stock} ${p.unit}', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: RadioListTile(value: 'in', groupValue: type, onChanged: (v) => setDialog(() => type = v!),
                  title: const Text('Masuk (+)'), contentPadding: EdgeInsets.zero)),
              Expanded(child: RadioListTile(value: 'out', groupValue: type, onChanged: (v) => setDialog(() => type = v!),
                  title: const Text('Keluar (-)'), contentPadding: EdgeInsets.zero)),
            ]),
            TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Jumlah'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextField(onChanged: (v) => reason = v, decoration: const InputDecoration(labelText: 'Alasan (opsional)')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final amount = int.tryParse(ctrl.text) ?? 0;
                final change = type == 'in' ? amount : -amount;
                final res = await ApiService.put('/admin/products/${p.id}/stock', {'change': change, 'reason': reason}, auth: true);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? ''),
                      backgroundColor: res['success'] == true ? AppColors.success : AppColors.error));
                  if (res['success'] == true) _load();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showProductForm()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (v) => setState(() {}),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: () {
                final filtered = _products.where((p) =>
                    p.name.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
                if (filtered.isEmpty) return const EmptyState(icon: '📦', title: 'Produk tidak ditemukan', subtitle: '');
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: p.image.isNotEmpty
                                ? Image.network('${AppConfig.baseUrl}/${p.image}', width: 64, height: 64, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: AppColors.background))
                                : Container(width: 64, height: 64, color: AppColors.background, child: const Icon(Icons.image, color: AppColors.divider)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                            Text(formatRupiah(p.finalPrice), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            Row(children: [
                              Icon(Icons.circle, size: 10, color: p.stock > 10 ? AppColors.success : p.stock > 0 ? AppColors.warning : AppColors.error),
                              const SizedBox(width: 4),
                              Text('Stok: ${p.stock} ${p.unit}', style: TextStyle(
                                  color: p.stock > 10 ? AppColors.success : p.stock > 0 ? AppColors.warning : AppColors.error,
                                  fontSize: 12)),
                            ]),
                          ])),
                          Column(children: [
                            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), onPressed: () => _showProductForm(product: p)),
                            IconButton(icon: const Icon(Icons.inventory_2_outlined, color: Colors.orange, size: 20), onPressed: () => _showStockUpdate(p)),
                            IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => _deleteProduct(p)),
                          ]),
                        ]),
                      ),
                    );
                  },
                );
              }(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
