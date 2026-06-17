import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';

/// {@template app_bottom_sheet}
/// Bottom sheet with custom design for entire app.
///
/// [handleBottomViewInset] is bottom view inset of [MediaQuery.viewInsetsOf] should be handled in this widget.
/// {@endtemplate}
Future<T?> showAppBottomSheet<T>(
  BuildContext context,
  Widget content, {
  bool isDismissible = true,
  bool enableDrag = true,
  bool handleBottomViewInset = true,
  bool showDecorations = true,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: (ctx) => AppBottomSheet(
      handleBottomViewInset: handleBottomViewInset,
      showDecorations: showDecorations,
      child: content,
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
  );
}

/// {@template app_bottom_sheet}
/// Bottom sheet with custom design for entire app.
/// {@endtemplate}
class AppBottomSheet extends StatelessWidget {
  /// {@macro app_bottom_sheet}
  const AppBottomSheet({
    required this.child,
    this.handleBottomViewInset = true,
    this.showDecorations = true,
    super.key,
  });

  /// Is bottom view inset of [MediaQuery.viewInsetsOf] should be handled in this widget.
  final bool handleBottomViewInset;

  /// The content of the bottom sheet.
  final Widget child;

  /// Show the decorations.
  final bool showDecorations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: handleBottomViewInset
          ? EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom)
          : null,
      decoration: BoxDecoration(
        color: context.appColorScheme.white,
        borderRadius: BorderRadius.only(
          topLeft: context.appSizesScheme.borderRadiusGeneral.topLeft,
          topRight: context.appSizesScheme.borderRadiusGeneral.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDecorations) ...[
            Height(context.appSizesScheme.paddingMedium),
            Container(
              decoration: BoxDecoration(
                color: context.appColorScheme.gray,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.double2),
                ),
              ),
              width: AppSizes.double40,
              height: AppSizes.double4,
            ),
            Height(context.appSizesScheme.paddingSmall),
          ] else ...[
            Height(context.appSizesScheme.paddingGeneral),
          ],
          SizedBox(width: double.infinity, child: child),
        ],
      ),
    );
  }
}
