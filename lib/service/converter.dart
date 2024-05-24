import 'package:intl/intl.dart';

String priceConverter(int price) {
  String formattedNumber = NumberFormat('#,###').format(price);
  return formattedNumber;
}
