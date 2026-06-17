import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';
import 'package:rooster/util/async/safe_unawaited.dart';

/// {@template app_bottom_sheet}
/// Dialog with custom design for entire app.
/// {@endtemplate}
Future<T?> showAppDialog<T>(
  BuildContext context,
  Widget content, {
  EdgeInsets? padding,
  bool isDismissible = true,
  bool? isPopable,
  Size? dialogSize,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => PopScope(
      canPop: isPopable ?? isDismissible,
      child: Center(
        child: SizedBox.fromSize(
          size: dialogSize,
          child: AppDialog(padding: padding, child: content),
        ),
      ),
    ),
    barrierDismissible: isDismissible,
  );
}

/// {@template app_dialog}
/// Dialog with custom design for entire app.
/// {@endtemplate}
class AppDialog extends StatelessWidget {
  /// {@macro app_dialog}
  const AppDialog({
    required this.child,
    this.padding,
    this.isDismissible = true,
    super.key,
  });

  /// Whether the dialog is dismissible.
  final bool isDismissible;

  /// The content of the dialog.
  final Widget child;

  /// Optional padding.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: context.appSizesScheme.borderRadiusGeneral,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.appColorScheme.white,
          borderRadius: context.appSizesScheme.borderRadiusGeneral,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.appSizesScheme.dialogSizeMaxiumum,
            maxHeight: context.appSizesScheme.dialogSizeMaxiumum,
          ),
          child: Padding(
            padding:
                padding ?? EdgeInsets.all(context.appSizesScheme.paddingHuge),
            child: Stack(
              children: [
                child,
                if (isDismissible)
                  Positioned(
                    top: context.appSizesScheme.empty,
                    right: context.appSizesScheme.empty,
                    child: IconButton(
                      onPressed: () {
                        safeUnawaited(context.router.maybePop());
                      },
                      icon: Icon(
                        Icons.close,
                        size: context.appSizesScheme.iconSizeHuge,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
