import 'package:flutter/material.dart';

const Color _kAppBarBackground = Color(0xFF38323C);
const Color _kAppBarLines = Color(0xFF524C55);

/// CustomPainter: прямоугольник со скруглёнными нижними углами
/// (левый меньше, правый больше) и горизонтальными линиями-декорами.
class AppBarShapePainter extends CustomPainter {
  /// Создаёт painter для отрисовки композиции.
  const AppBarShapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height;

    // 1) Основная форма: прямоугольник со скруглёнными только нижними углами
    final blRadius = (h * 0.10).clamp(2, 40).toDouble();
    final brRadius = (h * 0.20).clamp(4, 60).toDouble();
    final background = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, w, h),
      bottomLeft: Radius.circular(blRadius),
      bottomRight: Radius.circular(brRadius),
    );
    canvas.drawRRect(background, Paint()..color = _kAppBarBackground);

    // 2) Горизонтальные линии (декор)
    final strokeW = (h * 0.02).clamp(1, 4).toDouble();
    final linePaint = Paint()
      ..color = _kAppBarLines
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Группа 1 (слева вверху) — две короткие параллельные линии
    canvas.drawLine(
      Offset(w * 0.08, h * 0.20),
      Offset(w * 0.15, h * 0.20),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.05, h * 0.25),
      Offset(w * 0.12, h * 0.25),
      linePaint,
    );

    // Группа 2 (слева по центру) — одна линия
    canvas.drawLine(
      Offset(w * 0.18, h * 0.50),
      Offset(w * 0.28, h * 0.50),
      linePaint,
    );

    // Группа 3a (справа вверху) — две короткие параллельные линии
    canvas.drawLine(
      Offset(w * 0.65, h * 0.20),
      Offset(w * 0.70, h * 0.20),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.65, h * 0.25),
      Offset(w * 0.70, h * 0.25),
      linePaint,
    );

    // Группа 3b (справа, ниже) — две параллельные линии (нижняя длиннее)
    canvas.drawLine(
      Offset(w * 0.80, h * 0.35),
      Offset(w * 0.85, h * 0.35),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.80, h * 0.40),
      Offset(w * 0.88, h * 0.40),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Дефолтная ширина виджета, когда не задана.
const double kAppBarPainterDefaultWidth = 400;

/// Дефолтная высота виджета, когда не задана.
const double kAppBarPainterDefaultHeight = 56;

/// Виджет, отображающий композицию фигур через [AppBarShapePainter].
class AppBarPainterWidget extends StatelessWidget {
  /// Создаёт виджет с опциональными [width] и [height].
  const AppBarPainterWidget({super.key, this.width, this.height});

  /// Желаемая ширина (null — из констрейнтов или [kAppBarPainterDefaultWidth]).
  final double? width;

  /// Желаемая высота (null — из констрейнтов или [kAppBarPainterDefaultHeight]).
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w =
            width ??
            (constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : kAppBarPainterDefaultWidth);
        final h =
            height ??
            (constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : kAppBarPainterDefaultHeight);
        return SizedBox(
          width: w,
          height: h,
          child: CustomPaint(
            painter: const AppBarShapePainter(),
            size: Size(w, h),
          ),
        );
      },
    );
  }
}
