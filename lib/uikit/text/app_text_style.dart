//ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_light_palette.dart'
    show appPaletteGray900;

/// App text style.
enum AppTextStyle {
  t10(
    TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 12 / 10,
      color: appPaletteGray900,
    ),
  ),
  t10Medium(
    TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 12 / 10,
      color: appPaletteGray900,
    ),
  ),
  t12(
    TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 16 / 12,
      color: appPaletteGray900,
    ),
  ),
  t12Medium(
    TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      color: appPaletteGray900,
    ),
  ),
  t12Bold(
    TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 16 / 12,
      color: appPaletteGray900,
    ),
  ),
  t14(
    TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: appPaletteGray900,
    ),
  ),
  t14Medium(
    TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: appPaletteGray900,
    ),
  ),
  t16(
    TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      color: appPaletteGray900,
    ),
  ),
  t16Medium(
    TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 24 / 16,
      color: appPaletteGray900,
    ),
  ),
  t16Bold(
    TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 24 / 16,
      color: appPaletteGray900,
    ),
  ),
  t20(
    TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 28 / 20,
      color: appPaletteGray900,
    ),
  ),
  t20Medium(
    TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 28 / 20,
      color: appPaletteGray900,
    ),
  ),
  t20Bold(
    TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 28 / 20,
      color: appPaletteGray900,
    ),
  ),
  t24(
    TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 32 / 24,
      color: appPaletteGray900,
    ),
  ),
  t24Medium(
    TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      height: 32 / 24,
      color: appPaletteGray900,
    ),
  ),
  t24Bold(
    TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 32 / 24,
      color: appPaletteGray900,
    ),
  ),
  t32(
    TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 40 / 32,
      color: appPaletteGray900,
    ),
  ),
  t32Medium(
    TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      height: 40 / 32,
      color: appPaletteGray900,
    ),
  ),
  t32Bold(
    TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 40 / 32,
      color: appPaletteGray900,
    ),
  ),
  t56(
    TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w400,
      height: 70 / 56,
      color: appPaletteGray900,
    ),
  ),
  t56Medium(
    TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w500,
      height: 70 / 56,
      color: appPaletteGray900,
    ),
  ),
  t56Bold(
    TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      height: 70 / 56,
      color: appPaletteGray900,
    ),
  ),
  t24Oswald(
    TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 32 / 24,
      color: appPaletteGray900,
    ),
  ),
  t32Oswald(
    TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 40 / 32,
      color: appPaletteGray900,
    ),
  ),
  t10Oswald(
    TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 12 / 10,
      color: appPaletteGray900,
    ),
  ),
  t10MediumOswald(
    TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 12 / 10,
      color: appPaletteGray900,
    ),
  ),
  t12Oswald(
    TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 16 / 12,
      color: appPaletteGray900,
    ),
  ),
  t12MediumOswald(
    TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      color: appPaletteGray900,
    ),
  ),
  t12BoldOswald(
    TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 16 / 12,
      color: appPaletteGray900,
    ),
  ),
  t14Oswald(
    TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: appPaletteGray900,
    ),
  ),
  t14MediumOswald(
    TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: appPaletteGray900,
    ),
  ),
  t16Oswald(
    TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      color: appPaletteGray900,
    ),
  ),
  t16MediumOswald(
    TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 24 / 16,
      color: appPaletteGray900,
    ),
  ),
  t16BoldOswald(
    TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 24 / 16,
      color: appPaletteGray900,
    ),
  ),
  t20Oswald(
    TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 28 / 20,
      color: appPaletteGray900,
    ),
  ),
  t20MediumOswald(
    TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 28 / 20,
      color: appPaletteGray900,
    ),
  ),
  t20BoldOswald(
    TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 28 / 20,
      color: appPaletteGray900,
    ),
  ),
  t24MediumOswald(
    TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      height: 32 / 24,
      color: appPaletteGray900,
    ),
  ),
  t24BoldOswald(
    TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 32 / 24,
      color: appPaletteGray900,
    ),
  ),
  t32MediumOswald(
    TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      height: 40 / 32,
      color: appPaletteGray900,
    ),
  ),
  t32BoldOswald(
    TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 40 / 32,
      color: appPaletteGray900,
    ),
  ),
  t56Oswald(
    TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w400,
      height: 70 / 56,
      color: appPaletteGray900,
    ),
  ),
  t56MediumOswald(
    TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w500,
      height: 70 / 56,
      color: appPaletteGray900,
    ),
  ),
  t56BoldOswald(
    TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      height: 70 / 56,
      color: appPaletteGray900,
    ),
  );

  final TextStyle value;

  const AppTextStyle(this.value);
}
