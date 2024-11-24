import 'package:flutter/material.dart';
import 'package:flutter_canvas/widgets/test_zoom_image_from_size.dart';
import 'package:flutter_canvas/widgets/test_zoom_image_from_custom_painter.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>const TestZoomImageFromCustomPainter()));

            }, child:  const Text("使用自定义绘画缩放图片")),
            ElevatedButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>const TestZoomImageFromSize()));

            }, child:  const Text("使用图片尺寸缩放图片")),
            const Text("滑动蓝色圆点即可进行缩放")
          ],
        ),
      ),
    );
  }
}
