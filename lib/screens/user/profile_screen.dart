import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Address> _addresses = [];
  bool _loadingAddr = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;
    setState(() => _loadingAddr = true);
    final res = await ApiService.get('/addresses', auth: true);
    setState(() {
      _addresses = (res['data'] as List? ?? []).map((a) => Address.fromJson(a)).toList();
      _loadingAddr = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: EmptyState(
          icon: '👤',
          title: 'Belum Login',
          subtitle: 'Masuk untuk melihat profil kamu',
          actionLabel: 'Masuk',
          onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        ),
      );
    }
    final user = auth.user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          _buildHeader(user),
          const SizedBox(height: 8),
          _buildMenuSection('Akun', [
            _menuTile(Icons.person_outline, 'Edit Profil', () => _editProfile(user)),
            _menuTile(Icons.lock_outline, 'Ubah Password', () {}),
            _menuTile(Icons.notifications_outlined, 'Notifikasi', () {}),
          ]),
          _buildMenuSection('Belanja', [
            _menuTile(Icons.shopping_bag_outlined, 'Riwayat Pesanan', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()))),
            _menuTile(Icons.favorite_outline, 'Wishlist', () {}),
            _menuTile(Icons.star_outline, 'Ulasan Saya', () {}),
          ]),
          _buildAddressSection(),
          _buildMenuSection('Lainnya', [
            _menuTile(Icons.help_outline, 'Bantuan', () {}),
            _menuTile(Icons.privacy_tip_outlined, 'Kebijakan Privasi', () {}),
            _menuTile(Icons.info_outline, 'Tentang Aplikasi', () {}),
            _menuTile(Icons.logout, 'Keluar', _logout, color: AppColors.error),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(User user) => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: AppColors.primary.withOpacity(0.2),
        child: user.avatar != null
            ? ClipOval(child: Image.network('${AppConfig.baseUrl}/${user.avatar}', width: 80, height: 80, fit: BoxFit.cover))
            : Text(user.name[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(user.email, style: const TextStyle(color: AppColors.textSecondary)),
        if (user.phone != null && user.phone!.isNotEmpty)
          Text(user.phone!, style: const TextStyle(color: AppColors.textSecondary)),
      ])),
    ]),
  );

  Widget _buildAddressSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('📍 Alamat Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        TextButton(
          onPressed: () => _addAddress(),
          child: const Text('+ Tambah', style: TextStyle(color: AppColors.primary)),
        ),
      ]),
      const SizedBox(height: 8),
      if (_loadingAddr) const Center(child: CircularProgressIndicator())
      else if (_addresses.isEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Text('Belum ada alamat tersimpan', style: TextStyle(color: AppColors.textSecondary)),
        )
      else ..._addresses.map((a) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(a.label == 'Rumah' ? Icons.home : Icons.work, color: AppColors.primary, size: 20),
          ),
          title: Text('${a.label} - ${a.recipientName}', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(a.fullAddress, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (a.isDefault) const Icon(Icons.check_circle, color: AppColors.success, size: 18),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: () => _deleteAddress(a.id),
            ),
          ]),
        ),
      )),
    ]),
  );

  Widget _buildMenuSection(String title, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
      Container(
        color: Colors.white,
        child: Column(children: items),
      ),
    ],
  );

  Widget _menuTile(IconData icon, String title, VoidCallback onTap, {Color? color}) => ListTile(
    leading: Icon(icon, color: color ?? AppColors.textSecondary),
    title: Text(title, style: TextStyle(color: color)),
    trailing: color != null ? null : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    onTap: onTap,
  );

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Kamu akan keluar dari akun ini'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && mounted) context.read<AuthProvider>().logout();
  }

  Future<void> _editProfile(User user) async {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
          const SizedBox(height: 12),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'No. Telepon')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final res = await ApiService.put('/auth/profile', {'name': nameCtrl.text, 'phone': phoneCtrl.text}, auth: true);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res['message'] ?? ''),
                  backgroundColor: res['success'] == true ? AppColors.success : AppColors.error,
                ));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _addAddress() async {
    final formKey = GlobalKey<FormState>();
    final labelCtrl = TextEditingController(text: 'Rumah');
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    bool isDefault = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Tambah Alamat'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (Rumah/Kantor)')),
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Penerima*'), validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null),
                TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Nomor Telepon*'), validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null),
                TextFormField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'Kota*'), validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null),
                TextFormField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Alamat Lengkap*'), maxLines: 2, validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null),
                CheckboxListTile(value: isDefault, onChanged: (v) => setDialog(() => isDefault = v!),
                    title: const Text('Jadikan alamat utama'), controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await ApiService.post('/addresses', {
                  'label': labelCtrl.text, 'recipient_name': nameCtrl.text, 'phone': phoneCtrl.text,
                  'city': cityCtrl.text, 'full_address': addrCtrl.text, 'is_default': isDefault,
                }, auth: true);
                if (mounted) { Navigator.pop(ctx); _loadAddresses(); }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAddress(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Alamat?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) { await ApiService.delete('/addresses/$id', auth: true); _loadAddresses(); }
  }
}
