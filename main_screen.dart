import 'package:flutter/material.dart';
import 'package:uji/screens/profile_screen.dart';
import 'package:uji/screens/product_screen.dart';
import 'package:uji/screens/checkout_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _cart = []; // Manage cart state here

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Callback to update cart from ProductScreen
  void _updateCart(List<Map<String, dynamic>> newCart) {
    setState(() {
      _cart = newCart;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const ProfileScreen(),
      ProductScreen(onCartUpdated: _updateCart, cart: _cart), // Pass cart and callback
      CheckoutScreen(cart: _cart), // Pass cart to CheckoutScreen
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Checkout'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}