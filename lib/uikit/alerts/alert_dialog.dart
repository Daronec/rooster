import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/uikit/alerts/app_alert.dart';
import 'package:rooster/uikit/alerts/app_alert_action.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/dialogs/app_dialog.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Callback with context.
typedef ContextCallback = void Function(BuildContext context);

/// Show recurrence dialog.
Future<T?> showAppAlertDialog<T>({
  required BuildContext context,
  required String title,
  required String submitLabel,
  String? cancelLabel,
  String? subtitle,
  String? iconPath,
  ContextCallback? onCancel,
  ContextCallback? onSubmit,
  bool useRootNavigator = true,
}) {
  if (context.isDesktop) {
    return showAppDialog<T>(
      context,
      AlertDialog(
        title: title,
        submit: submitLabel,
        cancel: cancelLabel,
        subtitle: subtitle,
        iconPath: iconPath,
        onCancel: onCancel,
        onSubmit: onSubmit,
      ),
      dialogSize: Size(
        context.appSizesScheme.dialogSizeMinimum,
        AppSizes.double440,
      ),
    );
  }

  return showDialog<T>(
    context: context,
    builder: (ctx) {
      return AppAlert(
        actions: [
          AppAlertAction(
            onPressed: () => onSubmit?.call(ctx),
            isDefaultAction: true,
            child: Text(submitLabel),
          ),
          if (cancelLabel case final String label)
            AppAlertAction(
              onPressed: () => onCancel?.call(ctx),
              child: Text(label),
            ),
        ],
        title: Text(title),
        content: subtitle == null || subtitle.isEmpty ? null : Text(subtitle),
      );
    },
    useRootNavigator: useRootNavigator,
  );
}

/// {@template alert_dialog.class}
/// [AlertDialog].
/// {@endtemplate}
class AlertDialog extends StatelessWidget {
  /// {@macro alert_dialog.class}
  const AlertDialog({
    required this.title,
    required this.submit,
    this.cancel,
    this.subtitle,
    this.iconPath,
    this.onCancel,
    this.onSubmit,
    super.key,
  });

  /// Title of recurrence dialog.
  final String title;

  /// Cancel button label.
  final String? cancel;

  /// Submit button label.
  final String submit;

  /// Subtitle of dialog.
  final String? subtitle;

  /// Icon path of alert dialog.
  final String? iconPath;

  /// Cancel button callback.
  ///
  /// Should pop alert with any result.
  final ContextCallback? onCancel;

  /// Submit button callback.
  ///
  /// Should pop alert with any result.
  final ContextCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Width(double.infinity),
        Text(
          title,
          style: context.appTextScheme.t16Medium.copyWith(
            color: context.appColorScheme.black,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle case final String sub when sub.isNotEmpty) ...[
          Height(context.appSizesScheme.paddingGeneral),
          Text(
            sub,
            style: context.appTextScheme.t14.copyWith(
              color: context.appColorScheme.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        Height(context.appSizesScheme.paddingGeneral),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: AppPrimaryButton(
            onPressed: () => onSubmit?.call(context),
            child: Text(submit),
          ),
        ),
        if (cancel case final String label) ...[
          Height(context.appSizesScheme.paddingGeneral),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              onPressed: () => onCancel?.call(context),
              child: Text(label),
            ),
          ),
        ],
      ],
    );
  }
}
