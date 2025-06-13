import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<RecordModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pb = PocketBase('http://127.0.0.1:8090'); // Replace with your PocketBase URL
      final result = await pb.collection('orders').getList(
            page: 1,
            perPage: 50,
            expand: 'products', // Expand products relation
          );
      setState(() {
        _orders = result.items;
        _isLoading = false;
      });
      // Debug: Cek apakah Nama_Pelanggan dan Coordinates ada di data
      for (var order in _orders) {
        print('Order ${order.id}: Nama_Pelanggan=${order.data['Nama_Pelanggan']}, Coordinates=${order.data['Coordinates']}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat pesanan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8B4513), // Cokelat tua
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E6CC), Color(0xFFFFE0B2)], // Krem ke kuning lembut
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _orders.isEmpty
                    ? const Center(child: Text('Belum ada pesanan'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          // Format Coordinates with additional string check (comma-separated)
                          final coordinates = order.data['Coordinates'] is Map
                              ? 'Lat: ${order.data['Coordinates']['lat']}, Lng: ${order.data['Coordinates']['lng']}'
                              : order.data['Coordinates'] is String && (order.data['Coordinates'] as String).contains(',')
                                  ? (order.data['Coordinates'] as String).split(',').map((c) => c.trim()).join(', ')
                                  : order.data['Coordinates']?.toString() ?? 'N/A';
                          // Handle products relation (single or multiple products)
                          final products = order.expand['products'] is List
                              ? order.expand['products']
                              : order.expand['products'] != null
                                  ? [order.expand['products']]
                                  : [];
                          final productNames = products?.isNotEmpty ?? false
                              ? (products as List)
                                  .map((p) => p.data['name']?.toString() ?? 'N/A')
                                  .join(', ')
                              : 'N/A';
                          return Card(
                            color: const Color(0xFFF5E6CC), // Krem terang
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                'Pesanan #${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5C4033), // Cokelat sedang
                                ),
                              ),
                              subtitle: Text(
                                'Pelanggan: ${order.data['Nama_Pelanggan'] ?? 'N/A'}\n'
                                'Produk: $productNames\n'
                                'Koordinat: $coordinates\n'
                                'Status: ${order.data['status'] ?? 'N/A'}\n'
                                'Tanggal: ${order.created.toString().substring(0, 16)}',
                                style: const TextStyle(color: Color(0xFF5C4033)),
                              ),
                              onTap: () {
                                // Tambahkan logika untuk detail pesanan jika diperlukan
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}