import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class OrderConfirmationWidget extends StatefulWidget {
  final String email;
  final double totalAmount;
  final VoidCallback onStartNewScan;

  const OrderConfirmationWidget({
    super.key,
    required this.email,
    required this.totalAmount,
    required this.onStartNewScan,
  });

  @override
  State<OrderConfirmationWidget> createState() =>
      _OrderConfirmationWidgetState();
}

class _OrderConfirmationWidgetState extends State<OrderConfirmationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.green,
                size: 48,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Order Confirmed!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'email',
                  color: theme.colorScheme.tertiary,
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    'Receipt sent to ${widget.email}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 70.w,
            child: ElevatedButton.icon(
              onPressed: widget.onStartNewScan,
              icon: CustomIconWidget(
                iconName: 'camera_alt',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Start New Scan'),
            ),
          ),
        ],
      ),
    );
  }
}
