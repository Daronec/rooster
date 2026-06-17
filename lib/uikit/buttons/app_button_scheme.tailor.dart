// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_button_scheme.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppButtonSchemeTailorMixin on ThemeExtension<AppButtonScheme> {
  ButtonStyle get primaryLarge;
  ButtonStyle get primaryMedium;
  ButtonStyle get primarySmall;
  ButtonStyle get blackLarge;
  ButtonStyle get blackMedium;
  ButtonStyle get blackSmall;
  ButtonStyle get grayLarge;
  ButtonStyle get grayMedium;
  ButtonStyle get graySmall;

  @override
  AppButtonScheme copyWith({
    ButtonStyle? primaryLarge,
    ButtonStyle? primaryMedium,
    ButtonStyle? primarySmall,
    ButtonStyle? blackLarge,
    ButtonStyle? blackMedium,
    ButtonStyle? blackSmall,
    ButtonStyle? grayLarge,
    ButtonStyle? grayMedium,
    ButtonStyle? graySmall,
  }) {
    return AppButtonScheme(
      primaryLarge: primaryLarge ?? this.primaryLarge,
      primaryMedium: primaryMedium ?? this.primaryMedium,
      primarySmall: primarySmall ?? this.primarySmall,
      blackLarge: blackLarge ?? this.blackLarge,
      blackMedium: blackMedium ?? this.blackMedium,
      blackSmall: blackSmall ?? this.blackSmall,
      grayLarge: grayLarge ?? this.grayLarge,
      grayMedium: grayMedium ?? this.grayMedium,
      graySmall: graySmall ?? this.graySmall,
    );
  }

  @override
  AppButtonScheme lerp(
    covariant ThemeExtension<AppButtonScheme>? other,
    double t,
  ) {
    if (other is! AppButtonScheme) return this as AppButtonScheme;
    return AppButtonScheme(
      primaryLarge: t < 0.5 ? primaryLarge : other.primaryLarge,
      primaryMedium: t < 0.5 ? primaryMedium : other.primaryMedium,
      primarySmall: t < 0.5 ? primarySmall : other.primarySmall,
      blackLarge: t < 0.5 ? blackLarge : other.blackLarge,
      blackMedium: t < 0.5 ? blackMedium : other.blackMedium,
      blackSmall: t < 0.5 ? blackSmall : other.blackSmall,
      grayLarge: t < 0.5 ? grayLarge : other.grayLarge,
      grayMedium: t < 0.5 ? grayMedium : other.grayMedium,
      graySmall: t < 0.5 ? graySmall : other.graySmall,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppButtonScheme &&
            const DeepCollectionEquality().equals(
              primaryLarge,
              other.primaryLarge,
            ) &&
            const DeepCollectionEquality().equals(
              primaryMedium,
              other.primaryMedium,
            ) &&
            const DeepCollectionEquality().equals(
              primarySmall,
              other.primarySmall,
            ) &&
            const DeepCollectionEquality().equals(
              blackLarge,
              other.blackLarge,
            ) &&
            const DeepCollectionEquality().equals(
              blackMedium,
              other.blackMedium,
            ) &&
            const DeepCollectionEquality().equals(
              blackSmall,
              other.blackSmall,
            ) &&
            const DeepCollectionEquality().equals(grayLarge, other.grayLarge) &&
            const DeepCollectionEquality().equals(
              grayMedium,
              other.grayMedium,
            ) &&
            const DeepCollectionEquality().equals(graySmall, other.graySmall));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(primaryLarge),
      const DeepCollectionEquality().hash(primaryMedium),
      const DeepCollectionEquality().hash(primarySmall),
      const DeepCollectionEquality().hash(blackLarge),
      const DeepCollectionEquality().hash(blackMedium),
      const DeepCollectionEquality().hash(blackSmall),
      const DeepCollectionEquality().hash(grayLarge),
      const DeepCollectionEquality().hash(grayMedium),
      const DeepCollectionEquality().hash(graySmall),
    );
  }
}

extension AppButtonSchemeBuildContext on BuildContext {
  AppButtonScheme get appButtonScheme =>
      Theme.of(this).extension<AppButtonScheme>()!;
}
