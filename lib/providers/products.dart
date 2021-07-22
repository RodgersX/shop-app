import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/http_exception.dart';

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
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
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
        id: json.decode(resp.body)['name'],
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url =
        'https://flutter-update-afd56-default-rtdb.firebaseio.com/products/$id.json';
    await http.patch(
      Uri.parse(url),
      body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price
      }),
    );
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...nothing');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-update-afd56-default-rtdb.firebaseio.com/products/$id.json';

    // save a pointer to the deleted prouct to memory.
    //Will live on in the memory
    final existingProdIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProdIndex];

    _items.removeAt(existingProdIndex);
    notifyListeners();

    // optimistic updating
    // roll back the removal
    final resp = await http.delete(Uri.parse(url));
    if (resp.statusCode >= 400) {
      _items.insert(existingProdIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product'); // same as return
    }
    // ignore: null_check_always_fails
    existingProduct = null!;
  }
}
