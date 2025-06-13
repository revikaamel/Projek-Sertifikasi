import 'package:flutter/material.dart';
import 'package:uji/services/pocketbase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = PocketBaseService().getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E6CC), Color(0xFFE0B2)], // Krem ke kuning lembut
          ),
        ),
        child: Center(
          child: Card(
            color: const Color(0xFFF5E6CC), // Krem terang untuk card
            elevation: 8,
            margin: const EdgeInsets.all(24.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 80, color: Color(0xFF5C4033)), // Ikon profil dengan warna cokelat
                  const SizedBox(height: 16),
                  const Text(
                    'Profil Pengguna',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C4033), // Cokelat sedang
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nama: ${_user?['name'] ?? 'Tidak tersedia'}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF5C4033), // Cokelat sedang
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Email: ${_user?['email'] ?? 'Tidak tersedia'}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF5C4033), // Cokelat sedang
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      PocketBaseService().logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513), // Cokelat tua
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}