import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:uji/screens/checkout_screen.dart';
import 'package:uji/services/pocketbase_service.dart';

/// Halaman untuk menampilkan daftar produk dari PocketBase dengan fitur keranjang belanja.
class ProductScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function(List<Map<String, dynamic>>) onCartUpdated;

  const ProductScreen({
    super.key,
    required this.cart,
    required this.onCartUpdated,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> _products = [];
  String _errorMessage = '';

  /// Menentukan base URL berdasarkan platform.
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8090/api/files/products'; // Untuk Flutter Web/Chrome
    } else {
      // Untuk emulator Android
      return 'http://10.0.2.2:8090/api/files/products';
      // Uncomment dan ganti dengan IP lokal Anda untuk perangkat fisik
      // return 'http://192.168.1.100:8090/api/files/products';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  /// Mengambil daftar produk dari PocketBase dengan pengecekan konektivitas.
  Future<void> _fetchProducts() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Tidak ada koneksi internet';
          });
        }
        return;
      }

      final products = await PocketBaseService().getProducts();
      print('Fetched products: $products'); // Debugging data lengkap
      for (var product in products) {
        print('Product details: name=${product['name']}, id=${product['id']}, image=${product['image']}'); // Debugging per produk
      }

      if (mounted) {
        setState(() {
          _products = products;
          _errorMessage = '';
        });
      }
    } catch (e) {
      print('Error fetching products: $e'); // Debugging error
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat produk: $e';
        });
      }
    }
  }

  /// Menambahkan produk ke keranjang belanja.
  void _addToCart(Map<String, dynamic> product) {
    final updatedCart = List<Map<String, dynamic>>.from(widget.cart);
    final existing = updatedCart.firstWhere(
      (item) => item['id'] == product['id'],
      orElse: () => {...product, 'quantity': 0},
    );
    if (existing['quantity'] == 0) {
      updatedCart.add({...product, 'quantity': 1});
    } else {
      existing['quantity'] += 1;
    }
    widget.onCartUpdated(updatedCart);
  }

  /// Menghapus satu unit produk dari keranjang belanja.
  void _removeFromCart(Map<String, dynamic> product) {
    final updatedCart = List<Map<String, dynamic>>.from(widget.cart);
    final existing = updatedCart.firstWhere(
      (item) => item['id'] == product['id'],
      orElse: () => {...product, 'quantity': 0},
    );
    if (existing['quantity'] > 0) {
      existing['quantity'] -= 1;
      if (existing['quantity'] == 0) {
        updatedCart.removeWhere((item) => item['id'] == product['id']);
      }
    }
    widget.onCartUpdated(updatedCart);
  }

  /// Navigasi ke halaman checkout.
  void _navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: widget.cart),
      ),
    );
  }

  /// Membuat URL gambar produk dari PocketBase.
  String _getImageUrl(Map<String, dynamic> product) {
    final imageFilename = product['gambar']?.toString();
    final productId = product['id']?.toString();
    if (imageFilename != null &&
        imageFilename.isNotEmpty &&
        productId != null &&
        productId.isNotEmpty &&
        imageFilename.contains('.')) {
      final imageUrl = '$_baseUrl/$productId/$imageFilename';
      print('Generated image URL: $imageUrl'); // Debugging URL
      return imageUrl;
    }
    print('Invalid image data for ${product['name']}: image=$imageFilename, id=$productId'); // Debugging error
    return 'https://via.placeholder.com/100'; // Fallback image
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etalase Produk'),
        backgroundColor: const Color(0xFF8B4513), // Cokelat tua
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchProducts,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: widget.cart.isNotEmpty ? _navigateToCheckout : null,
              ),
              if (widget.cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: const Color(0xFFD7CCC8), // Cokelat muda
                    child: Text(
                      widget.cart.length.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5C4033), // Cokelat gelap
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E6CC), Color(0xFFFFE0B2)], // Gradasi krem
          ),
        ),
        child: _errorMessage.isNotEmpty
            ? Center(
                child: Card(
                  color: const Color(0xFFF5E6CC),
                  elevation: 8,
                  margin: const EdgeInsets.all(24.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, size: 80, color: Color(0xFF5C4033)),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF5C4033),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchProducts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : _products.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5C4033)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final cartItem = widget.cart.firstWhere(
                        (item) => item['id'] == product['id'],
                        orElse: () => {'quantity': 0},
                      );
                      return Card(
                        color: const Color(0xFFFFF3E0), // Krem pucat
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: _getImageUrl(product),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const SizedBox(
                                width: 60,
                                height: 60,
                                child: Center(
                                  child: CircularProgressIndicator(color: Color(0xFF5C4033)),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print('Image load error for ${product['name']}: $error'); // Debugging error
                                return Image.network(
                                  'https://via.placeholder.com/100',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          title: Text(
                            product['name'] ?? 'Nama tidak tersedia',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5C4033),
                            ),
                          ),
                          subtitle: Text(
                            'Harga: Rp ${product['price']?.toString() ?? '0'}',
                            style: const TextStyle(color: Color(0xFF5C4033)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Color(0xFF5C4033)),
                                onPressed: cartItem['quantity'] > 0
                                    ? () => _removeFromCart(product)
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFD7CCC8)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  cartItem['quantity'].toString(),
                                  style: const TextStyle(color: Color(0xFF5C4033)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Color(0xFF5C4033)),
                                onPressed: () => _addToCart(product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}