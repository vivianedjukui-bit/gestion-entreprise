import 'package:flutter/material.dart';
import '../theme.dart';

class LedgerRow extends StatelessWidget {
  final String? date;
  final String label;
  final int amount;
  final bool? positive; // true = vente (vert), false = dépense (rouge), null = neutre

  const LedgerRow({
    super.key,
    this.date,
    required this.label,
    required this.amount,
    this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive == null
        ? AppColors.ink
        : (positive! ? AppColors.green : AppColors.red);
    final prefix = positive == null ? '' : (positive! ? '+' : '-');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (date != null) ...[
            Text(date!, style: AppText.amount(size: 11, color: AppColors.muted, weight: FontWeight.w400)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(label, style: AppText.body(), overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              height: 1,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.dottedLine, width: 1)),
              ),
            ),
          ),
          Text('$prefix${formatFcfa(amount)}', style: AppText.amount(color: color)),
        ],
      ),
    );
  }
}
