import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../../home/data/products_inventory_provider.dart';
import 'cart_persistence.dart';

class CartItem {
  final Product product;
  final int quantity;
  const CartItem(this.product, this.quantity);

  CartItem copyWith({Product? product, int? quantity}) =>
      CartItem(product ?? this.product, quantity ?? this.quantity);
}

class CartController extends StateNotifier<List<CartItem>> {
  CartController(this.ref) : super(const []) {
    Future.microtask(_restoreCart);
  }

  final Ref ref;

  Future<void> _restoreCart() async {
    try {
      final persisted = await readPersistedCart();
      if (persisted.isEmpty) {
        return;
      }

      final inventoryNotifier = ref.read(productsInventoryProvider.notifier);
      var products = [...await ref.read(productsInventoryProvider.future)];
      final restoredItems = <CartItem>[];

      for (final line in persisted) {
        final index = products.indexWhere((element) => element.id == line.productId);
        if (index == -1) {
          continue;
        }

        final product = products[index];
        final available = product.inventory;
        if (available <= 0) {
          continue;
        }

        final desired = line.quantity;
        final quantity = desired <= 0
            ? 0
            : (desired > available ? available : desired);
        if (quantity <= 0) {
          continue;
        }

        final reserved = await inventoryNotifier.reserveInventory(product.id, quantity);
        if (!reserved) {
          continue;
        }

        restoredItems.add(CartItem(product, quantity));
        products[index] = product.copyWith(inventory: available - quantity);
      }

      if (restoredItems.isEmpty) {
        await clearPersistedCart();
        return;
      }

      state = restoredItems;
      await _persistCart();
    } catch (_) {
      await clearPersistedCart();
    }
  }

  Future<void> _persistCart() async {
    await writePersistedCart([
      for (final item in state)
        PersistedCartLine(productId: item.product.id, quantity: item.quantity),
    ]);
  }

  Future<bool> add(Product p, [int quantity = 1]) async {
    final inventoryNotifier = ref.read(productsInventoryProvider.notifier);
    final reserved = await inventoryNotifier.reserveInventory(p.id, quantity);
    if (!reserved) {
      return false;
    }

    final idx = state.indexWhere((e) => e.product.id == p.id);
    if (idx == -1) {
      state = [...state, CartItem(p, quantity)];
    } else {
      final updated = [...state];
      final item = updated[idx];
      updated[idx] = item.copyWith(quantity: item.quantity + quantity);
      state = updated;
    }
    await _persistCart();
    return true;
  }

  Future<void> remove(Product p) async {
    final idx = state.indexWhere((e) => e.product.id == p.id);
    if (idx == -1) {
      return;
    }
    final item = state[idx];
    await ref.read(productsInventoryProvider.notifier).releaseInventory(p.id, item.quantity);
    state = state.where((e) => e.product.id != p.id).toList();
    await _persistCart();
  }

  Future<void> decrement(Product p) async {
    final idx = state.indexWhere((e) => e.product.id == p.id);
    if (idx == -1) return;
    final updated = [...state];
    final item = updated[idx];
    final q = item.quantity - 1;
    await ref.read(productsInventoryProvider.notifier).releaseInventory(p.id, 1);
    if (q <= 0) {
      updated.removeAt(idx);
    } else {
      updated[idx] = item.copyWith(quantity: q);
    }
    state = updated;
    await _persistCart();
  }

  double get total => state.fold(0.0, (sum, i) => sum + i.product.price * i.quantity);

  Future<void> clear() async {
    final notifier = ref.read(productsInventoryProvider.notifier);
    for (final item in state) {
      await notifier.releaseInventory(item.product.id, item.quantity);
    }
    state = const [];
    await clearPersistedCart();
  }

  Future<void> checkout() async {
    await ref.read(productsInventoryProvider.notifier).persistInventoryToDisk();
    state = const [];
    await clearPersistedCart();
  }
}

final cartProvider = StateNotifierProvider<CartController, List<CartItem>>((ref) => CartController(ref));

// Total count of items across all cart lines (sum of quantities)
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (sum, e) => sum + e.quantity);
});
