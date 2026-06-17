import 'package:flutter/material.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type_style.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

const _snackId = 'snack';

/// Default controller for displaying messages.
class DefaultSnackController {
  /// Create an instance [DefaultSnackController].
  const DefaultSnackController();

  /// Show the message.
  Future<void> showSnack({
    required SnackMessageType messageType,
    required String message,
    required BuildContext context,
    required EasyDialogDecoration dialogDecoration,
    required EasyDialogAnimationConfiguration animationConfiguration,
    Duration? autoHideDuration,
  }) {
    final isDesktop = context.isDesktop;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottomInset = viewPadding.bottom;

    return FlutterEasyDialogs.show(
      EasyDialog.positioned(
        position: EasyDialogPosition.bottom,
        content: isDesktop
            ? _DesktopSnack(
                message: message,
                messageType: messageType,
                bottomInset: bottomInset,
              )
            : _MobileSnack(
                message: message,
                messageType: messageType,
                bottomInset: bottomInset,
              ),
        id: _snackId,
        animationConfiguration: animationConfiguration,
        decoration: dialogDecoration,
        autoHideDuration: autoHideDuration,
      ).swipe(direction: DismissDirection.down, willDismiss: () => true),
    );
  }

  /// Hide Snack.
  Future<void> hideSnack() {
    return FlutterEasyDialogs.hide(id: _snackId, instantly: true);
  }
}

class _MobileSnack extends StatelessWidget {
  const _MobileSnack({
    required this.message,
    required this.messageType,
    required this.bottomInset,
  });

  final String message;
  final SnackMessageType messageType;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.appColorScheme;
    final textScheme = context.appTextScheme;
    final generalPaddingDimension16 = context.appSizesScheme.paddingGeneral;
    final paddingMedium = context.appSizesScheme.paddingMedium;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        width: double.infinity,
        child: ColoredBox(
          color: messageType.snackBackgroundColor(
            colorScheme,
            isDesktopLayout: false,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              generalPaddingDimension16,
              paddingMedium,
              generalPaddingDimension16,
              generalPaddingDimension16,
            ),
            child: Text(
              message,
              style: textScheme.t14.copyWith(
                color: messageType.snackForegroundColor(colorScheme),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopSnack extends StatelessWidget {
  const _DesktopSnack({
    required this.message,
    required this.messageType,
    required this.bottomInset,
  });

  final String message;
  final SnackMessageType messageType;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.appColorScheme;
    final textScheme = context.appTextScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + 38),
      child: SizedBox(
        width: 375,
        child: ColoredBox(
          color: messageType.snackBackgroundColor(
            colorScheme,
            isDesktopLayout: true,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.appSizesScheme.paddingGeneral,
              horizontal: context.appSizesScheme.paddingStandard,
            ),
            child: Text(
              message,
              style: textScheme.t14.copyWith(
                color: messageType.snackForegroundColor(colorScheme),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
