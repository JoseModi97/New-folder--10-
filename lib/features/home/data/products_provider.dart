import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product.dart';
import '../../../services/providers.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final category = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  List<Product> products;
  if (category == null || category.isEmpty || category == 'all') {
    products = await api.getProducts();
  } else {
    products = await api.getByCategory(category);
  }

  if (searchQuery.isNotEmpty) {
    products = products.where((product) {
      final title = product.title.toLowerCase();
      final description = product.description.toLowerCase();
      final query = searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  return products;
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getCategories();
});