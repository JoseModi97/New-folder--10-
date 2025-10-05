import 'dart:io';

Future<void> saveInventoryData(String data) async {
  final file = File('Sale/api_products.json');
  await file.writeAsString('$data\n');
}
