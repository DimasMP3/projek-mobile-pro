import 'package:flutter/material.dart';
import '../../utils/format_currency.dart';

class PaymentSummary extends StatelessWidget {
  final double subtotal;
  final double fee;
  const PaymentSummary({super.key, required this.subtotal, this.fee = 2500});

  @override
  Widget build(BuildContext context) {
    final total = subtotal + fee;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _row('Subtotal', toRupiah(subtotal)),
          const SizedBox(height: 6),
          _row('Convenience Fee', toRupiah(fee)),
          const Divider(height: 20),
          _row('Total', toRupiah(total), bold: true),
        ],
      ),
    );
  }

  Row _row(String l, String r, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        l,
        style: TextStyle(
          color: Colors.white70,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      Text(
        r,
        style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
      ),
    ],
  );
}
