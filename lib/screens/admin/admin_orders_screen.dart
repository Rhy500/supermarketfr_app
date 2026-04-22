// ======================== ADMIN ORDERS ========================
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _tabs = ['Semua', 'Pending', 'Diproses', 'Dikirim', 'Selesai'];
  final _statuses = [null, 'pending', 'processing', 'shipped', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Manajemen Pesanan'),
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
      children: _statuses.map((s) => _AdminOrderTab(status: s)).toList(),
    ),
  );
}

class _AdminOrderTab extends StatefulWidget {
  final String? status;
  const _AdminOrderTab({this.status});
  @override State<_AdminOrderTab> createState() => _AdminOrderTabState();
}

class _AdminOrderTabState extends State<_AdminOrderTab> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final query = widget.status != null ? {'status': widget.status!} : null;
    final res = await ApiService.get('/admin/orders', auth: true, query: query);
    setState(() {
      _orders = List<Map<String, dynamic>>.from(res['data'] ?? []);
      _loading = false;
    });
  }

  void _showUpdateStatus(Map<String, dynamic> order) {
    String status = order['order_status'];
    final trackCtrl = TextEditingController(text: order['tracking_number'] ?? '');
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text('Update Pesanan #${order['order_number']}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: status,
              items: ['pending', 'processing', 'shipped', 'completed', 'cancelled']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
              onChanged: (v) => setDialog(() => status = v!),
              decoration: const InputDecoration(labelText: 'Status Pesanan'),
            ),
            if (status == 'shipped') ...[
              const SizedBox(height: 12),
              TextField(controller: trackCtrl, decoration: const InputDecoration(labelText: 'Nomor Resi')),
            ],
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final body = {'status': status, 'tracking_number': trackCtrl.text};
                final res = await ApiService.put('/admin/orders/${order['id']}/status', body, auth: true);
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

  void _showVerifyPayment(Map<String, dynamic> order) {
    String paymentStatus = order['payment_status'];
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Verifikasi Pembayaran'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Order: #${order['order_number']}'),
            Text('Total: ${formatRupiah(double.tryParse(order['total'].toString()) ?? 0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: paymentStatus,
              items: ['pending', 'paid', 'failed', 'refunded']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
              onChanged: (v) => setDialog(() => paymentStatus = v!),
              decoration: const InputDecoration(labelText: 'Status Pembayaran'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final res = await ApiService.put('/admin/orders/${order['id']}/payment',
                    {'payment_status': paymentStatus}, auth: true);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? '')));
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_orders.isEmpty) return const EmptyState(icon: '📋', title: 'Tidak ada pesanan', subtitle: '');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _orders.length,
        itemBuilder: (_, i) {
          final o = _orders[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('#${o['order_number']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  OrderStatusBadge(status: o['order_status']),
                ]),
                const SizedBox(height: 4),
                Text('${o['customer_name']} · ${o['customer_email']}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text(o['created_at'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const Divider(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(formatRupiah(double.tryParse(o['total']?.toString() ?? '0') ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                    OrderStatusBadge(status: o['payment_status']),
                  ]),
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.payments_outlined, color: Colors.green),
                      tooltip: 'Verifikasi Bayar',
                      onPressed: () => _showVerifyPayment(o),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blue),
                      tooltip: 'Update Status',
                      onPressed: () => _showUpdateStatus(o),
                    ),
                  ]),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ======================== ADMIN USERS ========================
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.get('/admin/users', auth: true);
    setState(() {
      _users = List<Map<String, dynamic>>.from(res['data'] ?? []);
      _loading = false;
    });
  }

  Future<void> _toggleBlock(Map<String, dynamic> user) async {
    final isBlocked = user['is_blocked'] == '1';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isBlocked ? 'Aktifkan User?' : 'Blokir User?'),
        content: Text(isBlocked ? 'User ${user['name']} akan diaktifkan kembali' : 'User ${user['name']} akan diblokir'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isBlocked ? null : ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(isBlocked ? 'Aktifkan' : 'Blokir'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ApiService.put('/admin/users/${user['id']}/toggle-block', {}, auth: true);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) =>
        '${u['name']} ${u['email']}'.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen User (${_users.length})'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari user...',
                prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: filtered.isEmpty
                  ? const EmptyState(icon: '👥', title: 'User tidak ditemukan', subtitle: '')
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final u = filtered[i];
                        final isBlocked = u['is_blocked'] == '1';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isBlocked ? AppColors.error.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                              child: Text(
                                (u['name'] as String? ?? 'U')[0].toUpperCase(),
                                style: TextStyle(color: isBlocked ? AppColors.error : AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Row(children: [
                              Text(u['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (isBlocked) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('BLOKIR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ]),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(u['email'] ?? ''),
                              Text('Bergabung: ${u['created_at'] ?? ''}', style: const TextStyle(fontSize: 11)),
                            ]),
                            trailing: IconButton(
                              icon: Icon(isBlocked ? Icons.lock_open : Icons.block,
                                  color: isBlocked ? AppColors.success : AppColors.error),
                              tooltip: isBlocked ? 'Aktifkan' : 'Blokir',
                              onPressed: () => _toggleBlock(u),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
