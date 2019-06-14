import 'package:candlesticks/widgets/bottom/BottomWidget.dart';
import 'package:candlesticks/widgets/floating/vertical_line_floating_widget.dart';
import 'package:candlesticks/widgets/graticule/time_graticule_widget.dart';
import 'package:candlesticks/widgets/indicator_switch.dart';
import 'package:candlesticks/widgets/line_type.dart';
import 'package:candlesticks/widgets/mh/mh_middle_widget.dart';
import 'package:candlesticks/widgets/mh/mh_top_widget.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/candlesticks_state.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_widget.dart';
import 'package:candlesticks/widgets/top/top_widget.dart';
import 'package:candlesticks/widgets/middle/middle_widget.dart';

class CandlesticksView extends CandlesticksState {
  CandlesticksView({Stream<CandleData> dataStream})
      : super(dataStream: dataStream);

  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (isWaitingForInitData()) {
      isShowingEmptyPage = true;
      return Container(
          /*
        child: Center(
          child: CircularProgressIndicator(),
        ),
        */
          );
    }

    return GestureDetector(
      onHorizontalDragStart: (x) {
        touching = true;
      },
//      onVerticalDragCancel: () {
//        touching = false;
//      },
      onHorizontalDragEnd: onHorizontalDragEnd,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragCancel: () {
        print('srx onHorizontalDragCancel');
      },
      onHorizontalDragDown: (detail) {
        print('srx onHorizontalDragDown');
      },

      onScaleUpdate: onScaleUpdate,
      onScaleStart: handleScaleStart,

      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onLongPress: onLongPress,


      child: AnimatedBuilder(
          animation: Listenable.merge([
            uiCameraAnimation,
          ]),
          builder: (BuildContext context, Widget child) {
            return CandlesticksContext(
              key: globalKey,
              onCandleDataFinish: onCandleDataFinish,
              candlesX: candlesX,
              extCandleData: extCandleData,
              touchPoint: touchPoint,
              touching: touching,
              lastCandleData: (candleDataList != null && candleDataList.isNotEmpty)
                  ? candleDataList[candleDataList.length - 1]
                  : null,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: widget.lineType == LineType.k_line
                              ? _buildKLine()
                              : _buildMhLine(),
                        ),
                        Positioned.fill(
                          child: AABBWidget(
                            extDataStream: exdataStream,
                            durationMs: durationMs,
                            rangeX: uiCameraAnimation?.value,
                            candlesticksStyle: widget.candlesticksStyle,
                            paddingY:
                                widget.candlesticksStyle.candlesStyle.cameraPaddingY,
                            child: VerticalLineFloatingWidget(
                              style: widget.candlesticksStyle,
                              extCandleData: extCandleData,
                              touchPoint: touchPoint,
                              durationMs: widget.durationMs,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: widget.candlesticksStyle.backgroundColor),
                    width: MediaQuery.of(context).size.width,
                    height: 12,
                    child: AABBWidget(
                      extDataStream: exdataStream,
                      durationMs: durationMs,
                      rangeX: uiCameraAnimation?.value,
                      candlesticksStyle: widget.candlesticksStyle,
                      paddingY:
                      widget.candlesticksStyle.candlesStyle.cameraPaddingY,
                      child: TimeGraticuleWidget(
                        candlesticksStyle: widget.candlesticksStyle,
                        paddingY: 0.1,
                        touchPoint:touchPoint,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildKLine() {
    return Column(children: <Widget>[
      Expanded(
          flex: 60,
          child: TopWidget(
            durationMs: durationMs,
            rangeX: uiCameraAnimation?.value,
            candlesticksStyle: widget.candlesticksStyle,
            extDataStream: exdataStream,
          )),
      Container(
          height: widget.candlesticksStyle.middleHeight ?? 70,
          child: MiddleWidget(
            durationMs: durationMs,
            rangeX: uiCameraAnimation?.value,
            candlesticksStyle: widget.candlesticksStyle,
            extDataStream: exdataStream,
          )),
      Visibility(
        visible: defaultIndicatorSwitch.subSwitch,
        maintainState: true,
        child: Container(
          height: widget.candlesticksStyle.bottomHeight ?? 70,
          child: BottomWidget(
            durationMs: durationMs,
            rangeX: uiCameraAnimation?.value,
            candlesticksStyle: widget.candlesticksStyle,
            extDataStream: exdataStream,
          ),
        ),
      ),
    ]);
  }

  Widget _buildMhLine() {
    return Column(children: <Widget>[
      Expanded(
          flex: 60,
          child: MHTopWidget(
            durationMs: durationMs,
            rangeX: uiCameraAnimation?.value,
            candlesticksStyle: widget.candlesticksStyle,
            extDataStream: exdataStream,
          )),
      Container(
          height: widget.candlesticksStyle.middleHeight ?? 70,
          child: MhMiddleWidget(
            durationMs: durationMs,
            rangeX: uiCameraAnimation?.value,
            candlesticksStyle: widget.candlesticksStyle,
            extDataStream: exdataStream,
          )),
      Visibility(
        visible: defaultIndicatorSwitch.subSwitch,
        maintainState: true,
        child: Container(
          height: widget.candlesticksStyle.bottomHeight ?? 70,
          child: BottomWidget(
            durationMs: durationMs,
            rangeX: uiCameraAnimation?.value,
            candlesticksStyle: widget.candlesticksStyle,
            extDataStream: exdataStream,
          ),
        ),
      ),
    ]);
  }
}
