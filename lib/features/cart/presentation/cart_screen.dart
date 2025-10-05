import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cart_provider.dart';
import '../../home/data/products_inventory_provider.dart';
import '../../../services/daraja_service.dart';
import '../../../widgets/breadcrumbs.dart';
import '../../../widgets/product_image.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: const CartContents(),
    );
  }
}

class CartContents extends ConsumerWidget {
  final bool showBreadcrumbs;
  final VoidCallback? onClose;

  const CartContents({super.key, this.showBreadcrumbs = true, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final inventoryState = ref.watch(productsInventoryProvider);

    final closeAction = onClose ?? () => Navigator.of(context).maybePop();

    return Column(
      children: [
        if (showBreadcrumbs)
          Breadcrumbs(
            items: [
              BreadcrumbItem(title: 'Home', path: '/'),
              BreadcrumbItem(title: 'Cart', path: '/cart'),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Your Cart',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close cart',
                  onPressed: closeAction,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
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
                    final available = inventoryState.maybeWhen(
                      data: (products) =>
                          products.firstWhere((element) => element.id == item.product.id, orElse: () => item.product).inventory,
                      orElse: () => item.product.inventory,
                    );
                    return ListTile(
                      leading: ProductImage(
                        image: item.product.image,
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
                            onPressed: () async {
                              await cartNotifier.decrement(item.product);
                            },
                          ),
                          Text(item.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              final added = await cartNotifier.add(item.product);
                              if (!added && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Only $available left in stock.')),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await cartNotifier.remove(item.product);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (cartItems.isNotEmpty) const _CartTotals(),
      ],
    );
  }
}

class _CartTotals extends ConsumerWidget {
  const _CartTotals({super.key});

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
            onPressed: () async {
              final navigator = Navigator.of(context, rootNavigator: true);
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              try {
                final receipt = await ref.read(cartProvider.notifier).checkout();
                if (navigator.mounted) {
                  navigator.pop();
                }
                if (context.mounted) {
                  await showDialog<void>(
                    context: context,
                    builder: (_) => _ReceiptDialog(receipt: receipt),
                  );
                }
              } on DarajaException catch (error) {
                if (navigator.mounted) {
                  navigator.pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.message)),
                  );
                }
              } catch (_) {
                if (navigator.mounted) {
                  navigator.pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checkout failed. Please try again.')),
                  );
                }
              }
            },
            child: const Text('Checkout'),
          ),
          const SizedBox(height: 8.0),
          OutlinedButton(
            onPressed: () async {
              await ref.read(cartProvider.notifier).clear();
            },
            child: const Text('Clear Cart'),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDialog extends StatelessWidget {
  const _ReceiptDialog({required this.receipt});

  final DarajaReceipt receipt;

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final date = '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}:${local.second.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment Receipt'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReceiptRow(label: 'Amount', value: 'KES ${receipt.amount.toStringAsFixed(2)}'),
          _ReceiptRow(label: 'Phone', value: receipt.phoneNumber),
          _ReceiptRow(label: 'Merchant Request ID', value: receipt.merchantRequestId),
          _ReceiptRow(label: 'Checkout Request ID', value: receipt.checkoutRequestId),
          _ReceiptRow(label: 'Description', value: receipt.responseDescription),
          _ReceiptRow(label: 'Timestamp', value: _formatDateTime(receipt.timestamp)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
