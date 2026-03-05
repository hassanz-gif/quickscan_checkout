import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmailInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final bool hasError;
  final String? errorMessage;
  final ValueChanged<String> onChanged;

  const EmailInputWidget({
    super.key,
    required this.controller,
    required this.isValid,
    required this.hasError,
    this.errorMessage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Username or full @carleton.edu email',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomIconWidget(
                iconName: 'email_outlined',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: isValid
                        ? CustomIconWidget(
                            iconName: 'check_circle',
                            color: Colors.green,
                            size: 20,
                          )
                        : CustomIconWidget(
                            iconName: 'error_outline',
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? theme.colorScheme.error
                    : isValid
                    ? Colors.green
                    : theme.colorScheme.outline,
                width: hasError || isValid ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? theme.colorScheme.error
                    : isValid
                    ? Colors.green
                    : theme.colorScheme.tertiary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError && errorMessage != null) ...[
          SizedBox(height: 0.5.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: theme.colorScheme.error,
                size: 14,
              ),
              SizedBox(width: 1.w),
              Text(
                errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
