import 'dart:ui' as ui;
import 'dart:ui';

//画布信息
class canvasModel {
  double bgScale; //当前背景缩放比例
  int index;       //当前历史记录索引
  canvasModel(this.bgScale, this.index);
}

/// 图片信息模型
class elementModel {
  elementModel({
      required this.image,
      required this.offset,
      required this.size,
      required this.rotationAngle,
      required this.initialRotationAngle,
      required  this.scale,
      required  this.elementRect,
      required this.groupElementMap,
      required this.elementCenter,
      required this.elementVertex,
    //  required this.isChanged,
      });
  ui.Image image;           //图片
  Offset offset;            //位于画布的x,y值
  Size   size;              //显示图片组件的尺寸
  double rotationAngle;     //新增旋转角度属性
  double initialRotationAngle;//新增旋转角度初始值(元素是组元素时有用)
  double scale;             //缩放比例
  Rect   elementRect;       //改元素占用画布的rect
  Map    groupElementMap;   //组元素，当前元素是组元素，这里值不为空，并且子元素>=2
  Offset elementCenter;     //元素旋转中心点
  Map    elementVertex;     //元素顶点坐标
 //bool    isChanged = false;

    // // 可以添加一个方法来重置更改状态
    // void resetChangedStatus() {
    //     isChanged = false;
    // }

  // 克隆方法，方便复制图片信息
  elementModel clone() => (elementModel(
      image: image.clone(),
      offset: Offset(offset.dx, offset.dy),
      size: Size(size.width, size.height),
      rotationAngle: rotationAngle,
      initialRotationAngle: initialRotationAngle,
      scale: scale,
      elementRect: elementRect,
      groupElementMap: groupElementMap,
      elementCenter: elementCenter,
      elementVertex: elementVertex,
    //  isChanged: isChanged,
      ));

  @override
  String toString() {
    return 'elementModel{image: $image, offset: $offset, size: $size, rotationAngle: $rotationAngle, scale: $scale, elementRect: $elementRect, groupElementMap: $groupElementMap}';
  }

  elementModel copyWith({
    String? image,
    Offset? offset,
    Size? size,
    double? rotationAngle,
    double? initialRotationAngle,
    double? scale,
    double? initScale,
    Rect? elementRect,
    Map?  groupElementMap,
    Offset?  elementCenter,
    Map?  elementVertex,
   // bool?  isChanged
  })=>elementModel(
      image:this.image,
      offset: offset?? this.offset,
      size: size?? this.size,
      rotationAngle: rotationAngle?? this.rotationAngle,
      initialRotationAngle: initialRotationAngle?? this.initialRotationAngle,
      scale: scale?? this.scale,
      elementRect:elementRect?? this.elementRect,
      groupElementMap:groupElementMap?? this.groupElementMap,
      elementCenter:elementCenter?? this.elementCenter,
      elementVertex:elementVertex?? this.elementVertex,
   //   isChanged:isChanged?? this.isChanged,
    );

}
