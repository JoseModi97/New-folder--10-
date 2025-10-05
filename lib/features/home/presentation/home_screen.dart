import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cart/data/cart_provider.dart';
import '../../cart/presentation/cart_screen.dart';
import '../data/products_inventory_provider.dart';
import '../data/products_provider.dart';
import '../../../widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openCartDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _closeCartDrawer() {
    _scaffoldKey.currentState?.closeEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsInventoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('POS System'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(cartCountProvider);
              return Stack(
                children: [
                  IconButton(
                    tooltip: 'Cart',
                    onPressed: _openCartDrawer,
                    icon: const Icon(Icons.shopping_cart),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Drawer(
        width: 420,
        child: SafeArea(
          child: CartContents(
            showBreadcrumbs: false,
            onClose: _closeCartDrawer,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products by name or description...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          categoriesAsync.when(
            data: (cats) => _CategoryFilters(categories: cats, selected: selected),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Failed to load categories: $e'),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) => GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => context.go('/product/${product.id}', extra: product),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load products: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilters extends ConsumerWidget {
  final List<String> categories;
  final String? selected;

  const _CategoryFilters({required this.categories, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCategories = ['all', ...categories];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = selected == category || (selected == null && category == 'all');
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (value) {
                if (value) {
                  ref.read(selectedCategoryProvider.notifier).state = category == 'all' ? null : category;
                }
              },
            ),
          );
        },
      ),
    );
  }
}