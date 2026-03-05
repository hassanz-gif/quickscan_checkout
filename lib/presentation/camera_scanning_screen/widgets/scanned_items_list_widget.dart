import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScannedItemsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<int> onRemove;

  const ScannedItemsListWidget({
    super.key,
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return items.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'camera_alt',
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  size: 36,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Tap the camera button to scan items',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: theme.dividerColor),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 0.5.h,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImageWidget(
                    imageUrl: item['image'] as String? ?? '',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    semanticLabel:
                        item['semanticLabel'] as String? ?? 'Product image',
                  ),
                ),
                title: Text(
                  item['name'] as String? ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Text(
                  'Qty: ${item['quantity']} × \$${(item['price'] as double).toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${((item['price'] as double) * (item['quantity'] as int)).toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: () => onRemove(item['id'] as int),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: theme.colorScheme.error,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
