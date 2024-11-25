import 'package:flutter/material.dart';

class SpeedPointModel {
  late Offset point;
  late int time;

  SpeedPointModel({
    required this.point,
    required this.time,
  });

  SpeedPointModel.fromJson(Map<String, dynamic> json) {
    point = json['point'];
    time = json['time'];
  }

  SpeedPointModel copyWith({
    int? time,
    Offset? point,
  }) {
    return SpeedPointModel(
      point: point ?? this.point,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['point'] = point;
    data['time'] = time;
    return data;
  }
}
