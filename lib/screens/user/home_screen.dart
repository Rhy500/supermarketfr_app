import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import 'product_list_screen.dart';
import 'product_detail_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Ganti Banner → PromoBanner
  List<PromoBanner> _banners    = [];
  List<Category>   _categories  = [];
  List<Product>    _featured    = [];
  bool             _loading     = true;
  int              _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.get('/banners'),
      ApiService.get('/categories'),
      ApiService.get('/products/featured'),
    ]);
    setState(() {
      _banners    = (results[0]['data'] as List? ?? []).map((b) => PromoBanner.fromJson(b)).toList();
      _categories = (results[1]['data'] as List? ?? []).map((c) => Category.fromJson(c)).toList();
      _featured   = (results[2]['data'] as List? ?? []).map((p) => Product.fromJson(p)).toList();
      _loading    = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(cart),
            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else ...[
              _buildSearchBar(),
              _buildBanners(),
              _buildCategories(),
              _buildSectionTitle('Produk Populer',
                onViewAll: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProductListScreen()))),
              _buildFeaturedProducts(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(CartProvider cart) => SliverAppBar(
    floating: true,
    backgroundColor: AppColors.primary,
    title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('SuperMarket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
      Text('Belanja mudah & hemat',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
    ]),
    actions: [
      IconButton(
        icon: Badge(
          isLabelVisible: cart.count > 0,
          label: Text('${cart.count}'),
          child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        ),
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        onPressed: () {},
      ),
    ],
  );

  Widget _buildSearchBar() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProductListScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
          ),
          child: const Row(children: [
            Icon(Icons.search, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text('Cari produk...', style: TextStyle(color: AppColors.textSecondary)),
          ]),
        ),
      ),
    ),
  );

  // ── Banner: pakai PageView manual, tanpa carousel_slider ──────────────
  Widget _buildBanners() {
    if (_banners.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              itemCount: _banners.length,
              onPageChanged: (i) => setState(() => _currentBanner = i),
              itemBuilder: (_, i) {
                final b = _banners[i];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(children: [
                    if (b.image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          '${AppConfig.baseUrl}/${b.image}',
                          width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    Positioned(
                      bottom: 16, left: 16,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.title,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(b.subtitle,
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ]),
                    ),
                  ]),
                );
              },
            ),
          ),
          // Dot indicator
          if (_banners.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentBanner == i ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentBanner == i ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildCategories() => SliverToBoxAdapter(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () {},
              child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primary))),
        ]),
      ),
      SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final cat = _categories[i];
            return GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                      ProductListScreen(categoryId: cat.id, title: cat.name))),
              child: Container(
                width: 76,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(cat.icon,
                        style: const TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(height: 6),
                  Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ]),
              ),
            );
          },
        ),
      ),
    ]),
  );

  Widget _buildSectionTitle(String title, {VoidCallback? onViewAll}) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (onViewAll != null)
          TextButton(onPressed: onViewAll,
              child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primary))),
      ]),
    ),
  );

  Widget _buildFeaturedProducts() => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    sliver: SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final p = _featured[i];
          return ProductCard(
            product: p,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
            onAddToCart: () async {
              final auth = context.read<AuthProvider>();
              if (!auth.isLoggedIn) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
                return;
              }
              final ok = await context.read<CartProvider>().addToCart(p.id, 1);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? '${p.name} ditambahkan ke keranjang'
                      : 'Gagal menambahkan'),
                  backgroundColor: ok ? AppColors.success : AppColors.error,
                  duration: const Duration(seconds: 2),
                ));
              }
            },
          );
        },
        childCount: _featured.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.68,
        crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
    ),
  );
}