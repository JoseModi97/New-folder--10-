import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import 'inventory_persistence_stub.dart'
    if (dart.library.io) 'inventory_persistence_io.dart';
import 'products_provider.dart';

final productsInventoryProvider = AsyncNotifierProvider<ProductsInventoryController, List<Product>>(ProductsInventoryController.new);

class ProductsInventoryController extends AsyncNotifier<List<Product>> {
  Future<List<Product>> _currentProducts() async {
    final existing = state.valueOrNull;
    if (existing != null) {
      return existing;
    }
    return await future;
  }

  @override
  FutureOr<List<Product>> build() async {
    return ref.watch(productsProvider.future);
  }

  Future<bool> reserveInventory(int productId, int quantity) async {
    final products = await _currentProducts();
    final updated = [...products];
    final index = updated.indexWhere((element) => element.id == productId);
    if (index == -1) {
      return false;
    }
    final product = updated[index];
    if (product.inventory < quantity) {
      return false;
    }
    updated[index] = product.copyWith(inventory: product.inventory - quantity);
    state = AsyncData(updated);
    return true;
  }

  Future<void> releaseInventory(int productId, int quantity) async {
    final products = await _currentProducts();
    final updated = [...products];
    final index = updated.indexWhere((element) => element.id == productId);
    if (index == -1) {
      return;
    }
    final product = updated[index];
    updated[index] = product.copyWith(inventory: product.inventory + quantity);
    state = AsyncData(updated);
  }

  Future<void> persistInventoryToDisk() async {
    final products = await _currentProducts();
    final encoder = const JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert([
      for (final product in products) product.toJson(),
    ]);
    await saveInventoryData(jsonString);
  }
}
