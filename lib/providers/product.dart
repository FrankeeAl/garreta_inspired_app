import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });

  void _setFavorite(bool newFavorite) {
    isFavourite = newFavorite;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final url =
        'https://merch-picker-app-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token';

    final oldStatus = isFavourite;
    _setFavorite(!isFavourite);
    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(
          isFavourite,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavorite(oldStatus);
      }
    } catch (e) {
      _setFavorite(oldStatus);
      rethrow;
    }
  }
}
