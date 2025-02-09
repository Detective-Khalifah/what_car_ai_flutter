import 'dart:math';

String formatPrice(double price) {
  return '\$${price.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(\.\d+)?$)'), (Match m) => '${m.group(1)},')}';
}
