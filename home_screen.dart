import 'package:flutter/material.dart';
import 'package:uji/components/product_item.dart';
import 'package:uji/services/pocketbase_service.dart';
import 'package:uji/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  Map<String, dynamic>? _selectedProduct;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _orders = [];
  Map<String, double> _coordinates = {'latitude': 0.0, 'longitude': 0.0};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final products = await PocketBaseService().getProducts();
    final orders = await PocketBaseService().getOrders();
    setState(() {
      _products = products;
      _orders = orders;
    });
  }

  Future<void> _getLocation() async {
    try {
      final position = await Utils.getLocation();
      if (!mounted) return; // Check if widget is still mounted
      setState(() {
        _coordinates = {'latitude': position.latitude, 'longitude': position.longitude};
      });
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedProduct != null && _nameController.text.isNotEmpty && _coordinates['latitude']! > 0) {
      final orderData = {
        'customerName': _nameController.text,
        'productId': _selectedProduct!['id'],
        'coordinates': _coordinates,
        'status': 'pending',
      };
      await PocketBaseService().createOrder(orderData);
      final updatedOrders = await PocketBaseService().getOrders();
      if (!mounted) return; // Check if widget is still mounted
      setState(() {
        _orders = updatedOrders;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!')));
    } else {
      if (!mounted) return; // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan isi semua field dan pilih produk.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toko Roti & Kue Online')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Produk:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return ProductItem(
                    product: _products[index],
                    onSelect: (product) => setState(() => _selectedProduct = product),
                  );
                },
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Masukkan nama Anda'),
            ),
            ElevatedButton(onPressed: _getLocation, child: const Text('Ambil Lokasi')),
            Text('Koordinat: Latitude ${_coordinates['latitude']}, Longitude ${_coordinates['longitude']}'),
            ElevatedButton(onPressed: _placeOrder, child: const Text('Pesan')),
            const SizedBox(height: 20),
            const Text('Pesanan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Customer: ${order['customerName']}, Product: ${_products.firstWhere((p) => p['id'] == order['productId'], orElse: () => {'name': 'Unknown'})['name']}'),
                      subtitle: Text('Coords: ${order['coordinates']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}