import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _cartStorageKey = 'cart.items.v1';

class PersistedCartLine {
  final int productId;
  final int quantity;

  const PersistedCartLine({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };

  factory PersistedCartLine.fromJson(Map<String, dynamic> json) {
    final productId = json['productId'];
    final quantity = json['quantity'];
    if (productId is! num || quantity is! num) {
      throw const FormatException('Invalid persisted cart line');
    }
    return PersistedCartLine(
      productId: productId.toInt(),
      quantity: quantity.toInt(),
    );
  }
}

Future<List<PersistedCartLine>> readPersistedCart() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_cartStorageKey);
  if (raw == null || raw.isEmpty) {
    return const <PersistedCartLine>[];
  }
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return [
      for (final entry in decoded)
        if (entry is Map)
          PersistedCartLine.fromJson(Map<String, dynamic>.from(entry as Map)),
    ];
  } on FormatException {
    return const <PersistedCartLine>[];
  } on Object {
    return const <PersistedCartLine>[];
  }
}

Future<void> writePersistedCart(List<PersistedCartLine> lines) async {
  final prefs = await SharedPreferences.getInstance();
  if (lines.isEmpty) {
    await prefs.remove(_cartStorageKey);
    return;
  }
  final payload = jsonEncode([
    for (final line in lines) line.toJson(),
  ]);
  await prefs.setString(_cartStorageKey, payload);
}

Future<void> clearPersistedCart() => writePersistedCart(const <PersistedCartLine>[]);
