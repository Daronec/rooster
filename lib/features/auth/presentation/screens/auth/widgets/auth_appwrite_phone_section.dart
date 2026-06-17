import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Телефон (E.164) и код из SMS для Appwrite Auth.
class AuthAppwritePhoneSection extends StatelessWidget {
  /// Создаёт блок формы.
  const AuthAppwritePhoneSection({
    required this.phoneFieldController,
    required this.otpFieldController,
    required this.onRequestCodePressed,
    required this.onConfirmCodePressed,
    super.key,
  });

  /// Номер телефона в формате E.164.
  final TextEditingController phoneFieldController;

  /// Код из SMS.
  final TextEditingController otpFieldController;

  /// Запросить SMS.
  final VoidCallback onRequestCodePressed;

  /// Подтвердить код и войти.
  final VoidCallback onConfirmCodePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextField(
          controller: phoneFieldController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: FlutterI18n.translate(
              context,
              'auth.phoneFieldLabel',
            ),
            hintText: FlutterI18n.translate(
              context,
              'auth.phoneFieldHint',
            ),
          ),
        ),
        const Height(AppSizes.double12),
        AppTextField(
          controller: otpFieldController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: FlutterI18n.translate(
              context,
              'auth.phoneOtpLabel',
            ),
          ),
        ),
        const Height(AppSizes.double16),
        FilledButton.tonal(
          onPressed: onRequestCodePressed,
          child: Text(
            FlutterI18n.translate(context, 'auth.phoneRequestCodeButton'),
          ),
        ),
        const Height(AppSizes.double8),
        FilledButton(
          onPressed: onConfirmCodePressed,
          child: Text(
            FlutterI18n.translate(context, 'auth.phoneConfirmCodeButton'),
          ),
        ),
      ],
    );
  }
}
