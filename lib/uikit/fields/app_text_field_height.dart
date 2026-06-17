import 'package:flutter/material.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart' show AppTextField;
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';

/// Вариант вертикального размера однострочного [AppTextField].
///
/// При ширине экрана больше [AppSizesScheme.mobileWidth] (десктопный макет)
/// высота поля: [AppSizes.double48] ([compact]) или [AppSizes.double56] ([standard]);
/// скругление рамки — [AppSizes.borderRadius32]. На мобильном макете высота —
/// [AppSizes.double40] ([compact]) или [AppSizes.double48] ([standard]);
/// скругление — [AppSizes.borderRadius12] у [compact] и [AppSizes.borderRadius16]
/// у [standard].
enum AppTextFieldHeight {
  /// Компактная высота на мобильном макете ([AppSizes.double40]);
  /// скругление 12 px на мобильном и 32 px на десктопном макете.
  compact,

  /// Стандартная высота на мобильном макете ([AppSizes.double48]);
  /// скругление 16 px на мобильном и 32 px на десктопном макете.
  standard,
}

bool _appTextFieldIsDesktopLayout(BuildContext context) {
  final screenSize = MediaQuery.sizeOf(context);
  final scheme = Theme.of(context).extension<AppSizesScheme>();
  return screenSize.width > (scheme?.mobileWidth ?? AppSizes.kMobileWidth);
}

/// Разрешение целевой высоты и скругления поля с учётом ширины макета.
extension AppTextFieldHeightResolve on AppTextFieldHeight {
  /// Возвращает высоту однострочного поля в логических пикселях с учётом
  /// десктопного порога ширины ([AppSizesScheme.mobileWidth] / [AppSizes.kMobileWidth]).
  double resolveForLayout(BuildContext context) {
    if (_appTextFieldIsDesktopLayout(context)) {
      return switch (this) {
        AppTextFieldHeight.compact => AppSizes.double48,
        AppTextFieldHeight.standard => AppSizes.double56,
      };
    }
    return switch (this) {
      AppTextFieldHeight.compact => AppSizes.double40,
      AppTextFieldHeight.standard => AppSizes.double48,
    };
  }

  /// Скругление [OutlineInputBorder] для поля: на десктопном макете всегда
  /// [AppSizes.borderRadius32]; на мобильном — 12 px для [compact] и 16 px для [standard].
  BorderRadius borderRadiusForLayout(BuildContext context) {
    if (_appTextFieldIsDesktopLayout(context)) {
      return AppSizes.borderRadius32;
    }
    return switch (this) {
      AppTextFieldHeight.compact => AppSizes.borderRadius12,
      AppTextFieldHeight.standard => AppSizes.borderRadius16,
    };
  }
}
