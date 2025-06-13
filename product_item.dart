import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onSelect;

  const ProductItem({super.key, required this.product, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product['name']),
      subtitle: Text('Harga: Rp ${product['price'] ?? 0}'),
      trailing: IconButton(
        icon: const Icon(Icons.add_shopping_cart),
        onPressed: () => onSelect(product),
      ),
    );
  }
}