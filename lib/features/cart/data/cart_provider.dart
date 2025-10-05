import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  const CartItem(this.product, this.quantity);

  CartItem copyWith({Product? product, int? quantity}) =>
      CartItem(product ?? this.product, quantity ?? this.quantity);
}

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super(const []);

  void add(Product p, [int quantity = 1]) {
    final idx = state.indexWhere((e) => e.product.id == p.id);
    if (idx == -1) {
      state = [...state, CartItem(p, quantity)];
    } else {
      final updated = [...state];
      final item = updated[idx];
      updated[idx] = item.copyWith(quantity: item.quantity + quantity);
      state = updated;
    }
  }

  void remove(Product p) {
    state = state.where((e) => e.product.id != p.id).toList();
  }

  void decrement(Product p) {
    final idx = state.indexWhere((e) => e.product.id == p.id);
    if (idx == -1) return;
    final updated = [...state];
    final item = updated[idx];
    final q = item.quantity - 1;
    if (q <= 0) {
      updated.removeAt(idx);
    } else {
      updated[idx] = item.copyWith(quantity: q);
    }
    state = updated;
  }

  double get total => state.fold(0.0, (sum, i) => sum + i.product.price * i.quantity);

  void clear() {
    state = const [];
  }
}

final cartProvider = StateNotifierProvider<CartController, List<CartItem>>((ref) => CartController());

// Total count of items across all cart lines (sum of quantities)
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (sum, e) => sum + e.quantity);
});
