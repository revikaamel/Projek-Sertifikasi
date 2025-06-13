import 'package:flutter/material.dart';
import 'package:uji/services/pocketbase_service.dart';
import 'package:uji/utils/utils.dart';
import 'dart:developer';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function()? onOrderPlaced;

  const CheckoutScreen({super.key, required this.cart, this.onOrderPlaced});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final Map<String, double> _coordinates = {'latitude': 0.0, 'longitude': 0.0};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final position = await Utils.getLocation();
      if (mounted) {
        setState(() {
          _coordinates['latitude'] = position.latitude;
          _coordinates['longitude'] = position.longitude;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil lokasi: $e'),
           backgroundColor: const Color(0xFF8B4513), // Cokelat tua
          ),
        );
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama pelanggan harus diisi.'),
          backgroundColor: const Color(0xFF8B4513), // Cokelat tua
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_coordinates['latitude'] == 0.0 || _coordinates['longitude'] == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi harus diambil terlebih dahulu.'),
          backgroundColor: const Color(0xFF8B4513), // Cokelat tua
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang kosong. Tambahkan produk terlebih dahulu.'),
          backgroundColor: const Color(0xFF8B4513), // Cokelat tua
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final orderData = {
      'Nama_Pelanggan': _nameController.text,
      'products': widget.cart.map((item) => item['id'] ?? '').toList(),
      'coordinates': {
        'latitude': _coordinates['latitude'],
        'longitude': _coordinates['longitude'],
      },
      'status': 'pending',
      'createdBy': PocketBaseService().getCurrentUser()?['id'] ?? '',
    };

    debugPrint('Sending order data: $orderData');

    try {
      await PocketBaseService().createOrder(orderData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat!'),
            backgroundColor: const Color(0xFF8B4513), // Cokelat tua
          ),
        );
        _nameController.clear();
        setState(() {
          _coordinates['latitude'] = 0.0;
          _coordinates['longitude'] = 0.0;
        });
        widget.onOrderPlaced?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: $e'),
            backgroundColor: const Color(0xFF8B4513), // Cokelat tua
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cart.fold(
      0.0,
      (sum, item) => sum + ((item['price']?.toDouble() ?? 0.0) * (item['quantity'] ?? 1)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF8B4513), // Cokelat tua
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E6CC), Color(0xFFFFE0B2)], // Gradasi krem
          ),
        ),
        child: Center(
          child: Card(
            color: const Color(0xFFF5E6CC), // Krem terang
            elevation: 8,
            margin: const EdgeInsets.all(24.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shopping_cart_checkout, size: 80, color: const Color(0xFF5C4033)), // Coklat sedang
                  const SizedBox(height: 16),
                  Text(
                    'Checkout Pesanan',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C4033), // Coklat sedang
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Pelanggan',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD7CCC8)), // Coklat muda
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _getLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513), // Coklat tua
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Ambil Lokasi'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Koordinat: Lat ${_coordinates['latitude']}, Long ${_coordinates['longitude']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5C4033), 
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Produk:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C4033), // Coklat sedang
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.cart.length,
                      itemBuilder: (context, index) {
                        final item = widget.cart[index];
                        return Card(
                          color: const Color(0xFFF5E6CC), // Krem pucat
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            title: Text(
                              item['name'] ?? 'Nama tidak tersedia',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C4033), // Coklat sedang
                              ),
                            ),
                            subtitle: Text(
                              'Jumlah: ${item['quantity'] ?? 0} | Harga: Rp ${item['price'] ?? 0} | Subtotal: Rp ${(item['price']?.toDouble() ?? 0.0) * (item['quantity'] ?? 1)}',
                              style: const TextStyle(color: Color(0xFF5C4033)), // Coklat sedang
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: Rp ${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C4033), // Coklat sedang
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513), // Coklat tua
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Buat Pesanan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}