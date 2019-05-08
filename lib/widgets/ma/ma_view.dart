import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/ma/ma_value_widget.dart';
import 'package:candlesticks/widgets/ma/ma_context.dart';
import 'package:candlesticks/widgets/ma/ma_value_data.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';


class MaView extends UIAnimatedView<UIOPath, UIOPoint> {
  List<double> _sum;
  int count;
  Paint painter;
  Color color;

  MaContext maContext;

  MaView(this.count, this.color) : super(animationCount: 2) {
    this._sum = List<double>();

    painter = new Paint()
      ..color = color
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
  }

  double movingAverage(int index, int ma) {
    if ((this._sum == null) || (index + 1 < ma) ||
        (index >= this._sum.length)) {
      return null;
    }

    double last = this._sum[index];
    double before = 0;
    if (index - ma >= 0) {
      before = this._sum[index - ma];
    }

    var y = (last - before) / ma;
    return y;
  }


  @override
  UIOPoint getCandle(ExtCandleData candleData) {
    double last = 0;
    if (this._sum.length > 0) {
      last = this._sum.last;
    }
    while (this._sum.length <= candleData.index) {
      this._sum.add(last);
    }
    this._sum[candleData.index] =
        (candleData.index > 0 ? this._sum[candleData.index - 1] : 0) +
            candleData.getValue(candleData);

    var y = movingAverage(candleData.index, count);
    if (y != null) {
      var point = UIOPoint(candleData.timeMs.toDouble() +
          candleData.durationMs.toDouble() / 2.0, y, index: candleData.index);
      maContext.onMaChange(count, y, candleData.getValue(candleData));
      return point;
    }
    return null;
  }

  @override
  UIOPath getCandles() {
    return UIOPath([], painter: painter);
  }

  @override
  UIOPath getBeginAnimation(UIOPath lastAnimationUIObject, UIOPoint point) {
    var path = lastAnimationUIObject.clone();
    path.uiObjects.add(path.uiObjects.last.clone());
    return path;
  }

  @override
  UIOPath getEndAnimation(UIOPath lastAnimationUIObject, UIOPoint point) {
    var path = lastAnimationUIObject.clone();
    path.uiObjects.add(point);
    return path;
  }

  @override void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    maContext = MaContext.of(context);
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }
}

class MaWidgetState extends State<MaWidget> {

  AABBContext candlesticksContext;

  @override void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    candlesticksContext = AABBContext.of(context);
  }

  MaValueData maValueData;

  onMaChange(int count, double value, double currentValue) {
    if (maValueData == null) {
      maValueData = MaValueData();
    }
    if (count == widget.style.maStyle.shortCount) {
      maValueData = MaValueData(shortValue: value,
          middleValue: maValueData?.middleValue,
          longValue: maValueData?.longValue,
          currentValue: currentValue);
    } else if (count == widget.style.maStyle.middleCount) {
      maValueData = MaValueData(shortValue: maValueData?.shortValue,
          middleValue: value,
          longValue: maValueData?.longValue,
          currentValue: currentValue);
    } else {
      maValueData = MaValueData(shortValue: maValueData?.shortValue,
          middleValue: maValueData?.middleValue,
          longValue: value,
          currentValue: currentValue);
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = candlesticksContext?.uiCamera;
    return MaContext(
        onMaChange: onMaChange,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: widget.style.maStyle.duration,
                  state: () =>
                      MaView(
                          widget.style.maStyle.shortCount, widget.style.maStyle.shortColor),
                )
            ),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: widget.style.maStyle.duration,
                  state: () =>
                      MaView(widget.style.maStyle.middleCount,
                          widget.style.maStyle.middleColor),
                )
            ),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: widget.style.maStyle.duration,
                  state: () =>
                      MaView(widget.style.maStyle.longCount, widget.style.maStyle.longColor),
                )
            ),
            Positioned.fill(
                child: MaValueWidget(
                  maValueData: maValueData,
                  style: widget.style,
                  maType: widget.maType,
                )
            ),

          ],
        ));
  }
}


class MaWidget extends StatefulWidget {
  MaWidget({
    Key key,
    this.dataStream,
    this.style,
    this.maType,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final CandlesticksStyle style;
  final MaType maType;

  @override
  MaWidgetState createState() => MaWidgetState();
}
