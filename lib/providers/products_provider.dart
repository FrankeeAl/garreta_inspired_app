import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart';

import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((element) => element.isFavourite).toList();
    // }
    return [..._items];
  }

  final String? authToken;
  final String? userId;

  Products(this.authToken, this._items, this.userId);

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? ' &orderBy="sellerId"&equalTo="$userId"' : '';

    final url =
        'https://merch-picker-app-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken$filterString';

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }

      final favoriteUrl =
          'https://merch-picker-app-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken';
      final isFavoriteResponse = await http.get(Uri.parse(favoriteUrl));
      final favoriteData = json.decode(isFavoriteResponse.body);

      final List<Product> loadedData = [];
      extractedData.forEach((productId, data) => {
            loadedData.add(
              Product(
                id: productId,
                title: data['title'],
                description: data['description'],
                price: data['price'],
                imageUrl: data['imageUrl'],
                isFavourite: favoriteData == null
                    ? false
                    : favoriteData[productId] ?? false,
              ),
            ),
          });
      _items = loadedData;
      // print(response.body);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://merch-picker-app-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'sellerId': userId,
        }),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      // _items.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      //  print(e);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    final url =
        'https://merch-picker-app-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken';

    if (prodIndex >= 0) {
      await http.patch(
        Uri.parse(url),
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
          'id': newProduct.id,
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('No product');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://merch-picker-app-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken';

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete.');
    }
  }
}
