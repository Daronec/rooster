// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_color_scheme.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppColorSchemeTailorMixin on ThemeExtension<AppColorScheme> {
  Color get white;
  Color get black;
  Color get gray100;
  Color get gray200;
  Color get gray300;
  Color get gray400;
  Color get gray500;
  Color get gray600;
  Color get gray700;
  Color get gray900;
  Color get primaryLight;
  Color get primaryNormal;
  Color get green;
  Color get red;
  Color get warning;
  Color get grayLight;
  Color get gray;
  Color get grayDark;

  @override
  AppColorScheme copyWith({
    Color? white,
    Color? black,
    Color? gray100,
    Color? gray200,
    Color? gray300,
    Color? gray400,
    Color? gray500,
    Color? gray600,
    Color? gray700,
    Color? gray900,
    Color? primaryLight,
    Color? primaryNormal,
    Color? green,
    Color? red,
    Color? warning,
    Color? grayLight,
    Color? gray,
    Color? grayDark,
  }) {
    return AppColorScheme(
      white: white ?? this.white,
      black: black ?? this.black,
      gray100: gray100 ?? this.gray100,
      gray200: gray200 ?? this.gray200,
      gray300: gray300 ?? this.gray300,
      gray400: gray400 ?? this.gray400,
      gray500: gray500 ?? this.gray500,
      gray600: gray600 ?? this.gray600,
      gray700: gray700 ?? this.gray700,
      gray900: gray900 ?? this.gray900,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryNormal: primaryNormal ?? this.primaryNormal,
      green: green ?? this.green,
      red: red ?? this.red,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppColorScheme lerp(
    covariant ThemeExtension<AppColorScheme>? other,
    double t,
  ) {
    if (other is! AppColorScheme) return this as AppColorScheme;
    return AppColorScheme(
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      gray100: Color.lerp(gray100, other.gray100, t)!,
      gray200: Color.lerp(gray200, other.gray200, t)!,
      gray300: Color.lerp(gray300, other.gray300, t)!,
      gray400: Color.lerp(gray400, other.gray400, t)!,
      gray500: Color.lerp(gray500, other.gray500, t)!,
      gray600: Color.lerp(gray600, other.gray600, t)!,
      gray700: Color.lerp(gray700, other.gray700, t)!,
      gray900: Color.lerp(gray900, other.gray900, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryNormal: Color.lerp(primaryNormal, other.primaryNormal, t)!,
      green: Color.lerp(green, other.green, t)!,
      red: Color.lerp(red, other.red, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppColorScheme &&
            const DeepCollectionEquality().equals(white, other.white) &&
            const DeepCollectionEquality().equals(black, other.black) &&
            const DeepCollectionEquality().equals(gray100, other.gray100) &&
            const DeepCollectionEquality().equals(gray200, other.gray200) &&
            const DeepCollectionEquality().equals(gray300, other.gray300) &&
            const DeepCollectionEquality().equals(gray400, other.gray400) &&
            const DeepCollectionEquality().equals(gray500, other.gray500) &&
            const DeepCollectionEquality().equals(gray600, other.gray600) &&
            const DeepCollectionEquality().equals(gray700, other.gray700) &&
            const DeepCollectionEquality().equals(gray900, other.gray900) &&
            const DeepCollectionEquality().equals(
              primaryLight,
              other.primaryLight,
            ) &&
            const DeepCollectionEquality().equals(
              primaryNormal,
              other.primaryNormal,
            ) &&
            const DeepCollectionEquality().equals(green, other.green) &&
            const DeepCollectionEquality().equals(red, other.red) &&
            const DeepCollectionEquality().equals(warning, other.warning) &&
            const DeepCollectionEquality().equals(grayLight, other.grayLight) &&
            const DeepCollectionEquality().equals(gray, other.gray) &&
            const DeepCollectionEquality().equals(grayDark, other.grayDark));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(white),
      const DeepCollectionEquality().hash(black),
      const DeepCollectionEquality().hash(gray100),
      const DeepCollectionEquality().hash(gray200),
      const DeepCollectionEquality().hash(gray300),
      const DeepCollectionEquality().hash(gray400),
      const DeepCollectionEquality().hash(gray500),
      const DeepCollectionEquality().hash(gray600),
      const DeepCollectionEquality().hash(gray700),
      const DeepCollectionEquality().hash(gray900),
      const DeepCollectionEquality().hash(primaryLight),
      const DeepCollectionEquality().hash(primaryNormal),
      const DeepCollectionEquality().hash(green),
      const DeepCollectionEquality().hash(red),
      const DeepCollectionEquality().hash(warning),
      const DeepCollectionEquality().hash(grayLight),
      const DeepCollectionEquality().hash(gray),
      const DeepCollectionEquality().hash(grayDark),
    );
  }
}

extension AppColorSchemeBuildContext on BuildContext {
  AppColorScheme get appColorScheme =>
      Theme.of(this).extension<AppColorScheme>()!;
}
