import 'package:flutter/material.dart';
/// 样式条
class StyleBarWidget extends StatelessWidget {
  const StyleBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 40,
      child: Text("样式条"),
    );
  }
}
