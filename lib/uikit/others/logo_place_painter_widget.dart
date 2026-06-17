import 'package:flutter/material.dart';

const Color _kMainDarkGrey = Color(0xFF312D34);
const Color _kDiagonalLinesGrey = Color(0xFF524C55);
const Color _kFooterBlack = Color(0xFF000000);
const Color _kCutOutWhite = Color(0xFFFFFFFF);

/// CustomPainter: тёмная плашка со скруглённым правым нижним углом,
/// белый скруглённый вырез слева внизу, диагональные линии, чёрная полоса снизу.
class LogoPlaceShapePainter extends CustomPainter {
  /// Создаёт painter для отрисовки композиции.
  const LogoPlaceShapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height;
    final footerH = h * 0.10;
    final contentH = h - footerH;

    // 1) Чёрная полоса снизу
    canvas.drawRect(
      Rect.fromLTWH(0, contentH, w, footerH),
      Paint()..color = _kFooterBlack,
    );

    // 2) Белый скруглённый вырез в левом нижнем углу основной области
    final cutOutR = (w * 0.22).clamp(8, 80).toDouble();
    final cutOutRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, contentH - cutOutR, cutOutR, cutOutR),
      Radius.circular(cutOutR),
    );
    canvas.drawRRect(cutOutRRect, Paint()..color = _kCutOutWhite);

    // 3) Основная тёмная форма: прямоугольник со скруглённым правым нижним углом минус вырез
    final brRadius = (contentH * 0.15).clamp(4, 60).toDouble();
    final mainRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, w, contentH),
      bottomRight: Radius.circular(brRadius),
    );
    final mainPath = Path()..addRRect(mainRRect);
    final cutOutPath = Path()..addRRect(cutOutRRect);
    final filledPath = Path.combine(
      PathOperation.difference,
      mainPath,
      cutOutPath,
    );
    canvas.drawPath(filledPath, Paint()..color = _kMainDarkGrey);

    // 4) Диагональные линии (снизу-слева вверх-вправо)
    const lineAngle = 0.65;
    const strokeW = 2.2;

    final linePaint = Paint()
      ..color = _kDiagonalLinesGrey
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Кластер справа вверху — две параллельные линии
    final tx = w * 0.72;
    final ty = contentH * 0.28;
    final lineLen1 = w * 0.22;
    final lineLen2 = w * 0.18;
    final dx = lineLen1 * 0.92;
    final dy = lineLen1 * lineAngle;
    canvas.drawLine(Offset(tx, ty), Offset(tx + dx, ty - dy), linePaint);
    canvas.drawLine(
      Offset(tx + 4, ty + 8),
      Offset(
        tx + 4 + dx * (lineLen2 / lineLen1),
        ty + 8 - dy * (lineLen2 / lineLen1),
      ),
      linePaint,
    );

    // Кластер слева внизу — три параллельные линии (средняя длиннее)
    final bx = w * 0.12;
    final by = contentH * 0.72;
    final lineLenMid = w * 0.32;
    final lineLenShort = w * 0.20;
    final dxMid = lineLenMid * 0.92;
    final dyMid = lineLenMid * lineAngle;
    final dxShort = lineLenShort * 0.92;
    final dyShort = lineLenShort * lineAngle;
    canvas.drawLine(
      Offset(bx, by + 12),
      Offset(bx + dxShort, by + 12 - dyShort),
      linePaint,
    );
    canvas.drawLine(
      Offset(bx + 6, by + 6),
      Offset(bx + 6 + dxMid, by + 6 - dyMid),
      linePaint,
    );
    canvas.drawLine(
      Offset(bx + 12, by),
      Offset(bx + 12 + dxShort, by - dyShort),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Дефолтная ширина виджета, когда не задана.
const double kLogoPlaceDefaultWidth = 200;

/// Дефолтная высота виджета, когда не задана.
const double kLogoPlaceDefaultHeight = 80;

/// Виджет, отображающий композицию фигур через [LogoPlaceShapePainter].
class LogoPlacePainterWidget extends StatelessWidget {
  /// Создаёт виджет с опциональными [width] и [height].
  const LogoPlacePainterWidget({super.key, this.width, this.height});

  /// Желаемая ширина (null — из констрейнтов или [kLogoPlaceDefaultWidth]).
  final double? width;

  /// Желаемая высота (null — из констрейнтов или [kLogoPlaceDefaultHeight]).
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w =
            width ??
            (constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : kLogoPlaceDefaultWidth);
        final h =
            height ??
            (constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : kLogoPlaceDefaultHeight);
        return SizedBox(
          width: w,
          height: h,
          child: CustomPaint(
            painter: const LogoPlaceShapePainter(),
            size: Size(w, h),
          ),
        );
      },
    );
  }
}
