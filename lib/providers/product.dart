import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isfavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isfavorite = false,
  });

  void _setFavValue(bool newValue) {
    isfavorite = newValue;
    notifyListeners();
  }

  Future<void> togglefavoriteStatus() async {
    final url =
        'https://flutter-update-afd56-default-rtdb.firebaseio.com/products/$id.json';
    final oldStatus = isfavorite;
    isfavorite = !isfavorite;
    notifyListeners();
    try {
      final resp = await http.patch(
        Uri.parse(url),
        body: json.encode({'isfavorite': isfavorite}),
      );
      if (resp.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (err) {
      _setFavValue(oldStatus);
    }
  }
}
