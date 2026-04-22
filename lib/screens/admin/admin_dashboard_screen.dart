import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.get('/admin/dashboard', auth: true);
    setState(() {
      _data = res['data'];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () { auth.logout(); }),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Selamat datang, ${auth.user?.name}! 👋',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatCards(),
                  const SizedBox(height: 20),
                  if (_data?['low_stock_count'] != null && int.parse(_data!['low_stock_count'].toString()) > 0)
                    _buildAlert(),
                  const SizedBox(height: 20),
                  _buildSalesChart(),
                  const SizedBox(height: 20),
                  _buildTopProducts(),
                ]),
              ),
            ),
    );
  }

  Widget _buildStatCards() {
    if (_data == null) return const SizedBox();
    final stats = [
      ('Total Penjualan', formatRupiah(double.tryParse(_data!['total_sales']?.toString() ?? '0') ?? 0), Icons.attach_money, AppColors.success),
      ('Total Pesanan', _data!['total_orders'] ?? '0', Icons.shopping_bag, Colors.blue),
      ('Total Produk', _data!['total_products'] ?? '0', Icons.inventory_2, Colors.orange),
      ('Total User', _data!['total_users'] ?? '0', Icons.people, Colors.purple),
      ('Menunggu', _data!['pending_orders'] ?? '0', Icons.pending_actions, AppColors.warning),
      ('Stok Kritis', _data!['low_stock_count'] ?? '0', Icons.warning_amber, AppColors.error),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: stats.map((s) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(s.$3, color: s.$4, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: s.$4.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(s.$3, color: s.$4, size: 16),
              ),
            ]),
            const Spacer(),
            Text(s.$2.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: s.$4)),
            Text(s.$1, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
        ),
      )).toList(),
    );
  }

  Widget _buildAlert() => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.error.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.error.withOpacity(0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.warning_amber, color: AppColors.error),
      const SizedBox(width: 8),
      Expanded(child: Text(
        '${_data!['low_stock_count']} produk hampir habis stok!',
        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
      )),
    ]),
  );

  Widget _buildSalesChart() {
    final salesData = (_data?['daily_sales'] as List? ?? []);
    if (salesData.isEmpty) return const SizedBox();

    final spots = salesData.asMap().entries.map((e) => FlSpot(
      e.key.toDouble(),
      double.tryParse(e.value['total']?.toString() ?? '0') ?? 0,
    )).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📈 Penjualan 30 Hari Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: null),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTopProducts() {
    final products = (_data?['top_products'] as List? ?? []);
    if (products.isEmpty) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🏆 Produk Terlaris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...products.asMap().entries.map((e) {
            final p = e.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Terjual: ${p['sold']} unit'),
              trailing: Text(formatRupiah(double.tryParse(p['revenue']?.toString() ?? '0') ?? 0),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            );
          }),
        ]),
      ),
    );
  }
}
