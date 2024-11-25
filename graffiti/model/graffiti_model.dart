import 'package:flutter/material.dart';

class GraffitiModel {
  late Path path;
  late Color paintColor;
  late double paintWidth;

  GraffitiModel(
      {required this.path, required this.paintColor, required this.paintWidth});

  GraffitiModel.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    paintColor = json['paintColor'];
    paintWidth = json['paintWidth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['paintColor'] = paintColor;
    data['paintWidth'] = paintWidth;
    return data;
  }
}
