import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

// use of mixins
class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isfavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    var url =
        'https://flutter-update-afd56-default-rtdb.firebaseio.com/products.json';
    try {
      final resp = await http.get(Uri.parse(url));
      final extractedData = json.decode(resp.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            isfavorite: prodData['isfavorite']));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addProduct(Product prod) async {
    var url =
        'https://flutter-update-afd56-default-rtdb.firebaseio.com/products.json';

    try {
      final resp = await http.post(
        Uri.parse(url),
        body: json.encode({
          'title': prod.title,
          'description': prod.description,
          'imageUrl': prod.imageUrl,
          'price': prod.price,
          'isfavorite': prod.isfavorite
        }),
      );

      final newProduct = Product(
        description: prod.description,
        title: prod.title,
        price: prod.price,
        imageUrl: prod.imageUrl,
        id: resp.body,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  void updateProduct(String id, Product newProduct) {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...nothing');
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
