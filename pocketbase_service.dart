import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  final PocketBase _pb = PocketBase('http://127.0.0.1:8090');

  Future<void> login(String email, String password) async {
    await _pb.collection('users').authWithPassword(email, password);
  }

  Future<void> register(String email, String password, String name) async {
    await _pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'name': name,
    });
  }

  Future<void> logout() async {
    _pb.authStore.clear();
  }

  Map<String, dynamic>? getCurrentUser() {
    return _pb.authStore.model?.data;
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final records = await _pb.collection('products').getFullList();
    return records
        .map((record) => {'id': record.id, 'name': record.data['name'], 'price': record.data['price'], ...record.data})
        .toList();
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final records = await _pb.collection('orders').getFullList();
    return records.map((record) => {
      'id': record.id,
      'customerName': record.data['customerName'],
      'productId': record.data['productId'],
      'coordinates': record.data['coordinates'],
      'status': record.data['status'],
    }).toList();
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await _pb.collection('orders').create(body: orderData);
  }
}