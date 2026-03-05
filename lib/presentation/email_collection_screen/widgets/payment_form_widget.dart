import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentFormWidget extends StatefulWidget {
  final double totalPrice;
  final bool isProcessing;
  final Future<void> Function(Map<String, dynamic>) onPaymentSubmit;

  const PaymentFormWidget({
    super.key,
    required this.totalPrice,
    required this.isProcessing,
    required this.onPaymentSubmit,
  });

  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

  void _submitPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onPaymentSubmit({
        'cardNumber': _cardNumberController.text,
        'expiry': _expiryController.text,
        'cvv': _cvvController.text,
        'name': _nameController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tax = widget.totalPrice * 0.08;
    final grandTotal = widget.totalPrice + tax;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: EdgeInsets.all(4.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'credit_card',
                  color: theme.colorScheme.tertiary,
                  size: 22,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Payment Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Card Number
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              maxLength: 19,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                counterText: '',
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final formatted = _formatCardNumber(value);
                if (formatted != value) {
                  _cardNumberController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.replaceAll(' ', '').length < 16) {
                  return 'Enter a valid 16-digit card number';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: const InputDecoration(
                      labelText: 'Expiry',
                      hintText: 'MM/YY',
                      counterText: '',
                    ),
                    onChanged: (value) {
                      if (value.length == 2 && !value.contains('/')) {
                        _expiryController.text = '$value/';
                        _expiryController.selection = TextSelection.collapsed(
                          offset: 3,
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.length < 5) {
                        return 'Invalid expiry';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.length < 3) {
                        return 'Invalid CVV';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'John Doe',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter cardholder name';
                }
                return null;
              },
            ),
            SizedBox(height: 3.h),

            // Security badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                SizedBox(width: 1.w),
                Text('SSL Secured', style: theme.textTheme.labelSmall),
                SizedBox(width: 3.w),
                CustomIconWidget(
                  iconName: 'verified_user',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                SizedBox(width: 1.w),
                Text('PCI Compliant', style: theme.textTheme.labelSmall),
              ],
            ),
            SizedBox(height: 2.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isProcessing ? null : _submitPayment,
                child: widget.isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          const Text('Processing...'),
                        ],
                      )
                    : Text('Pay \$${grandTotal.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
