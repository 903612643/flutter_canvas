import 'package:flutter/material.dart';
import 'package:flutter_canvas/modules/image_editor/widgets/bottom_action_bar_widget.dart';
import 'package:flutter_canvas/modules/image_editor/widgets/style_bar_widget.dart';
import 'package:flutter_canvas/res/assets_res.dart';

/// 图片编辑页面
class ImageEditorPage extends StatelessWidget {
  const ImageEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('创作'),
      ),
      body: Column(
        children: [
          // 主体区域
          Expanded(
            child: Transform.scale(
              scale: 0.8,
              child: SizedBox(
                height: double.infinity,
               child: Image.asset(AssetsRes.EXAMPLE),
              ),
            ),
          ),
         // 样式条
         const StyleBarWidget(),
          // 底部功能条
          const BottomActionBarWidget()
        ],
      ),
    );
  }
}
