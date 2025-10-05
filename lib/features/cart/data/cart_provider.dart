import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../../home/data/products_inventory_provider.dart';

class CartItem {
  final Product product;
  final int quantity;
  const CartItem(this.product, this.quantity);

  CartItem copyWith({Product? product, int? quantity}) =>
      CartItem(product ?? this.product, quantity ?? this.quantity);
}

class CartController extends StateNotifier<List<CartItem>> {
  CartController(this.ref) : super(const []);

  final Ref ref;

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
  }

  double get total => state.fold(0.0, (sum, i) => sum + i.product.price * i.quantity);

  Future<void> clear() async {
    final notifier = ref.read(productsInventoryProvider.notifier);
    for (final item in state) {
      await notifier.releaseInventory(item.product.id, item.quantity);
    }
    state = const [];
  }

  Future<void> checkout() async {
    await ref.read(productsInventoryProvider.notifier).persistInventoryToDisk();
    state = const [];
  }
}

final cartProvider = StateNotifierProvider<CartController, List<CartItem>>((ref) => CartController(ref));

// Total count of items across all cart lines (sum of quantities)
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (sum, e) => sum + e.quantity);
});
