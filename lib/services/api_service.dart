import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';

class ApiService {
  final Dio _dio;
  ApiService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://fakestoreapi.com'));

  Future<List<Product>> getProducts() async {
    final string = await rootBundle.loadString('Sale/api_products.json');
    final list = jsonDecode(string) as List;
    return list.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> getProduct(int id) async {
    final products = await getProducts();
    return products.firstWhere((p) => p.id == id);
  }

  Future<List<String>> getCategories() async {
    final products = await getProducts();
    return products.map((p) => p.category).toSet().toList();
  }

  Future<List<Product>> getByCategory(String name) async {
    final products = await getProducts();
    return products.where((p) => p.category == name).toList();
  }

  Future<String> login({required String username, required String password}) async {
    final res = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    return (res.data as Map)['token'] as String;
  }
}

