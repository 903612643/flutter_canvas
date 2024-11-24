import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_canvas/res/assets_res.dart';

class TestZoomImageFromCustomPainter extends StatefulWidget {
  const TestZoomImageFromCustomPainter({super.key});

  @override
  State<TestZoomImageFromCustomPainter> createState() => _TestZoomImageFromCustomPainterState();
}

class _TestZoomImageFromCustomPainterState extends State<TestZoomImageFromCustomPainter> {
  // 编辑的图片
   ui.Image? editorImage;

  // 开始拖动之前点击按钮保存的坐标
  Offset dragStartPosition = Offset.zero;

  // 设置默认图片大小(图片右下角位置）
  Offset imageRightBottomPosition = const Offset(100, 100);
  bool isDrag = false;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    final ByteData data = await rootBundle.load(AssetsRes.EXAMPLE);
    ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
      setState(() {
        editorImage = img;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用自定义绘画缩放图片'),
      ),
      body: GestureDetector(
        onPanStart: myOnPanStart,
        onPanUpdate: myOnPanUpdate,
        onPanEnd: myOnPanEnd,
        child: editorImage == null
            ? const CircularProgressIndicator()
            : CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: EditorImagePainter(
                    image: editorImage!, imageSize: imageRightBottomPosition),
              ),
      ),
    );
  }

  void myOnPanStart(DragStartDetails details) {
    final Offset localPosition = details.localPosition;

    if ((localPosition - imageRightBottomPosition).distance < 20) {
      isDrag = true;
    }
    dragStartPosition = details.localPosition;
  }

  void myOnPanUpdate(DragUpdateDetails details) {
    final Offset localPosition = details.localPosition;
    final Offset delta = localPosition - dragStartPosition;

    setState(() {
      if (isDrag) {
        print("开始时imagePosition=${imageRightBottomPosition}");
        imageRightBottomPosition += delta;
        print("结束时imageRightBottomPosition=${imageRightBottomPosition}");
      }
      dragStartPosition = localPosition;
    });
  }

  void myOnPanEnd(DragEndDetails details) {
    isDrag = false;
  }
}

class EditorImagePainter extends CustomPainter {
  final ui.Image image;
  final Offset imageSize;

  EditorImagePainter({required this.image, required this.imageSize});

  final Paint myPaint = Paint()..color = Colors.blue;

  @override
  void paint(Canvas canvas, Size size) {
    // 图片大小
    final Rect rect = Rect.fromPoints(Offset.zero, imageSize);
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        rect,
        myPaint);

    // 在图片右下角设置个图标
    canvas.drawCircle(imageSize, 10, myPaint);
  }

  @override
  bool shouldRepaint(EditorImagePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize;
  }
}
