import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// {@template asset_image_widget.class}
/// Возвращает виджет который зависит от источника изображения.
/// {@endtemplate}
class VectorImageWidget extends StatelessWidget {
  /// {@macro asset_image_widget.class.class}
  const VectorImageWidget({
    required this.asset,
    this.borderRadius = BorderRadius.zero,
    super.key,
    this.width,
    this.height,
    this.useWrapperSize = false,
    this.wrapperSize,
    this.fit,
    this.color,
  });

  /// Цвет изображения.
  final Color? color;

  /// Путь до локального изображения.
  final String asset;

  /// Ширина изображения.
  final double? width;

  /// Высота изображения.
  final double? height;

  /// Радиус закругления углов изображения.
  final BorderRadius borderRadius;

  /// [BoxFit] для изображения.
  final BoxFit? fit;

  /// Когда размер фото не задан, то для теста надо указать размер. Используем размеры обёртки.
  final bool useWrapperSize;

  /// Размер заглушки для теста.
  final Size? wrapperSize;

  @override
  Widget build(BuildContext context) {
    final color = this.color;

    Widget widget = VectorGraphic(
      loader: AssetBytesLoader(asset),
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
    );

    if (borderRadius != BorderRadius.zero) {
      widget = ClipRRect(borderRadius: borderRadius, child: widget);
    }

    return widget;
  }
}
