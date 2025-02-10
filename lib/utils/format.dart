import 'package:intl/intl.dart';

String formatPrice(double price) {
  final format = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  return format.format(price);
}
