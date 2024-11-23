import 'package:flutter/material.dart';
import 'package:flutter_canvas/res/assets_res.dart';

class TestZoomImageFromSize extends StatefulWidget {
  const TestZoomImageFromSize({super.key});

  @override
  State<TestZoomImageFromSize> createState() => _TestZoomImageFromSizeState();
}

class _TestZoomImageFromSizeState extends State<TestZoomImageFromSize> {

  // 开始拖动之前点击按钮保存的坐标
  Offset dragStartPosition = Offset.zero;

  // 设置默认图片大小(图片右下角位置）
  Offset imageRightBottomPosition = const Offset(200, 200);
  bool isDrag = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用图片尺寸缩放图片'),
      ),
      body: Container(
        height: double.infinity,width: double.infinity,
        color: Colors.blue[50],
        child: Stack(
          children: [
            Container(
              color: Colors.green[50],
              child: GestureDetector(
                onPanStart: myOnPanStart,
                onPanUpdate: myOnPanUpdate,
                onPanEnd: myOnPanEnd,
                child: Image.asset(
                  alignment: Alignment(1, 1),
                  AssetsRes.EXAMPLE,
                  width: imageRightBottomPosition.dx,
                  height: imageRightBottomPosition.dy,
                ),
              ),
            ),
            Positioned(
              left: imageRightBottomPosition.dx-10,
              top: imageRightBottomPosition.dy-10,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue
                ),
                height: 20,
                width: 20,
              ),
            )
          ],
        ),
      ),
    );
  }

  void myOnPanStart(DragStartDetails details) {
    final Offset localPosition = details.localPosition;
    print("distance=${(localPosition - imageRightBottomPosition).distance }");
    if ((localPosition - imageRightBottomPosition).distance < 25) {
      isDrag = true;
    }
    dragStartPosition = localPosition;

  }

  void myOnPanUpdate(DragUpdateDetails details) {
    final Offset localPosition = details.localPosition;
    final Offset delta = localPosition - dragStartPosition;

    setState(() {
      if (isDrag) {
        imageRightBottomPosition += delta;
      }
      dragStartPosition = localPosition;
    });
  }

  void myOnPanEnd(DragEndDetails details) {
    isDrag = false;
  }
}
