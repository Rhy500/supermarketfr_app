import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final int? categoryId;
  final String? title;
  const ProductListScreen({super.key, this.categoryId, this.title});
  @override State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Product> _products = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;

  // Filters
  double? _minPrice, _maxPrice;
  String? _selectedBrand;
  String _sortBy = 'created_at';
  String _sortDir = 'desc';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200 && !_loading && _hasMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (reset) { _page = 1; _hasMore = true; _products = []; }
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    final query = <String, String>{
      'page': '$_page', 'limit': '20',
      if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
      if (widget.categoryId != null) 'category_id': '${widget.categoryId}',
      if (_minPrice != null) 'min_price': '$_minPrice',
      if (_maxPrice != null) 'max_price': '$_maxPrice',
      if (_selectedBrand != null) 'brand': _selectedBrand!,
      'sort_by': _sortBy, 'sort_dir': _sortDir,
    };

    final res = await ApiService.get('/products', query: query);
    if (mounted) {
      final data = (res['data'] as List? ?? []).map((p) => Product.fromJson(p)).toList();
      setState(() {
        _products.addAll(data);
        _hasMore = data.length == 20;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    _page++;
    await _loadProducts();
  }

  void _showFilterSheet() {
    double? tmpMin = _minPrice;
    double? tmpMax = _maxPrice;
    String tmpSort = _sortBy;
    String tmpDir = _sortDir;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Filter & Urutkan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Urutkan', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              for (final opt in [('Terbaru', 'created_at', 'desc'), ('Harga ↑', 'price', 'asc'), ('Harga ↓', 'price', 'desc'), ('Terlaris', 'sold_count', 'desc')])
                ChoiceChip(
                  label: Text(opt.$1),
                  selected: tmpSort == opt.$2 && tmpDir == opt.$3,
                  // ignore: deprecated_member_use
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  onSelected: (_) => setModal(() { tmpSort = opt.$2; tmpDir = opt.$3; }),
                ),
            ]),
            const SizedBox(height: 20),
            const Text('Rentang Harga', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(
                decoration: const InputDecoration(labelText: 'Min', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
                onChanged: (v) => tmpMin = double.tryParse(v),
              )),
              const SizedBox(width: 12),
              Expanded(child: TextField(
                decoration: const InputDecoration(labelText: 'Max', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
                onChanged: (v) => tmpMax = double.tryParse(v),
              )),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () {
                  setState(() { _minPrice = null; _maxPrice = null; _sortBy = 'created_at'; _sortDir = 'desc'; });
                  Navigator.pop(ctx);
                  _loadProducts(reset: true);
                },
                child: const Text('Reset'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  setState(() { _minPrice = tmpMin; _maxPrice = tmpMax; _sortBy = tmpSort; _sortDir = tmpDir; });
                  Navigator.pop(ctx);
                  _loadProducts(reset: true);
                },
                child: const Text('Terapkan'),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Semua Produk'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _loadProducts(reset: true); })
                    : null,
              ),
              onSubmitted: (_) => _loadProducts(reset: true),
              onChanged: (v) { if (v.isEmpty) _loadProducts(reset: true); },
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: _showFilterSheet),
        ],
      ),
      body: Column(children: [
        if (_minPrice != null || _maxPrice != null || _sortBy != 'created_at')
          Container(
            color: AppColors.primary.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text('Filter aktif', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: () { setState(() { _minPrice = null; _maxPrice = null; _sortBy = 'created_at'; _sortDir = 'desc'; }); _loadProducts(reset: true); },
                child: const Text('Hapus', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        Expanded(
          child: _products.isEmpty && !_loading
              ? const EmptyState(icon: '🔍', title: 'Produk tidak ditemukan', subtitle: 'Coba kata kunci atau filter lain')
              : GridView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.68,
                    crossAxisSpacing: 12, mainAxisSpacing: 12,
                  ),
                  itemCount: _products.length + (_loading ? 2 : 0),
                  itemBuilder: (_, i) {
                    if (i >= _products.length) {
                      return const Card(child: Center(child: CircularProgressIndicator()));
                    }
                    final p = _products[i];
                    return ProductCard(
                      product: p,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
                      onAddToCart: () async {
                        final auth = context.read<AuthProvider>();
                        if (!auth.isLoggedIn) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          return;
                        }
                        await context.read<CartProvider>().addToCart(p.id, 1);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${p.name} ditambahkan'), backgroundColor: AppColors.success, duration: const Duration(seconds: 2)));
                      },
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
