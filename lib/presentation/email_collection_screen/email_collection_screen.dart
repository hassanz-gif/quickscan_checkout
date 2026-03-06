import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_icon_widget.dart';
import './widgets/email_input_widget.dart';
import './widgets/order_confirmation_widget.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;class EmailCollectionScreen extends StatefulWidget {
  const EmailCollectionScreen({super.key});

  @override
  State<EmailCollectionScreen> createState() => _EmailCollectionScreenState();
}

class _EmailCollectionScreenState extends State<EmailCollectionScreen> {
  final _emailController = TextEditingController();
  bool _isEmailValid = false;
  bool _hasEmailError = false;
  String? _emailErrorMessage;
  bool _isSubmitting = false;
  bool _checkoutComplete = false;
  String? _photoPath;
  String? _photoBase64;
  String _resolvedEmail = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _photoPath = args?['photoPath'] as String?;
    _photoBase64 = args?['photoBase64'] as String?;  }

  /// Accepts "username" or "username@carleton.edu"
  bool _validateInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    // Full email — must end in @carleton.edu
    if (trimmed.contains('@')) {
      return RegExp(r'^[a-zA-Z0-9._%+-]+@carleton\.edu$').hasMatch(trimmed);
    }
    // Username only — must be valid characters
    return RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(trimmed);
  }

  void _onEmailChanged(String value) {
    setState(() {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        _isEmailValid = false;
        _hasEmailError = false;
        _emailErrorMessage = null;
      } else if (_validateInput(trimmed)) {
        _isEmailValid = true;
        _hasEmailError = false;
        _emailErrorMessage = null;
      } else if (trimmed.contains('@') &&
          !trimmed.endsWith('@carleton.edu')) {
        _isEmailValid = false;
        _hasEmailError = true;
        _emailErrorMessage = 'Must be a @carleton.edu address';
      } else {
        _isEmailValid = false;
        _hasEmailError = true;
        _emailErrorMessage = 'Enter your username or full @carleton.edu email';
      }
    });
  }

  Future<void> _submitCheckout() async {
    if (!_isEmailValid) return;
    setState(() => _isSubmitting = true);

    final input = _emailController.text.trim();
    _resolvedEmail =
        input.contains('@') ? input : '$input@carleton.edu';

    // Simulate a brief processing moment
    // Send via proxy server
    try {
      await http.post(
        Uri.parse('http://localhost:3000/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _resolvedEmail,
          'timestamp': DateTime.now().toIso8601String(),
          'image': _photoBase64 ?? '',
        }),
      );
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _checkoutComplete = true;
      });
    }
  }

  void _returnToCamera() {
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed('/camera-scanning-screen');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_checkoutComplete) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: OrderConfirmationWidget(
            email: _resolvedEmail,
            onStartNewScan: _returnToCamera,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo preview
              if (_photoPath != null && !kIsWeb) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 28.h,
                    child: Image.file(
                      File(_photoPath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 2.5.h),
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'photo_camera',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 48,
                    ),
                  ),
                ),
                SizedBox(height: 2.5.h),
              ],

              Text(
                'Who\'s checking out?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Enter your Carleton username or full email address.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 3.h),

              EmailInputWidget(
                controller: _emailController,
                isValid: _isEmailValid,
                hasError: _hasEmailError,
                errorMessage: _emailErrorMessage,
                onChanged: _onEmailChanged,
              ),

              SizedBox(height: 0.8.h),
              Padding(
                padding: EdgeInsets.only(left: 1.w),
                child: Text(
                  'e.g.  "hassanz"  or  "hassanz@carleton.edu"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              SizedBox(height: 3.h),
              Text(
                '* All items must be returned in 3 days unless an exemption was given by a makerspace staff member.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              ),

              SizedBox(height: 4.h),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _isEmailValid && !_isSubmitting ? _submitCheckout : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          'Complete Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
