import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Registration Form Widget
///
/// Contains all input fields for user registration with inline validation
class RegistrationFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode fullNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode phoneFocusNode;
  final FocusNode passwordFocusNode;
  final bool isPasswordVisible;
  final bool isFullNameValid;
  final bool isEmailValid;
  final bool isPhoneValid;
  final bool isPasswordValid;
  final String? fullNameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final VoidCallback onPasswordVisibilityToggle;

  const RegistrationFormWidget({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.fullNameFocusNode,
    required this.emailFocusNode,
    required this.phoneFocusNode,
    required this.passwordFocusNode,
    required this.isPasswordVisible,
    required this.isFullNameValid,
    required this.isEmailValid,
    required this.isPhoneValid,
    required this.isPasswordValid,
    this.fullNameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    required this.onPasswordVisibilityToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name Field
          _buildInputField(
            context: context,
            controller: fullNameController,
            focusNode: fullNameFocusNode,
            nextFocusNode: emailFocusNode,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: 'person_outline',
            isValid: isFullNameValid,
            errorText: fullNameError,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            ],
          ),

          SizedBox(height: 2.h),

          // Email Field
          _buildInputField(
            context: context,
            controller: emailController,
            focusNode: emailFocusNode,
            nextFocusNode: phoneFocusNode,
            label: 'Email Address',
            hint: 'Enter your email',
            prefixIcon: 'email_outlined',
            isValid: isEmailValid,
            errorText: emailError,
            keyboardType: TextInputType.emailAddress,
          ),

          SizedBox(height: 2.h),

          // Phone Field
          _buildInputField(
            context: context,
            controller: phoneController,
            focusNode: phoneFocusNode,
            nextFocusNode: passwordFocusNode,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            prefixIcon: 'phone_outlined',
            isValid: isPhoneValid,
            errorText: phoneError,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\+]')),
            ],
          ),

          SizedBox(height: 2.h),

          // Password Field
          _buildPasswordField(
            context: context,
            controller: passwordController,
            focusNode: passwordFocusNode,
            label: 'Password',
            hint: 'Create a strong password',
            isValid: isPasswordValid,
            errorText: passwordError,
            isPasswordVisible: isPasswordVisible,
            onVisibilityToggle: onPasswordVisibilityToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String label,
    required String hint,
    required String prefixIcon,
    required bool isValid,
    String? errorText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: prefixIcon,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: isValid ? 'check_circle' : 'cancel',
                      color: isValid
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      size: 20,
                    ),
                  )
                : null,
          ),
          onSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
        ),
        if (errorText != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            errorText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required bool isValid,
    String? errorText,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock_outline',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: CustomIconWidget(
                      iconName: isValid ? 'check_circle' : 'cancel',
                      color: isValid
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      size: 20,
                    ),
                  ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName:
                        isPasswordVisible ? 'visibility_off' : 'visibility',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: onVisibilityToggle,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            errorText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
