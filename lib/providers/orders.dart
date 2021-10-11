import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url =
        'https://merch-picker-app-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken';
    final response = await http.get(Uri.parse(url));
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData.isEmpty) {
      return;
    }

    extractedData.forEach((orderId, data) => {
          loadedOrders.add(
            OrderItem(
              id: orderId,
              amount: data['amount'],
              dateTime: DateTime.parse(data['dateTime']),
              products: (data['products'] as List<dynamic>)
                  .map(
                    (item) => CartItem(
                      id: item['id'],
                      title: item['title'],
                      price: item['price'],
                      quantity: item['quantity'],
                    ),
                  )
                  .toList(),
            ),
          )
        });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
    //print(json.decode(response.body));
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://merch-picker-app-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
    try {
      await http
          .post(
            Uri.parse(url),
            body: json.encode(
              {
                'amount': total.toDouble(),
                'dateTime': timeStamp.toIso8601String(),
                'products': cartProducts
                    .map((e) => {
                          'id': e.id,
                          'title': e.title,
                          'quantity': e.quantity,
                          'price': e.price,
                        })
                    .toList()
              },
            ),
          )
          .then((response) => {
                _orders.insert(
                  0,
                  OrderItem(
                    id: json.decode(response.body)['name'],
                    amount: total,
                    products: cartProducts,
                    dateTime: timeStamp,
                  ),
                ),
                notifyListeners(),
              });
    } catch (e) {
      rethrow;
    }
  }
}
