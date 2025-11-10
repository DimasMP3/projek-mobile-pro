import '../config/constants.dart';

String toRupiah(num n) {
  final s = n.toStringAsFixed(0);
  final buff = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    buff.write(s[i]);
    if (rev > 1 && rev % 3 == 1) buff.write('.');
  }
  return '$kCurrencySymbol ${buff.toString()}';
}
