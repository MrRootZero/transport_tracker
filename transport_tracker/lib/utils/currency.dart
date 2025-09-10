import 'package:intl/intl.dart';

/// Formats a number into the South African Rand currency string.
String money(num v) =>
    NumberFormat.currency(locale: 'en_ZA', symbol: 'R').format(v);