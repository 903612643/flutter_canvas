import 'dart:math';
import 'dart:ui';
import 'model/graffiti_line_model.dart';
import 'model/speed_point_model.dart';

class PenUtils {
  /// 计算速度: 距离/ 时间
  static double getSpeed(SpeedPointModel b, SpeedPointModel e) {
    var d = zDistance(b.point, e.point);
    double s = d / (e.time - b.time); //计算速度
    return s;
  }

  static double lastLineWidth = 8.0;

  /// 计算两点之间的直线距离
  static zDistance(Offset b, Offset e) {
    return sqrt(pow(e.dx - b.dx, 2) + pow(e.dy - b.dy, 2));
  }

  /// 计算宽度
  static computedLineWidth(double speed,
      {double penMinWidth = 2.0,
      double penInitialWidth = 8.0,
      double maxSpeed = 0.8,
      double minSpeed = 0.2}) {
    double lineWidth = 0.0;
    double minWidth = penMinWidth;
    double maxWidth = penInitialWidth;

    if (speed >= maxSpeed) {
      lineWidth = minWidth;
    } else if (speed <= minSpeed) {
      lineWidth = maxWidth;
    } else {
      lineWidth = maxWidth - (speed / maxSpeed) * maxWidth;
    }

    lineWidth = lineWidth * (1 / 3) + lastLineWidth * (2 / 3);
    lastLineWidth = lineWidth;
    return lineWidth;
  }

  /// [penType] pencil 铅笔，pen 钢笔，eraser 橡皮擦，brush 毛笔
  static void paint(
      {required Canvas canvas,
      required Paint paint,
      required List<SpeedPointModel> points,
      required PenType penType,
      // 最小宽度
      double penMinWidth = 2.0,
      // 起始宽度
      double penInitialWidth = 8.0}) {
    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (points.isNotEmpty) {
      ///毛笔
      if (penType == PenType.brush) {
        paint
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        if (points.isNotEmpty) {
          lastLineWidth = penInitialWidth;
          for (int i = 0; i < points.length - 1; i++) {
            double speed = getSpeed(points[i], points[i + 1]);
            double lineW = 0;
            if (i > points.length - 5) {
              lineW = lastLineWidth;
            } else {
              lineW = computedLineWidth(speed);
            }

            canvas.drawLine(points[i].point, points[i + 1].point,
                paint..strokeWidth = lineW);
          }
        }
      } else {
        Path path = Path();

        /// 钢笔，铅笔，橡皮擦
        if (penType == PenType.pen) {
          /// 绘制椭圆
          final Rect rect = Rect.fromCenter(
              center: Offset(points[0].point.dx, points[0].point.dy),
              width: penInitialWidth - 1,
              height: penInitialWidth + 2);

          canvas.drawOval(
              rect,
              paint
                ..color = const Color(0xFF333333)
                ..style = PaintingStyle.fill);
        }
        path.moveTo(points[0].point.dx, points[0].point.dy);

        for (int i = 1; i < points.length - 1; i++) {
          var mid = Offset(
            (points[i].point.dx + points[i + 1].point.dx) / 2,
            (points[i].point.dy + points[i + 1].point.dy) / 2,
          );
          path.quadraticBezierTo(
            points[i].point.dx,
            points[i].point.dy,
            mid.dx,
            mid.dy,
          );
        }
        path.lineTo(points.last.point.dx, points.last.point.dy);
        if (penType == PenType.pencil || penType == PenType.eraser) {
          canvas.drawPath(
              path,
              paint
                ..style = PaintingStyle.stroke
                ..strokeWidth = penInitialWidth
                ..color = penType == PenType.eraser
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF333333));
        } else if (penType == PenType.pen) {
          PathMetrics metrics = path.computeMetrics();

          for (PathMetric metric in metrics) {
            double segmentLength = metric.length;

            /// 不超过60的时候，从segmentLength - 2开始逐渐变细
            double startPosition =
                segmentLength - min(segmentLength - 2, 60); // 从长度减去60的位置开始逐渐变细
            Path startPath = Path();
            startPath.addPath(
                metric.extractPath(0, startPosition), Offset.zero);
            canvas.drawPath(
                startPath,
                paint
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = penInitialWidth
                  ..color = const Color(0xFF333333));

            for (double i = startPosition; i < segmentLength; i += 1.0) {
              /// 计算 segmentLength - 60开始的宽度递减
              double width = penInitialWidth -
                  ((i - startPosition) / (segmentLength - startPosition)) *
                      (penInitialWidth - penMinWidth);
              width = width.clamp(penMinWidth, penInitialWidth);
              final Tangent? tangent = metric.getTangentForOffset(i);

              if (tangent != null) {
                final Paint segmentPaint = Paint()
                  ..color = const Color(0xFF333333)
                  ..isAntiAlias = true
                  ..strokeCap = StrokeCap.round
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = width;

                /// 绘制一个点
                final Path segmentPath = Path()
                  ..moveTo(tangent.position.dx, tangent.position.dy)
                  ..lineTo(tangent.position.dx, tangent.position.dy);

                canvas.drawPath(segmentPath, segmentPaint);
              }
            }
          }
        }
      }
    }
  }
}
