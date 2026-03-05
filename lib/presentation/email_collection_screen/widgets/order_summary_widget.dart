import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class OrderSummaryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> scannedItems;
  final double totalPrice;

  const OrderSummaryWidget({
    super.key,
    required this.scannedItems,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tax = totalPrice * 0.08;
    final grandTotal = totalPrice + tax;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Text(
              'Order Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: scannedItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = scannedItems[index];
              final name = item["name"] as String? ?? 'Unknown';
              final price = item["price"] as double? ?? 0.0;
              final qty = item["quantity"] as int? ?? 1;
              final imageUrl = item["image"] as String? ?? '';
              final semanticLabel = item["semanticLabel"] as String? ?? name;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImageWidget(
                        imageUrl: imageUrl,
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                        semanticLabel: semanticLabel,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Qty: $qty', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(price * qty).toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              children: [
                _summaryRow(
                  theme,
                  'Subtotal',
                  '\$${totalPrice.toStringAsFixed(2)}',
                ),
                SizedBox(height: 0.8.h),
                _summaryRow(theme, 'Tax (8%)', '\$${tax.toStringAsFixed(2)}'),
                SizedBox(height: 1.h),
                const Divider(height: 1),
                SizedBox(height: 1.h),
                _summaryRow(
                  theme,
                  'Total',
                  '\$${grandTotal.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    ThemeData theme,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isBold
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.tertiary,
                )
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
