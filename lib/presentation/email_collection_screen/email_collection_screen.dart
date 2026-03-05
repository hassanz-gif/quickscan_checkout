import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import './widgets/checkout_summary_widget.dart';
import './widgets/email_input_widget.dart';
import './widgets/order_confirmation_widget.dart';
import './widgets/payment_options_widget.dart';

class EmailCollectionScreen extends StatefulWidget {
  const EmailCollectionScreen({super.key});

  @override
  State<EmailCollectionScreen> createState() => _EmailCollectionScreenState();
}

class _EmailCollectionScreenState extends State<EmailCollectionScreen> {
  final _emailController = TextEditingController();
  bool _isEmailValid = false;
  bool _hasEmailError = false;
  String? _emailErrorMessage;
  bool _isProcessing = false;
  bool _showPayment = false;
  bool _orderConfirmed = false;

  final List<Map<String, dynamic>> _scannedItems = [
    {
      "id": 1,
      "name": "Organic Green Tea",
      "price": 8.99,
      "quantity": 2,
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1298e33ac-1772696549384.png",
      "semanticLabel":
          "Box of organic green tea with green packaging on white background",
    },
    {
      "id": 2,
      "name": "Whole Grain Bread",
      "price": 4.49,
      "quantity": 1,
      "image":
          "https://images.unsplash.com/photo-1618194696460-202623a57e02",
      "semanticLabel": "Sliced whole grain bread loaf on wooden cutting board",
    },
    {
      "id": 3,
      "name": "Fresh Orange Juice",
      "price": 5.99,
      "quantity": 1,
      "image":
          "https://images.unsplash.com/photo-1716834092549-7d8fd540b51a",
      "semanticLabel": "Glass of fresh orange juice with oranges in background",
    },
  ];

  double get _totalAmount => (_scannedItems).fold(
    0.0,
    (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
  );

  bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _onEmailChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _isEmailValid = false;
        _hasEmailError = false;
        _emailErrorMessage = null;
      } else if (_validateEmail(value)) {
        _isEmailValid = true;
        _hasEmailError = false;
        _emailErrorMessage = null;
      } else {
        _isEmailValid = false;
        _hasEmailError = true;
        _emailErrorMessage = 'Please enter a valid email address';
      }
    });
  }

  Future<void> _continueToPayment() async {
    if (!_isEmailValid) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isProcessing = false;
      _showPayment = true;
    });
  }

  void _onPaymentSuccess() {
    setState(() => _orderConfirmed = true);
  }

  void _startNewScan() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/camera-scanning-screen');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _orderConfirmed
          ? null
          : CustomAppBar(
              title: _showPayment ? 'Payment' : 'Checkout',
              showBackButton: true,
              variant: CustomAppBarVariant.solid,
            ),
      body: SafeArea(
        child: _orderConfirmed
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                child: OrderConfirmationWidget(
                  email: _emailController.text,
                  totalAmount: _totalAmount,
                  onStartNewScan: _startNewScan,
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckoutSummaryWidget(
                      scannedItems: _scannedItems,
                      totalAmount: _totalAmount,
                    ),
                    SizedBox(height: 3.h),
                    if (!_showPayment) ...[
                      EmailInputWidget(
                        controller: _emailController,
                        isValid: _isEmailValid,
                        hasError: _hasEmailError,
                        errorMessage: _emailErrorMessage,
                        onChanged: _onEmailChanged,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Your receipt will be sent to this email address.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isEmailValid && !_isProcessing
                              ? _continueToPayment
                              : null,
                          child: _isProcessing
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : const Text('Continue to Payment'),
                        ),
                      ),
                    ] else ...[
                      PaymentOptionsWidget(
                        totalAmount: _totalAmount,
                        onPaymentSuccess: _onPaymentSuccess,
                      ),
                    ],
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
      ),
    );
  }
}
