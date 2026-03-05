import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentOptionsWidget extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onPaymentSuccess;

  const PaymentOptionsWidget({
    super.key,
    required this.totalAmount,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentOptionsWidget> createState() => _PaymentOptionsWidgetState();
}

class _PaymentOptionsWidgetState extends State<PaymentOptionsWidget> {
  bool _showCardForm = false;
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(value[i]);
    }
    return buffer.toString();
  }

  String _formatExpiry(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);
    widget.onPaymentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: _NativePayButton(
                label: 'Google Pay',
                iconName: 'payment',
                color: const Color(0xFF4285F4),
                onTap: _processPayment,
                isProcessing: _isProcessing,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _NativePayButton(
                label: 'Apple Pay',
                iconName: 'apple',
                color: Colors.black,
                onTap: _processPayment,
                isProcessing: _isProcessing,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            Expanded(child: Divider(color: theme.dividerColor)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Text(
                'or pay with card',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.dividerColor)),
          ],
        ),
        SizedBox(height: 1.5.h),
        GestureDetector(
          onTap: () => setState(() => _showCardForm = !_showCardForm),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'credit_card',
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Credit / Debit Card',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: _showCardForm
                      ? 'keyboard_arrow_up'
                      : 'keyboard_arrow_down',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (_showCardForm) ...[
          SizedBox(height: 1.5.h),
          _CardFormWidget(
            cardNumberController: _cardNumberController,
            expiryController: _expiryController,
            cvvController: _cvvController,
            nameController: _nameController,
            formatCardNumber: _formatCardNumber,
            formatExpiry: _formatExpiry,
            isProcessing: _isProcessing,
            onPay: _processPayment,
            totalAmount: widget.totalAmount,
          ),
        ],
        SizedBox(height: 2.h),
        _SecurityBadgesWidget(),
      ],
    );
  }
}

class _NativePayButton extends StatelessWidget {
  final String label;
  final String iconName;
  final Color color;
  final VoidCallback onTap;
  final bool isProcessing;

  const _NativePayButton({
    required this.label,
    required this.iconName,
    required this.color,
    required this.onTap,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(iconName: iconName, color: Colors.white, size: 18),
            SizedBox(width: 2.w),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFormWidget extends StatelessWidget {
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final TextEditingController nameController;
  final String Function(String) formatCardNumber;
  final String Function(String) formatExpiry;
  final bool isProcessing;
  final VoidCallback onPay;
  final double totalAmount;

  const _CardFormWidget({
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.nameController,
    required this.formatCardNumber,
    required this.formatExpiry,
    required this.isProcessing,
    required this.onPay,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomIconWidget(
                iconName: 'person_outline',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        TextFormField(
          controller: cardNumberController,
          keyboardType: TextInputType.number,
          maxLength: 19,
          onChanged: (v) {
            final formatted = formatCardNumber(v.replaceAll(' ', ''));
            if (formatted != v) {
              cardNumberController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
          decoration: InputDecoration(
            labelText: 'Card Number',
            counterText: '',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomIconWidget(
                iconName: 'credit_card',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: expiryController,
                keyboardType: TextInputType.number,
                maxLength: 5,
                onChanged: (v) {
                  final formatted = formatExpiry(v.replaceAll('/', ''));
                  if (formatted != v) {
                    expiryController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  labelText: 'MM/YY',
                  counterText: '',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomIconWidget(
                      iconName: 'calendar_today',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: TextFormField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  counterText: '',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomIconWidget(
                      iconName: 'lock_outline',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isProcessing ? null : onPay,
            child: isProcessing
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text('Pay \$${totalAmount.toStringAsFixed(2)}'),
          ),
        ),
      ],
    );
  }
}

class _SecurityBadgesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(iconName: 'lock', color: Colors.green, size: 16),
          SizedBox(width: 2.w),
          Text(
            'SSL Secured',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          CustomIconWidget(
            iconName: 'verified_user',
            color: Colors.green,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'PCI Compliant',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
