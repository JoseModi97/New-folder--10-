
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/new_theme.dart';
import 'features/cart/presentation/cart_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/product_detail/presentation/product_detail_screen.dart';
import 'models/product.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env/.env');
  runApp(const ProviderScope(child: App()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final product = state.extra as Product?;
        return ProductDetailScreen(productId: id, product: product);
      },
    ),
  ],
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'POS System',
      theme: newTheme,
    );
  }
}
