import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fakestore_custom_ui/models/product.dart';
import 'package:fakestore_custom_ui/features/home/data/products_provider.dart';

final productsInventoryProvider = AsyncNotifierProvider<ProductsInventoryController, List<Product>>(ProductsInventoryController.new);

class ProductsInventoryController extends AsyncNotifier<List<Product>> {
  @override
  FutureOr<List<Product>> build() async {
    return ref.watch(productsProvider.future);
  }

  void decreaseInventory(int productId, int quantity) async {
    final products = await future;
    state = AsyncData([
      for (final product in products)
        if (product.id == productId)
          product.copyWith(inventory: product.inventory - quantity)
        else
          product,
    ]);
  }
}
