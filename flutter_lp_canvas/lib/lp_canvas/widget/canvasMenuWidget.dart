import 'package:flutter/material.dart';

class canvasmenuwidget extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isPreviousDisabled;
  final bool isNextDisabled;

  const canvasmenuwidget({
    this.onPrevious,
    this.onNext,
    this.isPreviousDisabled = false,
    this.isNextDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 10.0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: isPreviousDisabled ? null : onPrevious ?? () {},
            child: Text('上一步'),
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: isNextDisabled ? null : onNext ?? () {},
            child: Text('下一步'),
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
