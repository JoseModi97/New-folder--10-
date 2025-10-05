import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cart_provider.dart';
import '../../../widgets/breadcrumbs.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Breadcrumbs(
            items: [
              BreadcrumbItem(title: 'Home', path: '/'),
              BreadcrumbItem(title: 'Cart', path: '/cart'),
            ],
          ),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text('Your cart is empty.'),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: item.product.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        title: Text(item.product.title),
                        subtitle: Text('\$${item.product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => cartNotifier.decrement(item.product),
                            ),
                            Text(item.quantity.toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => cartNotifier.add(item.product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => cartNotifier.remove(item.product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (cartItems.isNotEmpty) _CartTotals(),
        ],
      ),
    );
  }
}

class _CartTotals extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartProvider.notifier).total;
    final tax = total * 0.1;
    final subtotal = total - tax;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Totals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('\$${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax (10%)'),
              Text('\$${tax.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement checkout
            },
            child: const Text('Checkout'),
          ),
          const SizedBox(height: 8.0),
          OutlinedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
            },
            child: const Text('Clear Cart'),
          ),
        ],
      ),
    );
  }
}