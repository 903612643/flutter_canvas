/*
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../lp_canvas/model/canvas_model.dart';
import 'package:flutter_lp_canvas/lp_canvas/widget/canvasMenuWidget.dart';

class LPCanvasMainPage extends StatefulWidget {
  const LPCanvasMainPage({super.key, this.initScale = 1.0});

  /// 初始化缩放比例
  final double initScale;

  @override
  State<LPCanvasMainPage> createState() => _DraggableImagesWidgetState();
}

class _DraggableImagesWidgetState extends State<LPCanvasMainPage> {
  bool showCustomPaint = false;
  canvasListModel? currentModel;
  List<canvasListModel> listModel = [];
  List<List<canvasListModel>> historyList = [];
  int currentHistoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadImages();
    //初始化当前画布信息
    canvasModel(1.0, 0);
    //加载一个空画布
    historyList.add([]);
    //   Map<String, dynamic> myMap = {
    // 'historyList': historyList,
    // 'bgScale': 1.0,
    // };
    tController.value = Matrix4.identity()..scale(widget.initScale);
    tController.addListener(_onScaleChanged);
  }

  Future<void> _loadImages() async {
    for (var i = 0; i < 5; i++) {
      final imgByteData = await rootBundle.load('assets/images/35.jpg');
      final imgCodec =
          await ui.instantiateImageCodec(imgByteData.buffer.asUint8List());
      final imgFrame = await imgCodec.getNextFrame();
      setState(() {
        listModel.add(
          canvasListModel(
              1000 + i,
              imgFrame.image,
              Offset(i + 100, i * 100),
              Size(
                imgFrame.image.width.toDouble() * 0.1,
                imgFrame.image.height.toDouble() * 0.1,
              )),
        );
      });
    }

    final List<canvasListModel> newListModel = [];
    listModel.forEach((e) {
      newListModel.add(e.deepCopy());
    });
    historyList.add(newListModel);

    currentHistoryIndex = historyList.length - 1;

    // print('history_count=${historyList.length}');

    // historyList.forEach((innerList) {
    //   print('innerList=$innerList');
    //   innerList.forEach((element) {
    //     print(
    //         'Image: ${element.image}, Offset: ${element.offset}, Size: ${element.size}');
    //   });
    // });
  }

  final tController = TransformationController();

  double currentScale = 1.0;

  void _onScaleChanged() {
    final Matrix4 matrix = tController.value;
    currentScale = matrix.entry(0, 0);
    canvasModel(currentScale, 0);
    print('当前缩放倍数: $currentScale');
  }

  @override
  Widget build(BuildContext context) {
    bool isPreviousDisabled = true;
    bool isNextDisabled = true;
    if (currentHistoryIndex == 0) {
      isPreviousDisabled = true;
    } else {
      isPreviousDisabled = false;
    }
    if (currentHistoryIndex < historyList.length - 1) {
      isNextDisabled = false;
    } else {
      isNextDisabled = true;
    }
    final mediaQueryData = MediaQuery.of(context);
    final safeAreaHeight = mediaQueryData.size.height -
        mediaQueryData.padding.top -
        mediaQueryData.padding.bottom;
    if (!showCustomPaint) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!showCustomPaint)
                ElevatedButton(
                  onPressed: () {
                    setState(
                      () {
                        showCustomPaint = true;
                      },
                    );
                  },
                  child: Text('Add View'),
                ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('拖动'),
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: tController,
            minScale: 0.1,
            maxScale: 10.0,
            child: Stack(
              children: List.generate(
                listModel.length,
                (index) {
                  final model = listModel[index];
                  return Positioned(
                    left: model.offset.dx,
                    top: model.offset.dy,
                    child: Draggable(
                      onDragUpdate: (details) {
                        setState(() {
                          model.offset += ui.Offset(
                              details.delta.dx / currentScale,
                              details.delta.dy / currentScale);
                          //  currentModel?.offset = model.offset;
                        });
                      },
                      onDragStarted: () {
                        currentModel = model.deepCopy();
                      },
                      onDragEnd: (details) {
                        final List<canvasListModel> newListModel = [];
                        listModel.forEach((e) {
                          newListModel.add(e.deepCopy());
                        });
                        historyList.add(newListModel);

                        currentHistoryIndex = historyList.length - 1;
                        isNextDisabled = true;
                        isPreviousDisabled = false;

                        print('historyList.count = ${historyList.length}');
                        // //当前操作后历史记录的数据
                        // historyList.forEach((innerList) {
                        //   // print('innerList=$innerList');
                        //   innerList.forEach((element) {
                        //     print(
                        //         'Image: ${element.image}, Offset: ${element.offset}, Size: ${element.size}');
                        //   });
                        // });
                      },
                      feedback: const SizedBox(),
                      child: GestureDetector(
                        onTap: () {
                          print('图片被点击，索引为 $index');
                        },
                        child: Container(
                          width: 0.1 * model.image.width.toDouble(),
                          height: 0.1 * model.image.height.toDouble(),
                          child: CustomPaint(
                            size:
                                Size(mediaQueryData.size.width, safeAreaHeight),
                            painter: DraggableImagesPainter(model),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          canvasmenuwidget(
            onNext: () {
              print('下一步');
              currentHistoryIndex++;
              if (currentHistoryIndex > historyList.length - 1) {
                currentHistoryIndex = historyList.length - 1;
              }
              listModel = historyList[currentHistoryIndex];
              setState(() {});
            },
            onPrevious: () {
              currentHistoryIndex--;
              if (currentHistoryIndex < 0) {
                currentHistoryIndex = 0;
              }
              listModel = historyList[currentHistoryIndex];
              print('currentHistoryIndex = $currentHistoryIndex');

              historyList.forEach((innerList) {
                print('innerList=$innerList');
                innerList.forEach((element) {
                  print(
                      'Image: ${element.image}, Offset: ${element.offset}, Size: ${element.size}');
                });
              });
              setState(() {});
              print('上一步');
            },
            isPreviousDisabled: isPreviousDisabled,
            isNextDisabled: isNextDisabled,
          ),
        ],
      ),
    );
  }
}

class DraggableImagesPainter extends CustomPainter {
  final canvasListModel listModel;

  DraggableImagesPainter(this.listModel);

  @override
  void paint(Canvas canvas, Size size) {
    final image = listModel.image;
    final paint = Paint();
    final sourceRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final scaledRect = Rect.fromLTWH(
        0, 0, 0.1 * sourceRect.size.width, 0.1 * sourceRect.size.height);
    canvas.drawImageRect(image, sourceRect, scaledRect, paint);
  }

  @override
  bool shouldRepaint(DraggableImagesPainter oldDelegate) {
    return listModel != oldDelegate.listModel ||
        listModel.offset != oldDelegate.listModel.offset ||
        listModel.size != oldDelegate.listModel.size;
  }
}
*/

/*
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_lp_canvas/lp_canvas/res/assets_res.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lp_canvas/lp_canvas/model/canvas_element_model.dart';
import 'dart:ui' as ui;
import '../lp_canvas/model/canvas_model.dart';
import 'widget/canvasElementPainter.dart';

class LPCanvasMainPage extends StatefulWidget {
  const LPCanvasMainPage({super.key});

  @override
  State<LPCanvasMainPage> createState() => _ImageMainPageState();
}

class _ImageMainPageState extends State<LPCanvasMainPage> {
  // 编辑的图片列表
  final List<elementModel> listModel = [];
  canvasListModel? currentModel;
  // 当前编辑的图片索引
  int currentIndex = -1;

  /// 初始化缩放比例
  final double initScale = 1.0;
  double currentScale = 1.0;

  // 图标的大小
  static const double iconSize = 30.0;
  static const double textContainerHeight = 30.0;
  static const double textContainerWidth = 200.0;
  final tController = TransformationController();

  //是否正在旋转
  bool isHandleRotating = false;

// 用于存储起始位置
  Offset globalPanStartDetails = const Offset(0, 0);

  @override
  void initState() {
    super.initState();

    tController.value = Matrix4.identity()..scale(initScale);
    tController.addListener(_onScaleChanged);

    // 异步执行操作
    Future.delayed(Duration.zero, () => importImage());
  }

  @override
  void dispose() {
    listModel.clear();
    super.dispose();
  }

  // 导入图片 这里使用代码写死
  Future<void> importImage() async {
    final img1ByteData = await rootBundle.load(AssetsRes.EXAMPLE);
    final img1Codec =
        await ui.instantiateImageCodec(img1ByteData.buffer.asUint8List());
    final img1Frame = await img1Codec.getNextFrame();
    listModel.add(elementModel(
        image: img1Frame.image,
        offset: const Offset(100, 100),
        size: Size(img1Frame.image.width * 0.1, img1Frame.image.height * 0.1)));
    setState(() {});
  }

  // 恢复初始状态
  void reset() {
    if (listModel.isNotEmpty) {
      currentIndex = -1;
      listModel.clear();
    }
  }

  void _onScaleChanged() {
    final Matrix4 matrix = tController.value;
    currentScale = matrix.entry(0, 0);
    canvasModel(currentScale, 0);
    print('当前缩放倍数: $currentScale');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('创作'),
      ),
      body: InteractiveViewer(
        transformationController: tController,
        minScale: 0.1,
        maxScale: 10.0,
        onInteractionStart: (details) {
          print('点击了 InteractiveViewer');
          currentIndex = -1;
          setState(() {});
        },
        child: Stack(
          children: [
            // 图片编辑区
            Positioned(top: 10, child: _buildElementEditorArea()),
            // 底部工具栏
            Positioned(
                left: 10, right: 10, bottom: 10, child: _buildBottomToolBar()),
          ],
        ),
      ),
    );
  }

  /// 编辑图片区域
  Widget _buildElementEditorArea() {
    final mediaQueryData = MediaQuery.of(context);
    final safeAreaHeight = mediaQueryData.size.height -
        mediaQueryData.padding.top -
        mediaQueryData.padding.bottom;
    return Stack(
      children: [
        // 绘制所有图片
        CustomPaint(
          size: Size(mediaQueryData.size.width, safeAreaHeight),
          painter: CanvasElementPainter(listModel: listModel),
        ),
        // 处理每个图片的点击和拖动事件
        ...List.generate(listModel.length, (index) {
          final model = listModel[index];
          return Positioned(
            left: model.offset.dx,
            top: model.offset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  currentIndex = index;
                  model.offset += details.delta;
                });
              },
              onPanStart: (details) {
                print('object--------');
              },
              onTap: () {
                setState(() {
                  currentIndex = index;
                });
              },
              child: Transform.rotate(
                angle: model.rotationAngle,
                child: Container(
                  width: model.size.width * model.scale,
                  height: model.size.height * model.scale,
                  decoration: BoxDecoration(
                    border: currentIndex == index
                        ? Border.all(color: Colors.yellow, width: 1)
                        : null,
                  ),
                ),
              ),
            ),
          );
        }),
        //编辑图片时显示的内容
        ..._buildElementEditorTool(),
      ],
    );
  }

  /// 底部工具栏
  Widget _buildBottomToolBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 上一步
          IconButton(
              onPressed: () async {
                // todo 这里为了调试，设置成初始状态
                reset();
                await importImage();
                setState(() {});
              },
              icon: const Icon(Icons.rotate_left)),
          // 下一步
          IconButton(onPressed: () {}, icon: const Icon(Icons.rotate_right)),
          // 复制
          IconButton(
              onPressed: () {
                final currentModel = listModel[currentIndex];
                // todo 这里写死复制的图片为原图片向右下平移50像素
                listModel.add(currentModel.clone(
                    offset: Offset(currentModel.offset.dx + 50,
                        currentModel.offset.dy + 50)));
                // todo 且默认将当前图片设置为复制的图片
                // 设置当前索引为新的图片
                currentIndex = listModel.length - 1;
                setState(() {});
              },
              icon: const Icon(Icons.copy)),
          // 显示或关闭编辑按钮
          IconButton(onPressed: () {}, icon: const Icon(Icons.remove_red_eye)),
        ],
      ),
    );
  }

  /// 编辑图片时显示的内容
  List<Widget> _buildElementEditorTool() {
    if (currentIndex <= -1) {
      return [const SizedBox()];
    }
    // 当前编辑的图片
    final currentModel = listModel[currentIndex];
    // 顶部显示尺寸信息坐标
    final topTextOffset = handleRotatePoint(
        Offset(
          currentModel.offset.dx +
              currentModel.size.width * currentModel.scale / 2,
          currentModel.offset.dy - textContainerHeight,
        ),
        currentModel,
        distanceXY: textContainerWidth / 2,
        distanceY: textContainerHeight / 2);
    // 左上角坐标
    final leftTopOffset = handleRotatePoint(currentModel.offset, currentModel,
        distanceXY: iconSize / 2);
    // 右上角坐标
    final rightTopOffset = handleRotatePoint(
        Offset(
            currentModel.offset.dx +
                currentModel.size.width * currentModel.scale,
            currentModel.offset.dy),
        currentModel,
        distanceXY: iconSize / 2);
    // 左下角坐标
    final leftBottomOffset = handleRotatePoint(
        Offset(
            currentModel.offset.dx,
            currentModel.offset.dy +
                currentModel.size.height * currentModel.scale),
        currentModel,
        distanceXY: iconSize / 2);

    // 右下角坐标
    final rightBottomOffset = handleRotatePoint(
        Offset(
            currentModel.offset.dx +
                currentModel.size.width * currentModel.scale,
            currentModel.offset.dy +
                currentModel.size.height * currentModel.scale),
        currentModel,
        distanceXY: iconSize / 2);

    // 尺寸信息
    final String imageSizeContent =
        "${(currentModel.size.width * currentModel.scale).toStringAsFixed(2)}mm × ${(currentModel.size.height * currentModel.scale).toStringAsFixed(2)}mm";
    // 旋转角度
    final String rotateAngleContent =
        "${(currentModel.rotationAngle * 180 / pi).toStringAsFixed(2)}°";
    return [
      // 顶部显示尺寸信息
      Positioned(
        left: topTextOffset.dx,
        top: topTextOffset.dy,
        child: Transform.rotate(
          angle: currentModel.rotationAngle,
          child: Container(
            alignment: Alignment.center,
            width: textContainerWidth,
            height: textContainerHeight,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isHandleRotating ? rotateAngleContent : imageSizeContent,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),

      // 左上角 删除按钮
      _buildItemEditorTool(
        leftTopOffset,
        currentModel.rotationAngle,
        Icons.delete,
      ),
      // 右上角 旋转按钮
      //region 右上角 旋转按钮
      _buildItemEditorTool(
          rightTopOffset, currentModel.rotationAngle, Icons.crop_rotate,
          onPanStart: (details) {
        globalPanStartDetails = details.globalPosition;
        isHandleRotating = true;
      }, onPanUpdate: (details) {
        final currentGlobalPosition = details.globalPosition;
        // 计算角度
        final angle = atan2(currentGlobalPosition.dy - globalPanStartDetails.dy,
            currentGlobalPosition.dx - globalPanStartDetails.dx);

        currentModel.rotationAngle = angle;
        setState(() {});
      }, onPanEnd: (details) {
        isHandleRotating = false;
      }),
      //endregion

      // 左下角 锁按钮
      _buildItemEditorTool(
        leftBottomOffset,
        currentModel.rotationAngle,
        Icons.lock,
      ),

      // 右下角 缩放按钮
      _buildItemEditorTool(
        rightBottomOffset,
        currentModel.rotationAngle,
        Icons.open_in_full,
        onPanStart: (details) {
          globalPanStartDetails = details.globalPosition;
        },
        onPanUpdate: (details) {
          final currentGlobalPosition = details.globalPosition;
          final dy = currentGlobalPosition.dy - globalPanStartDetails.dy;
          // 将newScale保留两位小数
          final newScale = double.parse(
              (currentModel.scale + dy * 0.001).toStringAsFixed(2));
          currentModel.scale = newScale.clamp(0.5, 4.0); // 限制缩放范围
          setState(() {});
        },
        onPanEnd: (details) {},
      ),
    ];
  }

  /// 构建每个编辑工具
  Widget _buildItemEditorTool(
      Offset locationPoint, double angle, IconData iconData,
      {GestureDragStartCallback? onPanStart,
      GestureDragUpdateCallback? onPanUpdate,
      GestureDragEndCallback? onPanEnd}) {
    return Positioned(
        left: locationPoint.dx,
        top: locationPoint.dy,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: GestureDetector(
            onPanStart: onPanStart,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,

            child: Transform.rotate(
              angle: angle,
              child: Icon(
                iconData,
                size: iconSize,
                color: Colors.white,
              ),
            ),
            // child: Transform.rotate(
            //   angle: angle,
            //   child: iconData == Icons.crop_rotate
            //       ? Image.asset(
            //           AssetsRes.EXAMPLE,
            //           width: iconSize,
            //           height: iconSize,
            //         )
            //       : Icon(
            //           iconData,
            //           size: iconSize,
            //           color: Colors.white,
            //         ),
            // ),
            // child: Transform.rotate(
            //     angle: angle,
            //     child: Image.asset(AssetsRes.EXAMPLE, width: 30, height: 30)
            //     ),
          ),
        ));
  }

  //处理旋转后的点应该在的位置
  Offset handleRotatePoint(Offset oldPoint, elementModel currentImage,
      {double distanceXY = 0, double distanceY = 0}) {
    //得到图形的中心点
    final centerX = currentImage.offset.dx +
        currentImage.size.width * currentImage.scale / 2;
    final centerY = currentImage.offset.dy +
        currentImage.size.height * currentImage.scale / 2;
    final centerOffset = Offset(centerX, centerY);
    final radian = currentImage.rotationAngle;

    // 计算新的 x 和 y 坐标
    final newX = centerOffset.dx +
        (oldPoint.dx - centerOffset.dx) * cos(radian) -
        (oldPoint.dy - centerOffset.dy) * sin(radian);
    final newY = centerOffset.dy +
        (oldPoint.dy - centerOffset.dy) * cos(radian) +
        (oldPoint.dx - centerOffset.dx) * sin(radian);
    if (distanceY != 0) {
      return Offset(newX - distanceXY, newY - distanceY);
    }
    return Offset(newX - distanceXY, newY - distanceXY);
  }
}

*/



// import 'package:flutter/material.dart';
// import 'package:flutter_lp_canvas/lp_canvas/model/canvas_element_model.dart';

// class CanvasElementPainter extends CustomPainter {
//   final List<elementModel> listModel;

//   CanvasElementPainter({required this.listModel});

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (var i = 0; i < listModel.length; i++) {
//       final image = listModel[i].image;
//       final paint = Paint();
//       final sourceRect =
//           Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
//       final scaledRect = Rect.fromLTWH(
//           listModel[i].offset.dx,
//           listModel[i].offset.dy,
//           sourceRect.size.width * listModel[i].scale * 0.1,
//           sourceRect.size.height * listModel[i].scale * 0.1);

//       // 保存画布状态
//       canvas.save();

//       // 移动画布到图片的中心点
//       final centerX = scaledRect.left + scaledRect.width / 2;
//       final centerY = scaledRect.top + scaledRect.height / 2;
//       canvas.translate(centerX, centerY);

//       // 旋转画布并将角度转为弧度
//       canvas.rotate(listModel[i].rotationAngle);

//       // 移动画布回原点
//       canvas.translate(-centerX, -centerY);

//       // 绘制图片
//       canvas.drawImageRect(image, sourceRect, scaledRect, paint);

//       // 恢复画布状态
//       canvas.restore();
//     }
//   }

//   bool shouldRepaint(CanvasElementPainter oldDelegate) => true;
// }















/*

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_lp_canvas/lp_canvas/res/assets_res.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lp_canvas/lp_canvas/model/canvas_element_model.dart';
import 'dart:ui' as ui;
import 'widget/canvasElementPainter.dart';
import 'package:flutter_lp_canvas/lp_canvas/widget/canvasMenuWidget.dart';

class LPCanvasNotifier extends ChangeNotifier {
  final List<elementModel> notifierModel = [];

  void addLine(elementModel line) {
    notifierModel.add(line);
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  void clear() {
    notifierModel.clear();
    notifyListeners();
  }
}

class LPCanvasMainPage extends StatefulWidget {
  const LPCanvasMainPage({super.key});

  @override
  State<LPCanvasMainPage> createState() => _ImageMainPageState();
}

class _ImageMainPageState extends State<LPCanvasMainPage> {

  LPCanvasNotifier canvasNotifier = LPCanvasNotifier();

  // 编辑的图片列表
  List<elementModel> elementModelList = [];

  // 当前编辑的图片索引
  int currentIndex = -1;

  //历史记录列表
  List<List<elementModel>> historyList = [];

  //当前历史记录索引
  int currentHistoryIndex = 0;

  bool isPreviousDisabled = true;
  bool isNextDisabled = true;

  /// 初始化缩放比例
  final double initScale = 1.0;
  double currentScale = 1.0;

  // 图标的大小
  static const double iconSize = 30.0;
  static const double textContainerHeight = 30.0;
  static const double textContainerWidth = 200.0;
  final tController = TransformationController();

  //是否正在旋转
  bool isHandleRotating = false;

// 用于存储起始位置
  Offset globalPanStartDetails = const Offset(0, 0);

  /*记录手指滑动屏幕的开始坐标和结束坐标以得到一个rect，将rect范围内的元素加入其中成为一个组元素*/
  // 用于存储开始触摸的点坐标
  Offset? startTouchPoint;
  // 用于存储当前触摸的点坐标
  Offset? currentTouchPoint;

  //testMap,这是一个测试数据
  Map<String, dynamic> testMap = {};


  @override
  void initState() {
    super.initState();
    historyList.add([]);
    tController.value = Matrix4.identity()..scale(initScale);
    tController.addListener(_onScaleChanged);
    // 异步执行操作
    Future.delayed(Duration.zero, () => importImage());
  }

  @override
  void dispose() {
    elementModelList.clear();
    super.dispose();
  }

  //模拟导入N个图片
  Future<void> importImage() async {
    for (var i = 0; i < 3; i++) {
        final img1ByteData = await rootBundle.load(AssetsRes.EXAMPLE);
        final img1Codec =
        await ui.instantiateImageCodec(img1ByteData.buffer.asUint8List());
        final img1Frame = await img1Codec.getNextFrame();
          //得到组元素的顶点
        Map<String, dynamic> elementVertexMap = {};
        elementVertexMap['tl'] = Offset(i + 100, i * 100);
        elementVertexMap['tr'] = Offset(i + 100 + img1Frame.image.width * 0.1, i * 100);
        elementVertexMap['bl'] = Offset(i + 100, i * 100+ img1Frame.image.height * 0.1);
        elementVertexMap['br'] = Offset(i + 100 + img1Frame.image.width * 0.1, i * 100+ img1Frame.image.height * 0.1);

        setState(() {
          elementModelList.add(elementModel(
          image: img1Frame.image,
          offset:  Offset(i + 100, i * 100),
          size: Size(img1Frame.image.width * 0.1, img1Frame.image.height * 0.1),
          rotationAngle: 0,
          initialRotationAngle: 0,
          scale: 1.0,
          elementRect: Rect.fromLTWH(i + 100, i * 100, img1Frame.image.width * 0.1, img1Frame.image.height * 0.1),
          groupElementMap: Map(),
          elementCenter: Offset(i + 100 + (img1Frame.image.width * 0.1)/2, i * 100 + (img1Frame.image.height * 0.1)/2),
          elementVertex: elementVertexMap
          ));
      });
    }
    final List<elementModel> newListModel =
        elementModelList.map((e) => e.copyWith()).toList();
    historyList.add(newListModel);
    currentHistoryIndex = historyList.length - 1;
  }

  // 恢复初始状态
  void reset() {
    if (elementModelList.isNotEmpty) {
      currentIndex = -1;
      elementModelList.clear();
    }
  }

  void _onScaleChanged() {
    final Matrix4 matrix = tController.value;
    currentScale = matrix.entry(0, 0);
    canvasModel(currentScale, 0);
  }

  void printHistoryData() {
    print("historyList.length==${historyList.length}");
    print("historyList = ${historyList}");
    historyList.forEach((innerList) {
      // print('innerList=$innerList');
      print('--------------------完美分割线------------------');
      innerList.forEach((element) {
        print(
            'Image: ${element.image}, Offset: ${element.offset}, Size: ${element.size}, rect:${element.elementRect},groupElementMap:${element.groupElementMap}');
      });
    });
  }

  void addDataToHistoryList(){
    // 数组的索引深拷贝一个
      final List<elementModel> copyList =
          elementModelList.map((e) => e.clone()).toList();
      // 当前历史索引跟历史数组长度间的差值
      if (historyList.length - currentHistoryIndex > 1) {
        // 后续位置全部删掉
          historyList.removeRange(currentHistoryIndex + 1, historyList.length);
      }
      // 加入下一个位置
      historyList.add(copyList);
      currentHistoryIndex = historyList.length - 1;
      isNextDisabled = true;
      isPreviousDisabled = false;
  }

  // 根据起始触摸点和当前触摸点计算最小x、最大x、最小y、最大y以及宽高
Rect getRectFromTouchPoints() {
  double minX = double.maxFinite;
  double maxX = double.minPositive;
  double minY = double.maxFinite;
  double maxY = double.minPositive;
  if (startTouchPoint!= null && currentTouchPoint!= null) {
    minX = min(startTouchPoint!.dx, currentTouchPoint!.dx);
    maxX = max(startTouchPoint!.dx, currentTouchPoint!.dx);
    minY = min(startTouchPoint!.dy, currentTouchPoint!.dy);
    maxY = max(startTouchPoint!.dy, currentTouchPoint!.dy);
  }
  double width = maxX - minX;
  double height = maxY - minY;
  return Rect.fromLTWH(minX, minY, width, height);
}

//获取所有相交元素的rect
Rect getGroupFromRect(List<elementModel> crossElementModelList) {
   double minX = double.maxFinite;
  double maxX = double.minPositive;
  double minY = double.maxFinite;
  double maxY = double.minPositive;
  for (var element in crossElementModelList) {
      Rect elementRect = element.elementRect;
      // 更新最小x值
      if (elementRect.left < minX) {
          minX = elementRect.left;
      }
      // 更新最大x值
      if (elementRect.right > maxX) {
          maxX = elementRect.right;
      }
      // 更新最小y值
      if (elementRect.top < minY) {
          minY = elementRect.top;
      }
      // 更新最大y值
      if (elementRect.bottom > maxY) {
          maxY = elementRect.bottom;
      }
  }
  double width = maxX - minX ;
  double height = maxY - minY ;
  return Rect.fromLTWH(minX , minY , width, height);
}

  @override
  Widget build(BuildContext context) {
    //  print("currentHistoryIndex==$currentHistoryIndex");
    if (currentHistoryIndex == 0) {
      isPreviousDisabled = true;
    } else {
      isPreviousDisabled = false;
    }
    if (currentHistoryIndex < historyList.length - 1) {
      isNextDisabled = false;
    } else {
      isNextDisabled = true;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('图片编辑'),
      ),
      body: InteractiveViewer(
        transformationController: tController,
        minScale: 0.1,
        maxScale: 10.0,
        onInteractionStart: (details) {
          if (details.pointerCount == 1) {
            //  startTouchPoint = Offset.zero;
              startTouchPoint = details.localFocalPoint;
               currentIndex = -1;
               setState(() {});
          }
         
        },
        onInteractionUpdate: (details) {
           if (details.pointerCount == 1) {
              currentTouchPoint = details.localFocalPoint;
            }
            setState(() {});
        },
        onInteractionEnd: (details) {
          // 获取触摸形成的矩形范围
          Rect touchRect = getRectFromTouchPoints();
          List<elementModel> crossElementModelList = [];
          for (var elementModel in elementModelList) {
              if (touchRect.overlaps(elementModel.elementRect)) {
                  crossElementModelList.add(elementModel);
              } 
          }
          if (crossElementModelList.length>=2) {
           // print('选中的元素大于等于两个===${crossElementModelList}');
             final List<elementModel> newListModel = elementModelList.map((e) => e.copyWith()).toList();
             // 从elementModelList中移除选中的元素
             elementModelList.removeWhere((element) => crossElementModelList.contains(element));
             //添加一个带组的元素
             Map<String, dynamic> groupElementMap = {};
             groupElementMap['elementModelList'] = crossElementModelList;
             final firstElement = newListModel.first;
              // 获取crossElementModelList元素elementModel.elementRect的最小x、最大x、最小y、最大y值
              Rect rect = getGroupFromRect(crossElementModelList);
              //得到组元素的顶点
             Map<String, dynamic> elementVertexMap = {};
             elementVertexMap['tl'] = Offset(rect.left, rect.top);
             elementVertexMap['tr'] = Offset(rect.left + rect.width, rect.top);
             elementVertexMap['bl'] = Offset(rect.left , rect.bottom);
             elementVertexMap['br'] = Offset(rect.left + rect.width , rect.bottom);
             //重新得到范围offset，size,elementRect,elementVertex
              elementModelList.add(elementModel(
              image: firstElement.image,
              offset:  Offset(rect.left, rect.top),
              size: Size(rect.width, rect.height),
              rotationAngle: 0,
              initialRotationAngle: 0,
              scale: 1.0,
              elementRect: rect,
              groupElementMap: groupElementMap,
              elementCenter: Offset(rect.left + rect.width/2, rect.top+rect.height/2),
              elementVertex: elementVertexMap
              ));
              currentIndex = elementModelList.length-1;
             // final model = elementModelList[currentIndex];
             // print('-----------model:${model}');
             crossElementModelList.forEach((elementModel){
               print('11111groupElement.elementRect:${elementModel.elementRect}');
             });
             addDataToHistoryList();
          }
            currentTouchPoint = startTouchPoint;
            setState(() { });
        },
        child: Stack(
          children: [
            // 图片编辑区
            Positioned(top: 10, child: _buildImageEditorArea()),
            canvasmenuwidget(
              onNext: () {
                currentHistoryIndex++;
                if (currentHistoryIndex > historyList.length - 1) {
                  currentHistoryIndex = historyList.length - 1;
                }
                final List<elementModel> copyList = historyList[currentHistoryIndex].map((e) => e.clone()).toList();
                elementModelList = copyList;
                currentIndex = -1;
                setState(() {});
              },
              onPrevious: () {
                currentHistoryIndex--;
                if (currentHistoryIndex < 0) {
                  currentHistoryIndex = 0;
                }
                final List<elementModel> copyList = historyList[currentHistoryIndex].map((e) => e.clone()).toList();
                elementModelList = copyList;
                currentIndex = -1;
                setState(() {});
              },
              isPreviousDisabled: isPreviousDisabled,
              isNextDisabled: isNextDisabled,
            ),
          ],
        ),
      ),
    );
  }

  /// 编辑图片区域
  Widget _buildImageEditorArea() {
    final mediaQueryData = MediaQuery.of(context);
    final safeAreaHeight = mediaQueryData.size.height -
        mediaQueryData.padding.top -
        mediaQueryData.padding.bottom;
    return Stack(
      children: [
        //绘制所有图片
        ...List.generate(elementModelList.length, (index) {
          return RepaintBoundary(
            child: CustomPaint(
              size: Size(mediaQueryData.size.width, safeAreaHeight),
              painter: CanvasElementPainter(eModel: elementModelList[index],testData: testMap),
            ),
          );
        }),
      //新增的CustomPaint用于绘制其他内容（这里以绘制一个基于触摸点矩形的半透明覆盖层）
       if (startTouchPoint!= null && currentTouchPoint!= null)
         CustomPaint(
            size: Size(mediaQueryData.size.width, safeAreaHeight),
            painter: TouchRectPainter(bgRect: getRectFromTouchPoints(),
            ),
        ),
        // 处理每个图片的点击和拖动事件
        ...List.generate(elementModelList.length, (index) {
          final model = elementModelList[index];
          return Positioned(
            left: model.offset.dx,
            top: model.offset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  currentIndex = index;
                  model.offset += details.delta;
                  model.elementCenter = Offset(model.elementRect.left + model.elementRect.width/2, model.elementRect.top + model.elementRect.height/2);
                   if (model.groupElementMap.containsKey('elementModelList')) {
                     List<elementModel> groupElements = model.groupElementMap['elementModelList'];
                     groupElements.forEach((element) {
                       element.offset+=details.delta;
                       element.elementCenter+=details.delta;
                       element.elementRect = Rect.fromLTWH(element.elementCenter.dx - element.elementRect.width/2, element.elementCenter.dy - element.elementRect.height/2, element.elementRect.width, element.elementRect.height);

                                          //得到组元素的顶点
                        Map<String, dynamic> elementVertexMap = {};
                         Offset tl =  element.elementVertex['tl'];
                        Offset tr =  element.elementVertex['tr'];
                        Offset bl =  element.elementVertex['bl'];
                        Offset br =  element.elementVertex['br'];
                        tl+=details.delta;
                        tr+=details.delta;
                        bl+=details.delta;
                        br+=details.delta;

                        elementVertexMap['tl'] = tl;
                        elementVertexMap['tr'] = tr;
                        elementVertexMap['bl'] = bl;
                        elementVertexMap['br'] = br;
                        element.elementVertex = elementVertexMap;

                     });
                   }
                });
              },
              onTap: () {
                setState(() {
                  currentIndex = index;
                });
              },
              onPanEnd: (details) {
                //print('-------elements:${model}');
                addDataToHistoryList();
            //    printHistoryData();
                setState(() {});
              },
              child: Transform.rotate(
                angle: model.rotationAngle,
                child: Container(
                  width: model.size.width * model.scale,
                  height: model.size.height * model.scale,
                  decoration: BoxDecoration(
                    border: currentIndex == index
                        ? Border.all(color: Colors.yellow, width: 1)
                        : null,
                  ),
                ),
              ),
            ),
          );
        }),
        //编辑图片时显示的内容
        ..._buildImageEditorTool(),
      ],
    );
  }

  /// 编辑图片时显示的内容
  List<Widget> _buildImageEditorTool() {
    if (currentIndex <= -1) {
      return [const SizedBox()];
    }
     print('_buildImageEditorTool');
    // 当前编辑的图片
    final currentImage = elementModelList[currentIndex];
    // 顶部显示尺寸信息坐标
    final topTextOffset = handleRotatePoint(
        Offset(
          currentImage.offset.dx +
              currentImage.size.width * currentImage.scale / 2,
          currentImage.offset.dy - textContainerHeight,
        ),
        currentImage,
        distanceXY: textContainerWidth / 2,
        distanceY: textContainerHeight / 2);
    // 左上角坐标
    final leftTopOffset = handleRotatePoint(currentImage.offset, currentImage,
        distanceXY: iconSize / 2);
    // 右上角坐标
    final rightTopOffset = handleRotatePoint(
        Offset(
            currentImage.offset.dx +
                currentImage.size.width * currentImage.scale,
            currentImage.offset.dy),
        currentImage,
        distanceXY: iconSize / 2);
    // 左下角坐标
    final leftBottomOffset = handleRotatePoint(
        Offset(
            currentImage.offset.dx,
            currentImage.offset.dy +
                currentImage.size.height * currentImage.scale),
        currentImage,
        distanceXY: iconSize / 2);
    // 右下角坐标
    final rightBottomOffset = handleRotatePoint(
        Offset(
            currentImage.offset.dx +
                currentImage.size.width * currentImage.scale,
            currentImage.offset.dy +
                currentImage.size.height * currentImage.scale),
        currentImage,
        distanceXY: iconSize / 2);
          // 计算最小x、最大x、最小y、最大y
      double minX = min(
          leftTopOffset.dx,
          min(rightTopOffset.dx, min(leftBottomOffset.dx, rightBottomOffset.dx)));
      double maxX = max(
          leftTopOffset.dx,
          max(rightTopOffset.dx, max(leftBottomOffset.dx, rightBottomOffset.dx)));
      double minY = min(
          leftTopOffset.dy,
          min(rightTopOffset.dy, min(leftBottomOffset.dy, rightBottomOffset.dy)));
      double maxY = max(
          leftTopOffset.dy,
          max(rightTopOffset.dy, max(leftBottomOffset.dy, rightBottomOffset.dy)));
      // 计算宽度w和高度h
      double w = maxX - minX;
      double h = maxY - minY;
      currentImage.elementRect = Rect.fromLTWH(minX+iconSize/2, minY+iconSize/2, w, h);

       //得到组元素的顶点
      Map<String, dynamic> elementVertexMap = {};
      elementVertexMap['tl'] = Offset(leftTopOffset.dx+iconSize/2, leftTopOffset.dy+iconSize/2);
      elementVertexMap['tr'] = Offset(rightTopOffset.dx+iconSize/2, rightTopOffset.dy+iconSize/2);;
      elementVertexMap['bl'] = Offset(leftBottomOffset.dx+iconSize/2, leftBottomOffset.dy+iconSize/2);;
      elementVertexMap['br'] = Offset(rightBottomOffset.dx+iconSize/2, rightBottomOffset.dy+iconSize/2);;
      currentImage.elementVertex = elementVertexMap;

    // 尺寸信息
    final String imageSizeContent =
        "${(currentImage.size.width * currentImage.scale).toStringAsFixed(2)}mm × ${(currentImage.size.height * currentImage.scale).toStringAsFixed(2)}mm";
    // 旋转角度
    final String rotateAngleContent =
        "${(currentImage.rotationAngle * 180 / pi).toStringAsFixed(2)}°";
    return [
      // 顶部显示尺寸信息
      Positioned(
        left: topTextOffset.dx,
        top: topTextOffset.dy,
        child: Transform.rotate(
          angle: currentImage.rotationAngle,
          child: Container(
            alignment: Alignment.center,
            width: textContainerWidth,
            height: textContainerHeight,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isHandleRotating ? rotateAngleContent : imageSizeContent,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),

      // 左上角 删除按钮
      _buildItemEditorTool(
        leftTopOffset,
        currentImage.rotationAngle,
        Icons.delete,
      ),
      // 右上角 旋转按钮
      //region 右上角 旋转按钮
      _buildItemEditorTool(
          rightTopOffset, currentImage.rotationAngle, Icons.crop_rotate,
          onPanStart: (details) {
        globalPanStartDetails = details.globalPosition;
        isHandleRotating = true;
         if (currentImage.groupElementMap.containsKey('elementModelList')) {
            List<elementModel> groupElements = currentImage.groupElementMap['elementModelList'];
            // 遍历元素列表，存储每个元素的初始旋转角度
               groupElements.forEach((element) {
            // 新增一个属性来存储初始旋转角度，假设elementModel类可以新增属性
               element.initialRotationAngle = element.rotationAngle;
            });
        }
      }, onPanUpdate: (details) {
        final currentGlobalPosition = details.globalPosition;
        // 计算角度
        final angle = atan2(currentGlobalPosition.dy - globalPanStartDetails.dy,
            currentGlobalPosition.dx - globalPanStartDetails.dx);
        currentImage.rotationAngle = angle;

        if (currentImage.groupElementMap.containsKey('elementModelList')) {
            List<elementModel> groupElements = currentImage.groupElementMap['elementModelList'];
            // 遍历元素列表，存储每个元素的初始旋转角度
            groupElements.forEach((element) {
                // 新增一个属性来存储初始旋转角度，假设elementModel类可以新增属性
                element.initialRotationAngle = element.rotationAngle;
            });
        }
  
        setState(() {});
      },onPanEnd: (details) {

           if (currentImage.groupElementMap.containsKey('elementModelList')) {
            List<elementModel> groupElements = currentImage.groupElementMap['elementModelList'];
            final currentImageCenter = currentImage.elementCenter;
            groupElements.forEach((element) {
                // 计算元素相对于currentImage的位置偏移量
              final Offset relativeOffset = element.elementCenter - currentImageCenter;

              // 根据旋转角度更新偏移量
              final double rotatedX = relativeOffset.dx * cos(currentImage.rotationAngle) - relativeOffset.dy * sin(currentImage.rotationAngle);
              final double rotatedY = relativeOffset.dx * sin(currentImage.rotationAngle) + relativeOffset.dy * cos(currentImage.rotationAngle);

              // 更新elementCenter的位置
              element.elementCenter = currentImageCenter + Offset(rotatedX, rotatedY);

              // // 更新elementRect（根据新的elementCenter重新计算elementRect）
              // final double width = element.elementRect.width;
              // final double height = element.elementRect.height;
              // element.elementRect = Rect.fromLTWH(
              //     element.elementCenter.dx - width / 2,
              //     element.elementCenter.dy - height / 2,
              //     width,
              //     height
              // );

              element.offset = Offset(element.elementRect.left, element.elementRect.top);

               element.rotationAngle = currentImage.rotationAngle + element.initialRotationAngle;

           
            });


          }
       
           addDataToHistoryList();
           printHistoryData();
        }),
      //endregion

      // 左下角 锁按钮
      _buildItemEditorTool(
        leftBottomOffset,
        currentImage.rotationAngle,
        Icons.lock,
      ),

      // 右下角 缩放按钮
      _buildItemEditorTool(
          rightBottomOffset, currentImage.rotationAngle, Icons.open_in_full,
          onPanStart: (details) {
        globalPanStartDetails = details.globalPosition;
      }, onPanUpdate: (details) {
        final currentGlobalPosition = details.globalPosition;
          // 计算 globalPanStartDetails 与 currentGlobalPosition 之间的距离差
          final dy = currentGlobalPosition.dy - globalPanStartDetails.dy;
          final dx = currentGlobalPosition.dx - globalPanStartDetails.dx;
          final distance = dy + dx;
          // 将newScale保留两位小数
          final newScale = double.parse(
              (currentImage.scale + distance * 0.0005).toStringAsFixed(2));
              final double scaleRatio = newScale / currentImage.scale;
          currentImage.scale = newScale.clamp(0.5, 4.0); // 限制缩放范围
           if (currentImage.groupElementMap.containsKey('elementModelList')) {
            List<elementModel> groupElements = currentImage.groupElementMap['elementModelList'];
              // 先计算currentImage缩放后的新尺寸
            final double newWidth = currentImage.size.width * scaleRatio;
            final double newHeight = currentImage.size.height * scaleRatio;
    
            print('----------scaleRatio:${scaleRatio}');
            groupElements.forEach((element) {
                // element.scale = newScale;
                element.offset = Offset(
                    element.offset.dx * scaleRatio,
                    element.offset.dy * scaleRatio
                );
     

               //  print('currentImage.size.width:${currentImage.size.width}');

                // // 更新size
                // // 根据element在currentImage中的相对位置和比例计算新的size
                // final double relativeWidth = element.size.width / currentImage.size.width;
                // final double relativeHeight = element.size.height / currentImage.size.height;
                // element.size = Size(
                //     newWidth * relativeWidth,
                //     newHeight * relativeHeight
                // );
            // 计算当前元素相对于currentImage左上角的偏移量
            final double offsetXFromCurrentImage = element.offset.dx - currentImage.offset.dx;
            final double offsetYFromCurrentImage = element.offset.dy - currentImage.offset.dy;
                // 更新elementRect
            element.elementRect = Rect.fromLTWH(
                currentImage.offset.dx + offsetXFromCurrentImage * scaleRatio,
                currentImage.offset.dy + offsetYFromCurrentImage * scaleRatio,
                element.elementRect.width * scaleRatio,
                element.elementRect.height * scaleRatio
            );

                // // 更新elementCenter
                // element.elementCenter = Offset(
                //     element.elementCenter.dx * scaleRatio,
                //     element.elementCenter.dy * scaleRatio
                // );

                // // 更新elementVertex
                // Map elementVertexMap = element.elementVertex;
                // elementVertexMap['tl'] = Offset(
                //     elementVertexMap['tl'].dx * scaleRatio,
                //     elementVertexMap['tl'].dy * scaleRatio
                // );
                // elementVertexMap['tr'] = Offset(
                //     elementVertexMap['tr'].dx * scaleRatio,
                //     elementVertexMap['tr'].dy * scaleRatio
                // );
                // elementVertexMap['bl'] = Offset(
                //     elementVertexMap['bl'].dx * scaleRatio,
                //     elementVertexMap['bl'].dy * scaleRatio
                // );
                // elementVertexMap['br'] = Offset(
                //     elementVertexMap['br'].dx * scaleRatio,
                //     elementVertexMap['br'].dy * scaleRatio
                // );
                // element.elementVertex = elementVertexMap;
            });
       }
        setState(() {});
      },onPanEnd: (details) {
           addDataToHistoryList();
        },
      ),
    ];
  }

  /// 构建每个编辑工具
  Widget _buildItemEditorTool(
      Offset locationPoint, double angle, IconData iconData,
      {GestureDragStartCallback? onPanStart,
      GestureDragUpdateCallback? onPanUpdate,
      GestureDragEndCallback? onPanEnd}) {
    return Positioned(
        left: locationPoint.dx,
        top: locationPoint.dy,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: GestureDetector(
            onPanStart: onPanStart,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            child: Transform.rotate(
              angle: angle,
              child: Icon(
                iconData,
                size: iconSize,
                color: Colors.white,
              ),
            ),
          ),
        ));
  }

  //处理旋转后的点应该在的位置
  Offset handleRotatePoint(Offset oldPoint, elementModel currentImage,
      {double distanceXY = 0, double distanceY = 0}) {
    //得到图形的中心点
    final centerX = currentImage.offset.dx +
        currentImage.size.width * currentImage.scale / 2;
    final centerY = currentImage.offset.dy +
        currentImage.size.height * currentImage.scale / 2;
    final centerOffset = Offset(centerX, centerY);
    final radian = currentImage.rotationAngle;

    // 计算新的 x 和 y 坐标
    final newX = centerOffset.dx +
        (oldPoint.dx - centerOffset.dx) * cos(radian) -
        (oldPoint.dy - centerOffset.dy) * sin(radian);
    final newY = centerOffset.dy +
        (oldPoint.dy - centerOffset.dy) * cos(radian) +
        (oldPoint.dx - centerOffset.dx) * sin(radian);
    if (distanceY != 0) {
      return Offset(newX - distanceXY, newY - distanceY);
    }
    return Offset(newX - distanceXY, newY - distanceXY);
  }
}


*/