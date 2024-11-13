
import 'package:flutter/material.dart';
import 'package:flutter_lp_canvas/lp_canvas/model/canvas_element_model.dart';

class CanvasElementPainter extends CustomPainter {
  final elementModel eModel;
  final Map testData;
  Offset offset;
  Size size;
  // 新增旋转角度属性
  double rotationAngle;
  double scale; // 缩放比例

  // 新增构造函数参数来初始化testData
  CanvasElementPainter({
    required this.eModel,
    required this.testData
  }) : offset = eModel.offset,
       size = eModel.size,
       rotationAngle = eModel.rotationAngle,
       scale = eModel.scale;

  @override
  void paint(Canvas canvas, Size size) {
    final image = eModel.image;
    final paint = Paint();
    final sourceRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final scaledRect = Rect.fromLTWH(
      eModel.offset.dx,
      eModel.offset.dy,
      sourceRect.size.width * eModel.scale * 0.1,
      sourceRect.size.height * eModel.scale * 0.1,
    );
    // 保存画布状态
    canvas.save();

    // 移动画布到图片的中心点
    final centerX = scaledRect.left + scaledRect.width / 2;
    final centerY = scaledRect.top + scaledRect.height / 2;
    canvas.translate(centerX, centerY);

    // 旋转画布并将角度转为弧度
    canvas.rotate(eModel.rotationAngle);

    // 移动画布回原点
    canvas.translate(-centerX, -centerY);
    
    if (eModel.groupElementMap.containsKey('elementModelList')) {
       // 这里将图片设置为空，即绘制一个空白区域占位，并设置为透明，但仅针对非组元素对应的绘制区域
        paint.color = Colors.transparent;
        canvas.drawRect(scaledRect, paint);
    }else{
        // 绘制图片
        canvas.drawImageRect(image, sourceRect, scaledRect, paint);
    }
    // 恢复画布状态
    canvas.restore();

      // 设置画笔属性
    Paint paint1 = Paint()
    ..color = Colors.blue.withOpacity(0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5;
    //绘制当前元素的在画布的rect
    canvas.drawRect(eModel.elementRect, paint1);

   
  
   if (eModel.groupElementMap.containsKey('elementModelList')) {
     // 校验不是组元素的elementCenter
      Paint paint2 = Paint()
      ..color = Colors.red.withOpacity(1.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      //绘制当前元素的在画布的rect
      canvas.drawRect(Rect.fromCenter(center: eModel.elementCenter, width: 1, height: 1), paint2);

      // if (eModel.elementVertex.containsKey('tl')) {
      //           Offset tl =  eModel.elementVertex['tl'];
      //           Offset tr =  eModel.elementVertex['tr'];
      //           Offset bl =  eModel.elementVertex['bl'];
      //           Offset br =  eModel.elementVertex['br'];
      //      Paint paint3 = Paint()
      //       ..color = Colors.purple.withOpacity(1.0)
      //       ..style = PaintingStyle.stroke
      //       ..strokeWidth = 1;
      //       //绘制当前元素的在画布的rect
      //       canvas.drawRect(Rect.fromCenter(center:tl, width: 1, height: 1), paint3);


      //       Paint paint4 = Paint()
      //       ..color = Colors.purple.withOpacity(1.0)
      //       ..style = PaintingStyle.stroke
      //       ..strokeWidth = 1;
      //       //绘制当前元素的在画布的rect
      //       canvas.drawRect(Rect.fromCenter(center: tr, width: 1, height: 1), paint4);


      //       Paint paint5 = Paint()
      //       ..color = Colors.purple.withOpacity(1.0)
      //       ..style = PaintingStyle.stroke
      //       ..strokeWidth = 1;
      //       //绘制当前元素的在画布的rect
      //       canvas.drawRect(Rect.fromCenter(center:bl, width: 1, height: 1), paint5);

      //       Paint paint6 = Paint()
      //       ..color = Colors.purple.withOpacity(1.0)
      //       ..style = PaintingStyle.stroke
      //       ..strokeWidth = 1;
      //       //绘制当前元素的在画布的rect
      //       canvas.drawRect(Rect.fromCenter(center: br, width: 1, height: 1), paint6);
    //  }
            


    }


     // 绘制groupElementMap里的元素
    if (eModel.groupElementMap.containsKey('elementModelList')) {
        List<elementModel> groupElements = eModel.groupElementMap['elementModelList'];

        // 遍历组内元素并绘制
        for (var groupElement in groupElements) {
            final groupImage = groupElement.image;
            final groupSourceRect = Rect.fromLTWH(
                0,
                0,
                groupImage.width.toDouble(),
                groupImage.height.toDouble());
            final groupScaledRect = Rect.fromLTWH(
                groupElement.offset.dx,
                groupElement.offset.dy,
                groupSourceRect.size.width * groupElement.scale * 0.1,
                groupSourceRect.size.height * groupElement.scale * 0.1,
            );
              Paint groupPaint = Paint()
              ..color = Colors.green.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
            // 保存画布状态
            canvas.save();
            // 移动画布到组内元素的中心点
            final groupCenterX = groupScaledRect.left +
                groupScaledRect.width / 2;
            final groupCenterY = groupScaledRect.top +
                groupScaledRect.height / 2;
            canvas.translate(groupCenterX, groupCenterY);
            // 旋转画布（使用组内元素的旋转角度）
            canvas.rotate(groupElement.rotationAngle);
            // 移动画布回原点
            canvas.translate(-groupCenterX, -groupCenterY);
            // 绘制组内元素的图片
            paint.color = Colors.white;
            canvas.drawImageRect(
                groupImage, groupSourceRect, groupScaledRect, paint);
            // 恢复画布状态
            canvas.restore();
            // 绘制组内元素在画布的rect
            print('groupElement.elementRect:${groupElement.elementRect}');
            Rect theRect = groupElement.elementRect;
            canvas.drawRect(Rect.fromLTWH(theRect.left, theRect.top, theRect.width, theRect.height), groupPaint);

            // 校验组元素里的elementCenter
            Paint paint2 = Paint()
            ..color = Colors.purple.withOpacity(1.0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
            //绘制当前元素的在画布的rect
            canvas.drawRect(Rect.fromCenter(center: groupElement.elementCenter, width: 1, height: 1), paint2);

              // if (testData.containsKey('tl')) {
              // // 校验不是组元素的elementCenter
              //   Offset tl =  testData['tl'];
              //   Offset tr =  testData['tr'];
              //   Offset bl =  testData['bl'];
              //   Offset br =  testData['br'];
              //   Paint paint2 = Paint()
              //   ..color = Colors.pink.withOpacity(1.0)
              //   ..style = PaintingStyle.stroke
              //   ..strokeWidth = 1;
              //   //绘制当前元素的在画布的rect
              //   canvas.drawRect(Rect.fromCenter(center: tl, width: 1, height: 1), paint2);
              //   canvas.drawRect(Rect.fromCenter(center: tr, width: 1, height: 1), paint2);
              //   canvas.drawRect(Rect.fromCenter(center: bl, width: 1, height: 1), paint2);
              //   canvas.drawRect(Rect.fromCenter(center: br, width: 1, height: 1), paint2);
              // }


                // if (groupElement.elementVertex.containsKey('tl')) {

                //     Offset tl =  groupElement.elementVertex['tl'];
                //     Offset tr =  groupElement.elementVertex['tr'];
                //     Offset bl =  groupElement.elementVertex['bl'];
                //     Offset br =  groupElement.elementVertex['br'];
                //     Paint paint3 = Paint()
                //     ..color = Colors.purple.withOpacity(1.0)
                //     ..style = PaintingStyle.stroke
                //     ..strokeWidth = 1;
                //     //绘制当前元素的在画布的rect
                //     canvas.drawRect(Rect.fromCenter(center:tl, width: 1, height: 1), paint3);


                //     Paint paint4 = Paint()
                //     ..color = Colors.purple.withOpacity(1.0)
                //     ..style = PaintingStyle.stroke
                //     ..strokeWidth = 1;
                //     //绘制当前元素的在画布的rect
                //     canvas.drawRect(Rect.fromCenter(center: tr, width: 1, height: 1), paint4);


                //     Paint paint5 = Paint()
                //     ..color = Colors.purple.withOpacity(1.0)
                //     ..style = PaintingStyle.stroke
                //     ..strokeWidth = 1;
                //     //绘制当前元素的在画布的rect
                //     canvas.drawRect(Rect.fromCenter(center:bl, width: 1, height: 1), paint5);

                //     Paint paint6 = Paint()
                //     ..color = Colors.purple.withOpacity(1.0)
                //     ..style = PaintingStyle.stroke
                //     ..strokeWidth = 1;
                //     //绘制当前元素的在画布的rect
                //     canvas.drawRect(Rect.fromCenter(center: br, width: 1, height: 1), paint6);

                // }
            
        }
    }
  }

  @override
  bool shouldRepaint(CanvasElementPainter oldDelegate) {
    if (oldDelegate.offset == offset &&
        oldDelegate.size == size &&
        oldDelegate.rotationAngle == rotationAngle &&
        oldDelegate.scale == scale) {
   //   print("不绘制");
      return false;
    }
   // print("绘制");
    return true;
  }
  // bool shouldRepaint(CanvasElementPainter oldDelegate) => true;

}


class TouchRectPainter extends CustomPainter {
  Rect bgRect; // 新增的背景矩形属性，不属于eModel

  // 新增构造函数参数来初始化bgRect，这里设置一个默认值示例
  TouchRectPainter({
    this.bgRect = const Rect.fromLTRB(0, 0, 0.1, 0.1),
  });

  @override
  void paint(Canvas canvas, Size size) {

      //显示绘制范围，宽高小于50像素不绘制范围
      if (bgRect.width > 50 || bgRect.height>50) {
          // 设置背景范围画笔属性
        Paint paint2 = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

        // 绘制背景矩形边框（可选，如果不需要边框可注释掉这行）
        canvas.drawRect(bgRect, paint2);

        // 设置蒙版画笔属性，这里设置为半透明的黑色
        Paint maskPaint = Paint()
      ..color = Colors.orange.withOpacity(0.2)
      ..style = PaintingStyle.fill;

        // 在bgRect区域绘制蒙版矩形
        canvas.drawRect(bgRect, maskPaint);
    }
    
  }
  @override
  bool shouldRepaint(TouchRectPainter oldDelegate) => true;
}