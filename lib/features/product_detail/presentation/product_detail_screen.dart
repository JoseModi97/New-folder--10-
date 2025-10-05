
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/product.dart';
import '../../cart/data/cart_provider.dart';
import '../../../widgets/breadcrumbs.dart';
import '../../home/data/products_inventory_provider.dart';
import '../../home/data/products_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;
  final Product? product;
  const ProductDetailScreen({super.key, required this.productId, this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> with SingleTickerProviderStateMixin {
  int _count = 1;
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  bool _flipped = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsInventoryProvider);

    return productsAsync.when(
      data: (products) {
        final p = products.firstWhere((element) => element.id == widget.productId, orElse: () => widget.product!);

        if (p != null) {
          final available = p.inventory;
          final desiredCount = available > 0 ? _count.clamp(1, available) : 1;
          if (_count != desiredCount) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _count = desiredCount);
            });
          }
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: p != null && p.inventory > 0
                ? () async {
                    final added = await ref.read(cartProvider.notifier).add(p, _count);
                    if (!mounted) return;
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          added
                              ? 'Added $_count to cart: ${p.title}'
                              : 'Only ${p.inventory} left in stock',
                        ),
                      ),
                    );
                    if (added && mounted) {
                      setState(() => _count = 1);
                    }
                  }
                : null,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: Text(p != null && p.inventory > 0 ? 'Add to cart' : 'Out of stock'),
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Breadcrumbs(
                            items: [
                              BreadcrumbItem(title: 'Home', path: '/'),
                              if (p != null)
                                BreadcrumbItem(
                                  title: p.category,
                                  path: '/',
                                  onTap: () {
                                    ref.read(selectedCategoryProvider.notifier).state = p.category;
                                    context.go('/');
                                  },
                                ),
                              if (p != null) BreadcrumbItem(title: p.title, path: '/product/${p.id}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, anim) {
                          final rotate = Tween(begin: pi, end: 0.0).animate(anim);
                          return AnimatedBuilder(
                            animation: rotate,
                            child: child,
                            builder: (context, child) {
                              final isUnder = (ValueKey(_flipped) != child!.key);
                              final tilt = ((anim.value - 0.5).abs() - 0.5) * 0.003;
                              final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
                              return Transform(
                                transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                                alignment: Alignment.center,
                                child: child,
                              );
                            },
                          );
                        },
                        child: _flipped
                            ? _DetailBack(key: ValueKey(!_flipped), product: p)
                            : _DetailFront(
                                key: ValueKey(!_flipped),
                                product: p,
                                count: _count,
                                maxCount: p?.inventory ?? 0,
                                onCountChanged: (c) => setState(() => _count = c),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p != null ? '\$${p.price.toStringAsFixed(2)}' : '-',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            FilledButton.icon(
                              onPressed: () => setState(() => _flipped = !_flipped),
                              icon: const Icon(Icons.flip),
                              label: const Text('Flip'),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Failed to load product: $e'))),
    );
  }
}

class _DetailFront extends StatelessWidget {
  final Product? product;
  final int count;
  final int maxCount;
  final void Function(int) onCountChanged;
  const _DetailFront({super.key, this.product, required this.count, required this.maxCount, required this.onCountChanged});

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (p != null)
          Expanded(
            child: Hero(
              tag: 'product_${p.id}',
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Center(
                      child: Image.network(
                        p.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            p?.title ?? 'Product #',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        _ItemCounter(count: count, max: maxCount, onChanged: onCountChanged),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ItemCounter extends StatelessWidget {
  final int count;
  final int max;
  final void Function(int) onChanged;
  const _ItemCounter({super.key, required this.count, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final canDecrease = count > 1;
    final canIncrease = max > 0 && count < max;
    final displayCount = max > 0 ? count : 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: canDecrease ? () => onChanged(count - 1) : null,
        ),
        Text('$displayCount', style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: canIncrease ? () => onChanged(count + 1) : null,
        ),
      ],
    );
  }
}

class _DetailBack extends StatelessWidget {
  final Product? product;
  const _DetailBack({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    final p = product;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(p?.description ?? '-', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.category_rounded, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(p?.category ?? '-', overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
              const SizedBox(width: 6),
              Expanded(child: Text(p != null ? p.rating.rate.toStringAsFixed(1) : '-', overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(p != null ? '${p.inventory} in stock' : '-', overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
