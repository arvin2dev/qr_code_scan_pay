import 'dart:math';

import 'package:flutter/material.dart';

class QrScannerOverlayShape extends ShapeBorder {
  QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
    double? cutOutWidth,
    double? cutOutHeight,
    this.cutOutBottomOffset = 0,
  })  : cutOutWidth = cutOutWidth ?? cutOutSize ?? 250,
        cutOutHeight = cutOutHeight ?? cutOutSize ?? 250 {
    assert(
      borderLength <=
          min(this.cutOutWidth, this.cutOutHeight) / 2 + borderWidth * 2,
      "Border can't be larger than ${min(this.cutOutWidth, this.cutOutHeight) / 2 + borderWidth * 2}",
    );
    assert(
        (cutOutWidth == null && cutOutHeight == null) ||
            (cutOutSize == null && cutOutWidth != null && cutOutHeight != null),
        'Use only cutOutWidth and cutOutHeight or only cutOutSize');
  }

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutWidth;
  final double cutOutHeight;
  final double cutOutBottomOffset;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _borderLength =
        borderLength > min(cutOutHeight, cutOutHeight) / 2 + borderWidth * 2
            ? borderWidthSize / 2
            : borderLength;
    final _cutOutWidth =
        cutOutWidth < width ? cutOutWidth : width - borderOffset;
    final _cutOutHeight =
        cutOutHeight < height ? cutOutHeight : height - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutWidth / 2 + borderOffset,
      -cutOutBottomOffset +
          rect.top +
          height / 2 -
          _cutOutHeight / 2 +
          borderOffset,
      _cutOutWidth - borderOffset * 2,
      _cutOutHeight - borderOffset * 2,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      // Draw top right corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - _borderLength,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + _borderLength,
          topRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw top left corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.top,
          cutOutRect.left + _borderLength,
          cutOutRect.top + _borderLength,
          topLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw bottom right corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - _borderLength,
          cutOutRect.bottom - _borderLength,
          cutOutRect.right,
          cutOutRect.bottom,
          bottomRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw bottom left corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.bottom - _borderLength,
          cutOutRect.left + _borderLength,
          cutOutRect.bottom,
          bottomLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      ..restore();
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}


class OverlayWidget extends StatefulWidget{

  final double width;


  OverlayWidget(this.width);

  @override
  State<StatefulWidget> createState() => OverLayState();

}

class OverLayState extends State<OverlayWidget> with TickerProviderStateMixin{
  late Animation<double> _animation;
  late AnimationController _controller;

  //起始之间的线性插值器 从 0.05 到 0.95 百分比。
  final Tween<double> _rotationTween = Tween(begin: 0.05, end: 0.95);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,     //实现 TickerProviderStateMixin
      duration: Duration(seconds: 3), //动画时间 3s
    );

    _animation = _rotationTween.animate(_controller)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _controller.repeat();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: ScanFramePainter(widget.width,lineMoveValue: _controller.value),
          child: Container(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}

class ScanFramePainter extends CustomPainter {

  final double width;
 //默认定义扫描框为 260边长的正方形
  late Size frameSize;
  final double cornerLength = 20.0;
  ScanFramePainter(this.width,{this.lineMoveValue = 0});

  // 百分比值，0 ~ 1，然后计算Y坐标
  final double lineMoveValue;



  @override
  void paint(Canvas canvas, Size size) {
    frameSize = Size.square(width);
    // 按扫描框居中来计算，全屏尺寸与扫描框尺寸的差集 除以 2 就是扫描框的位置
    Offset diff = (size - frameSize) as Offset;
    double leftTopX = diff.dx / 2;
    double leftTopY = diff.dy / 2;
    //根据左上角的坐标和扫描框的大小可得知扫描框矩形
    var rect =
    Rect.fromLTWH(leftTopX, leftTopY, frameSize.width, frameSize.height);
    // 4个点的坐标
    Offset leftTop = rect.topLeft;
    Offset leftBottom = rect.bottomLeft;
    Offset rightTop = rect.topRight;
    Offset rightBottom = rect.bottomRight;

    //定义画笔
    Paint paint = Paint()
      ..color = Colors.white  //颜色
      ..strokeWidth = 1.0   //画笔线条宽度
      ..style = PaintingStyle.stroke; // 画笔的模式，填充还是只绘制边框
    canvas.drawRect(rect, paint);

    Paint bgPaint = Paint()
      ..color = Color(0xb0000000) //透明灰
      ..style = PaintingStyle.fill;
    //绘制罩层
    //左侧矩形
    canvas.drawRect(Rect.fromLTRB(0, 0, leftTopX, size.height), bgPaint);
    //右侧矩形
    canvas.drawRect(
      Rect.fromLTRB(rightTop.dx, 0, size.width, size.height),
      bgPaint,
    );
    //中上矩形
    canvas.drawRect(Rect.fromLTRB(leftTopX, 0, rightTop.dx, leftTopY), bgPaint);
    //中下矩形
    canvas.drawRect(
      Rect.fromLTRB(leftBottom.dx, leftBottom.dy, rightBottom.dx, size.height),
      bgPaint,
    );
    // 重新设置画笔

    paint
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round  // 解决因为线宽导致交界处不是直角的问题
      ..style = PaintingStyle.stroke;

    // 横向线条的坐标偏移
    Offset horizontalOffset = Offset(cornerLength, 0);
    // 纵向线条的坐标偏移
    Offset verticalOffset = Offset(0, cornerLength);
    // 左上角
    canvas.drawLine(leftTop, leftTop + horizontalOffset, paint);
    canvas.drawLine(leftTop, leftTop + verticalOffset, paint);
    // 左下角
    canvas.drawLine(leftBottom, leftBottom + horizontalOffset, paint);
    canvas.drawLine(leftBottom, leftBottom - verticalOffset, paint);
    // 右上角
    canvas.drawLine(rightTop, rightTop - horizontalOffset, paint);
    canvas.drawLine(rightTop, rightTop + verticalOffset, paint);
    // 右下角
    canvas.drawLine(rightBottom, rightBottom - horizontalOffset, paint);
    canvas.drawLine(rightBottom, rightBottom - verticalOffset, paint);
    //修改画笔线条宽度
    paint.strokeWidth = 2;
    // 扫描线的移动值
    var lineY = leftTopY + frameSize.height * lineMoveValue - 20;

    // 10 为线条与方框之间的间距，绘制扫描线
    var shaderRect = Rect.fromLTWH(leftTopX + 1, lineY, frameSize.width - 2, 20);
    paint.style = PaintingStyle.fill;
    paint.shader = LinearGradient(begin: Alignment.topCenter,end: Alignment.bottomCenter,colors: [Color.fromRGBO(41,97,216,0),Color.fromRGBO(41,97,216,0.9)]).createShader(shaderRect);
    canvas.drawRect(
      shaderRect,
      paint,
    );

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // 返回true 则会重新绘制，执行 paint函数，返回false 则不会重新绘制
    return true;
  }

}

