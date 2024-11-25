import 'package:flutter/material.dart';

import 'speed_point_model.dart';

enum PenType { pencil, pen, eraser, brush }

class GraffitiLineModel {
  late List<SpeedPointModel> points;
  late Color paintColor;
  late double paintWidth;
  late PenType penType;

  GraffitiLineModel(
      {required this.points,
      required this.paintColor,
      required this.penType,
      required this.paintWidth});

  GraffitiLineModel.fromJson(Map<String, dynamic> json) {
    points = json['points'];
    penType = json['penType'];
    paintColor = json['paintColor'];
    paintWidth = json['paintWidth'];
  }

  GraffitiLineModel copyWith(
      {int? lineType,
      List<SpeedPointModel>? points,
      Color? paintColor,
      double? paintWidth,
      PenType? penType}) {
    return GraffitiLineModel(
      points: points ?? this.points,
      paintColor: paintColor ?? this.paintColor,
      penType: penType ?? this.penType,
      paintWidth: paintWidth ?? this.paintWidth,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['points'] = points;
    data['penType'] = penType;
    data['paintColor'] = paintColor;
    data['paintWidth'] = paintWidth;
    return data;
  }
}
