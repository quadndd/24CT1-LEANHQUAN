// ============================================================
// saved_locations_screen.dart — Màn hình Địa điểm đã lưu (Khách hàng)
// Quản lý danh sách địa điểm yêu thích: Nhà, Công ty...
// Cho phép thêm, sửa, xóa địa điểm đã lưu
// ============================================================
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';

class CustomerSavedLocationsScreen extends StatefulWidget {
  const CustomerSavedLocationsScreen({super.key});

  @override
  State<CustomerSavedLocationsScreen> createState() => _CustomerSavedLocationsScreenState();
}

class _CustomerSavedLocationsScreenState extends State<CustomerSavedLocationsScreen> {
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('saved_places')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _locations = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      // Bảng chưa tồn tại → fallback trống
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addLocation() async {
    final labelCtrl   = TextEditingController();
    final addressCtrl = TextEditingController();
    String selectedType = 'home';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thêm địa điểm mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loại địa điểm
            StatefulBuilder(builder: (ctx2, setInner) {
              return Wrap(
                spacing: 8,
                children: [
                  _typeChip('Nhà', 'home', Icons.home, selectedType, (v) => setInner(() => selectedType = v)),
                  _typeChip('Cơ quan', 'work', Icons.work, selectedType, (v) => setInner(() => selectedType = v)),
                  _typeChip('Khác', 'other', Icons.place, selectedType, (v) => setInner(() => selectedType = v)),
                ],
              );
            }),
            const SizedBox(height: 12),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(labelText: 'Tên địa điểm (VD: Nhà)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Địa chỉ đầy đủ', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (labelCtrl.text.isEmpty || addressCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              await _saveLocation(labelCtrl.text.trim(), addressCtrl.text.trim(), selectedType);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String label, String value, IconData icon, String selected, Function(String) onTap) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006E2E) : const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF3D4A3D)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : const Color(0xFF3D4A3D))),
        ]),
      ),
    );
  }

  Future<void> _saveLocation(String label, String address, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    if (userId == null) return;

    try {
      await Supabase.instance.client.from('saved_places').insert({
        'user_id': userId,
        'label': label,
        'address': address,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
      });
      await _loadLocations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu địa điểm: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteLocation(String id) async {
    try {
      await Supabase.instance.client.from('saved_places').delete().eq('id', id);
      await _loadLocations();
    } catch (e) {
      debugPrint('Lỗi xóa: $e');
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      default: return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Địa điểm đã lưu', style: TextStyle(color: Color(0xFF151C27), fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF151C27)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF00B14F)),
            onPressed: _addLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B14F)))
          : _locations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place_outlined, size: 64, color: Color(0xFFBCCBB9)),
                      const SizedBox(height: 12),
                      const Text('Chưa có địa điểm nào', style: TextStyle(fontSize: 16, color: Color(0xFF6D7B6C))),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addLocation,
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm địa điểm'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006E2E), foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _locations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final loc = _locations[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(20)),
                        child: Icon(_iconForType(loc['type'] ?? 'other'), color: const Color(0xFF006E2E)),
                      ),
                      title: Text(loc['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(loc['address'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A)),
                        onPressed: () => _deleteLocation(loc['id'].toString()),
                      ),
                    );
                  },
                ),
    );
  }
}


