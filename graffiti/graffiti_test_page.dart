import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lp_base/constant/constant_export.dart';
import 'package:lp_base/utils/screen_ui.dart';
import 'package:lp_assets/lp_assets.dart';
import 'package:lp_share/lp_share.dart';
import 'model/graffiti_line_model.dart';
import 'model/speed_point_model.dart';

class GraffitiNotifier extends ChangeNotifier {
  final List<GraffitiLineModel> lines = [];

  void addLine(GraffitiLineModel line) {
    lines.add(line);
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  void clear() {
    lines.clear();
    notifyListeners();
  }
}

class GraffitiTestPage extends StatefulWidget {
  const GraffitiTestPage({super.key});

  @override
  GraffitiTestPageState createState() => GraffitiTestPageState();
}

class GraffitiTestPageState extends State<GraffitiTestPage> {
  int? _firstPointerId; // 用于跟踪第一个触摸点的ID
  GraffitiNotifier graffitiNotifier = GraffitiNotifier();

  /// 历史栈
  GraffitiNotifier historyGraffitiNotifier = GraffitiNotifier();

  List<OptionsModel> iconList = [
    OptionsModel(label: "", value: 0, labelIcon: LpAssets.svg.pencil.keyName),
    OptionsModel(label: "", value: 1, labelIcon: LpAssets.svg.pen.keyName),
    OptionsModel(label: "", value: 2, labelIcon: LpAssets.svg.eraser.keyName),
  ];
  ValueNotifier<int> currentPenValue = ValueNotifier(0);
  int penWidth = 5;

  PenType get currentPenType => currentPenValue.value == 0
      ? PenType.pencil
      : currentPenValue.value == 2
          ? PenType.eraser
          : PenType.pen;
  ValueNotifier<GraffitiLineModel> currentLine = ValueNotifier(GraffitiLineModel(points: [], paintColor: Colors.black, paintWidth: 8, penType: PenType.pen));

  @override
  void dispose() {
    graffitiNotifier.dispose();
    historyGraffitiNotifier.dispose();
    currentLine.dispose();
    super.dispose();
  }

  void clear() {
    graffitiNotifier.clear();
    currentLine.value.points = [];
    currentLine.value = currentLine.value.copyWith(points: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: LpAppbar(
        leading: const SizedBox.shrink(),
        border: true,
        titleWidget: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (graffitiNotifier.lines.isEmpty) return;
                var item = graffitiNotifier.lines.removeLast();
                historyGraffitiNotifier.addLine(item);
                graffitiNotifier.update();
              },
              child: ListenableBuilder(
                listenable: graffitiNotifier,
                builder: (ctx, child) {
                  Color color = graffitiNotifier.lines.isEmpty ? LightColors.greyB0 : LightColors.textColor;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgWidget(
                          width: 28,
                          height: 28,
                          color: color,
                          svg: LpAssets.svg.reverseStep.keyName,
                        ),
                        Text(
                          "${graffitiNotifier.lines.length}",
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Gaps.getHGap(18),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (historyGraffitiNotifier.lines.isEmpty) return;
                var item = historyGraffitiNotifier.lines.removeLast();
                graffitiNotifier.addLine(item);
                graffitiNotifier.update();
                historyGraffitiNotifier.update();
              },
              child: ListenableBuilder(
                listenable: historyGraffitiNotifier,
                builder: (ctx, child) {
                  Color color = historyGraffitiNotifier.lines.isEmpty ? LightColors.greyB0 : LightColors.textColor;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgWidget(
                          width: 28,
                          height: 28,
                          color: color,
                          svg: LpAssets.svg.forwardStep.keyName,
                        ),
                        Text(
                          "${historyGraffitiNotifier.lines.length}",
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Gaps.getHGap(56),
          ],
        ),
      ),
      body: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildPainter(),
                  _buildBottom(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPainter() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Listener(
        onPointerDown: (details) {
          if (_firstPointerId == null) {
            _firstPointerId = details.pointer;
            currentLine.value = GraffitiLineModel(
                penType: currentPenType,
                points: [SpeedPointModel(point: details.localPosition, time: DateTime.now().millisecondsSinceEpoch)],
                paintWidth: currentPenType == PenType.pen ? 8.0 : penWidth.toDouble(),
                paintColor: Colors.black);
          }
        },
        onPointerMove: (details) {
          if (details.pointer != _firstPointerId) return;
          var p = details.localPosition;

          /// 判断过滤重复的点
          if (currentLine.value.points.isNotEmpty &&
              currentLine.value.points[currentLine.value.points.length - 1].point.dx == p.dx &&
              currentLine.value.points[currentLine.value.points.length - 1].point.dy == p.dy) return;
          currentLine.value.points.add(SpeedPointModel(point: p, time: DateTime.now().millisecondsSinceEpoch));

          currentLine.value = currentLine.value.copyWith(points: currentLine.value.points);
        },
        onPointerUp: (details) {
          if (details.pointer != _firstPointerId) return;
          _firstPointerId = null;

          /// 把当前线条塞进去
          var p = details.localPosition;
          currentLine.value.points.add(SpeedPointModel(point: p, time: DateTime.now().millisecondsSinceEpoch));
          currentLine.value = currentLine.value.copyWith(points: currentLine.value.points);
          graffitiNotifier.addLine(currentLine.value.copyWith());
          currentLine.value.points = [];
          currentLine.value = currentLine.value.copyWith(points: []);
          historyGraffitiNotifier.lines.clear();
          historyGraffitiNotifier.update();
          for (int i = 0; i < 100; i += 20) {
            Future.delayed(Duration(milliseconds: i), () {
              graffitiNotifier.update();
            });
          }
        },
        onPointerCancel: (details) {
          // 同样需要处理触摸取消的情况
          if (details.pointer == _firstPointerId) {
            _firstPointerId = null;
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  isComplex: true,
                  willChange: false,

                  /// 绘制已记录的record
                  painter: PenCustomPainter(graffitiNotifier: graffitiNotifier),

                  /// 绘制新的线条
                ),
              ),
              RepaintBoundary(
                child: CustomPaint(
                  willChange: true,
                  painter: CurrentPenCustomPainter(currentLine: currentLine),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: CustomKbhBox(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            children: [
              ListenableBuilder(
                  listenable: currentPenValue,
                  builder: (ctx, child) {
                    return SliderGroupItem(
                      title: currentPenValue.value == 2 ? "橡皮大小" : "笔刷大小",
                      minValue: 1,
                      maxValue: 50,
                      initValue: penWidth.toDouble(),
                      onChange: (val) {
                        penWidth = val;
                      },
                    );
                  }),
              Gaps.vGap40,
              BtmConfirmBtnMenuBox(
                  child: CustomAnimatedSwitcher(
                      align: Alignment.center,
                      switchList: iconList,
                      onTap: (item) {
                        currentPenValue.value = item.value;
                      },
                      bgColor: const Color(0xFFECECEC),
                      activeItemBgColor: Colors.white),
                  onCancel: () {},
                  onConfirm: () {}),
              Gaps.getVGap(ScreenUI.bottomSafeHeight + 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentPenCustomPainter extends CustomPainter {
  CurrentPenCustomPainter({required this.currentLine}) : super(repaint: currentLine);

  final ValueNotifier<GraffitiLineModel> currentLine;
  double penMinWidth = 2.0; // 最小宽度
  double penInitialWidth = 8.0; // 起始宽度
  double lastLineWidth = 8.0;
  double maxSpeed = 0.8;
  double minSpeed = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    var points = currentLine.value.points;
    if (points.isNotEmpty) {
      lastLineWidth = penInitialWidth;
      for (int i = 0; i < points.length - 1; i++) {
        double speed = getSpeed(points[i], points[i + 1]);
        double lineW = 0;
        if (i > points.length - 5) {
          lineW = lastLineWidth;
        } else {
          lineW = _computedLineWidth(speed);
        }

        canvas.drawLine(points[i].point, points[i + 1].point, paint..strokeWidth = lineW);
      }
    }
  }

  /// 计算宽度
  _computedLineWidth(double speed) {
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

  /// 计算速度: 距离/ 时间
  double getSpeed(SpeedPointModel b, SpeedPointModel e) {
    var d = zDistance(b.point, e.point);
    double s = d / (e.time - b.time); //计算速度
    return s;
  }

  /// 计算两点之间的直线距离
  zDistance(Offset b, Offset e) {
    return sqrt(pow(e.dx - b.dx, 2) + pow(e.dy - b.dy, 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PenCustomPainter extends CustomPainter {
  PenCustomPainter({required this.graffitiNotifier}) : super(repaint: graffitiNotifier);
  final GraffitiNotifier graffitiNotifier;
  double lastLineWidth = 8.0;
  double penMinWidth = 2.0; // 最小宽度
  double penInitialWidth = 8.0; // 起始宽度
  double maxSpeed = 0.8;
  double minSpeed = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var item in graffitiNotifier.lines) {
      lastLineWidth = penInitialWidth;
      var points = item.points;
      if (points.isNotEmpty) {
        for (int i = 0; i < points.length - 1; i++) {
          double speed = getSpeed(points[i], points[i + 1]);
          double lineW = 0;
          if (i > points.length - 5) {
            lineW = lastLineWidth;
          } else {
            lineW = _computedLineWidth(speed);
          }

          canvas.drawLine(points[i].point, points[i + 1].point, paint..strokeWidth = lineW);
        }
      }
    }
  }

  /// 计算宽度
  _computedLineWidth(double speed) {
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

  double getSpeed(SpeedPointModel b, SpeedPointModel e) {
    var d = zDistance(b.point, e.point);
    double s = d / (e.time - b.time); //计算速度
    return s;
  }

  /// 计算两点之间的直线距离
  zDistance(Offset b, Offset e) {
    return sqrt(pow(e.dx - b.dx, 2) + pow(e.dy - b.dy, 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
