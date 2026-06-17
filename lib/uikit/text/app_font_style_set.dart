// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Набор текстовых стилей одного шрифта для всех размеров и начертаний.
///
/// Позволяет использовать один и тот же набор размеров (10, 12, 14, 16, 20, 24, 32, 56)
/// и начертаний (regular, medium, bold) для обоих шрифтов приложения.
@immutable
class AppFontStyleSet {
  const AppFontStyleSet({
    required this.t10,
    required this.t10Medium,
    required this.t12,
    required this.t12Medium,
    required this.t12Bold,
    required this.t14,
    required this.t14Medium,
    required this.t16,
    required this.t16Medium,
    required this.t16Bold,
    required this.t20,
    required this.t20Medium,
    required this.t20Bold,
    required this.t24,
    required this.t24Medium,
    required this.t24Bold,
    required this.t32,
    required this.t32Medium,
    required this.t32Bold,
    required this.t56,
    required this.t56Medium,
    required this.t56Bold,
  });

  final TextStyle t10;
  final TextStyle t10Medium;
  final TextStyle t12;
  final TextStyle t12Medium;
  final TextStyle t12Bold;
  final TextStyle t14;
  final TextStyle t14Medium;
  final TextStyle t16;
  final TextStyle t16Medium;
  final TextStyle t16Bold;
  final TextStyle t20;
  final TextStyle t20Medium;
  final TextStyle t20Bold;
  final TextStyle t24;
  final TextStyle t24Medium;
  final TextStyle t24Bold;
  final TextStyle t32;
  final TextStyle t32Medium;
  final TextStyle t32Bold;
  final TextStyle t56;
  final TextStyle t56Medium;
  final TextStyle t56Bold;

  AppFontStyleSet copyWith({
    TextStyle? t10,
    TextStyle? t10Medium,
    TextStyle? t12,
    TextStyle? t12Medium,
    TextStyle? t12Bold,
    TextStyle? t14,
    TextStyle? t14Medium,
    TextStyle? t16,
    TextStyle? t16Medium,
    TextStyle? t16Bold,
    TextStyle? t20,
    TextStyle? t20Medium,
    TextStyle? t20Bold,
    TextStyle? t24,
    TextStyle? t24Medium,
    TextStyle? t24Bold,
    TextStyle? t32,
    TextStyle? t32Medium,
    TextStyle? t32Bold,
    TextStyle? t56,
    TextStyle? t56Medium,
    TextStyle? t56Bold,
  }) {
    return AppFontStyleSet(
      t10: t10 ?? this.t10,
      t10Medium: t10Medium ?? this.t10Medium,
      t12: t12 ?? this.t12,
      t12Medium: t12Medium ?? this.t12Medium,
      t12Bold: t12Bold ?? this.t12Bold,
      t14: t14 ?? this.t14,
      t14Medium: t14Medium ?? this.t14Medium,
      t16: t16 ?? this.t16,
      t16Medium: t16Medium ?? this.t16Medium,
      t16Bold: t16Bold ?? this.t16Bold,
      t20: t20 ?? this.t20,
      t20Medium: t20Medium ?? this.t20Medium,
      t20Bold: t20Bold ?? this.t20Bold,
      t24: t24 ?? this.t24,
      t24Medium: t24Medium ?? this.t24Medium,
      t24Bold: t24Bold ?? this.t24Bold,
      t32: t32 ?? this.t32,
      t32Medium: t32Medium ?? this.t32Medium,
      t32Bold: t32Bold ?? this.t32Bold,
      t56: t56 ?? this.t56,
      t56Medium: t56Medium ?? this.t56Medium,
      t56Bold: t56Bold ?? this.t56Bold,
    );
  }

  static AppFontStyleSet lerp(
    AppFontStyleSet? a,
    AppFontStyleSet? b,
    double t,
  ) {
    if (a == null && b == null) {
      throw ArgumentError('At least one of a or b must be non-null');
    }
    if (a == null) return b!;
    if (b == null) return a;
    return AppFontStyleSet(
      t10: TextStyle.lerp(a.t10, b.t10, t)!,
      t10Medium: TextStyle.lerp(a.t10Medium, b.t10Medium, t)!,
      t12: TextStyle.lerp(a.t12, b.t12, t)!,
      t12Medium: TextStyle.lerp(a.t12Medium, b.t12Medium, t)!,
      t12Bold: TextStyle.lerp(a.t12Bold, b.t12Bold, t)!,
      t14: TextStyle.lerp(a.t14, b.t14, t)!,
      t14Medium: TextStyle.lerp(a.t14Medium, b.t14Medium, t)!,
      t16: TextStyle.lerp(a.t16, b.t16, t)!,
      t16Medium: TextStyle.lerp(a.t16Medium, b.t16Medium, t)!,
      t16Bold: TextStyle.lerp(a.t16Bold, b.t16Bold, t)!,
      t20: TextStyle.lerp(a.t20, b.t20, t)!,
      t20Medium: TextStyle.lerp(a.t20Medium, b.t20Medium, t)!,
      t20Bold: TextStyle.lerp(a.t20Bold, b.t20Bold, t)!,
      t24: TextStyle.lerp(a.t24, b.t24, t)!,
      t24Medium: TextStyle.lerp(a.t24Medium, b.t24Medium, t)!,
      t24Bold: TextStyle.lerp(a.t24Bold, b.t24Bold, t)!,
      t32: TextStyle.lerp(a.t32, b.t32, t)!,
      t32Medium: TextStyle.lerp(a.t32Medium, b.t32Medium, t)!,
      t32Bold: TextStyle.lerp(a.t32Bold, b.t32Bold, t)!,
      t56: TextStyle.lerp(a.t56, b.t56, t)!,
      t56Medium: TextStyle.lerp(a.t56Medium, b.t56Medium, t)!,
      t56Bold: TextStyle.lerp(a.t56Bold, b.t56Bold, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppFontStyleSet &&
          t10 == other.t10 &&
          t10Medium == other.t10Medium &&
          t12 == other.t12 &&
          t12Medium == other.t12Medium &&
          t12Bold == other.t12Bold &&
          t14 == other.t14 &&
          t14Medium == other.t14Medium &&
          t16 == other.t16 &&
          t16Medium == other.t16Medium &&
          t16Bold == other.t16Bold &&
          t20 == other.t20 &&
          t20Medium == other.t20Medium &&
          t20Bold == other.t20Bold &&
          t24 == other.t24 &&
          t24Medium == other.t24Medium &&
          t24Bold == other.t24Bold &&
          t32 == other.t32 &&
          t32Medium == other.t32Medium &&
          t32Bold == other.t32Bold &&
          t56 == other.t56 &&
          t56Medium == other.t56Medium &&
          t56Bold == other.t56Bold);

  @override
  int get hashCode => Object.hashAll([
    t10,
    t10Medium,
    t12,
    t12Medium,
    t12Bold,
    t14,
    t14Medium,
    t16,
    t16Medium,
    t16Bold,
    t20,
    t20Medium,
    t20Bold,
    t24,
    t24Medium,
    t24Bold,
    t32,
    t32Medium,
    t32Bold,
    t56,
    t56Medium,
    t56Bold,
  ]);
}
