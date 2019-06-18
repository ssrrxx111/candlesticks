import 'package:candlesticks/widgets/kdj/kdj_style.dart';
import 'package:candlesticks/widgets/macd/macd_style.dart';
import 'package:candlesticks/widgets/mh/mh_style.dart';
import 'package:candlesticks/widgets/rsi/rsi_style.dart';
import 'package:candlesticks/widgets/wr/wr_style.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';
import 'package:candlesticks/widgets/candles/candles_style.dart';
import 'package:candlesticks/widgets/floating/floating_style.dart';

CandlesticksStyle DefaultDarkCandleStyle = CandlesticksStyle(
  backgroundColor: Color(0xFF060827),
  cameraDuration: Duration(milliseconds: 500),
  initAfterNData: 1,
  defaultViewPortX: 50,
  minViewPortX: 20,
  maxViewPortX: 256,
  fractionDigits: 8,
  lineColor: Colors.white.withOpacity(0.2),
  nX: 5,
  nY: 4,
  floatingStyle: FloatingStyle(
    backGroundColor: Colors.black.withOpacity(0.8),
    frontSize: 10,
    borderColor: Colors.white,
    frontColor: Colors.white,
    crossColor: Colors.white,
  ),
  candlesStyle: CandlesStyle(
      positiveColor: Colors.redAccent,
      negativeColor: Colors.greenAccent,
      paddingX: 0.5,
      cameraPaddingY: 0.1,
      duration: Duration(milliseconds: 200)),
  maStyle: MaStyle(
      currentColor: Colors.white.withOpacity(0.85),
      cameraPaddingY: 0.2,
      shortCount: 5,
      shortColor: Colors.yellowAccent,
      middleCount: 15,
      middleColor: Colors.greenAccent,
      longCount: 30,
      longColor: Colors.deepPurpleAccent,
      duration: Duration(milliseconds: 200)),
  mhStyle: defaultMHStyle,
  rsiStyle: defaultRsiStyle,
  wrStyle: defaultWrStyle,
  kdjStyle: defaultKdjStyle,
  macdStyle: defaultMacdStyle,

);

CandlesticksStyle DefaultLightCandleStyle = CandlesticksStyle(
  backgroundColor: Color(0xffffffff),
  cameraDuration: Duration(milliseconds: 500),
  initAfterNData: 1,
  defaultViewPortX: 50,
  minViewPortX: 20,
  maxViewPortX: 256,
  fractionDigits: 8,
  lineColor: Colors.white.withOpacity(0.2),
  nX: 5,
  nY: 4,
  floatingStyle: FloatingStyle(
    backGroundColor: Colors.black.withOpacity(0.8),
    frontSize: 10,
    borderColor: Colors.white,
    frontColor: Colors.white,
    crossColor: Colors.white,
  ),
  candlesStyle: CandlesStyle(
      positiveColor: Colors.redAccent,
      negativeColor: Colors.greenAccent,
      paddingX: 0.5,
      cameraPaddingY: 0.1,
      duration: Duration(milliseconds: 200)),
  maStyle: MaStyle(
      currentColor: Colors.white.withOpacity(0.85),
      cameraPaddingY: 0.2,
      shortCount: 5,
      shortColor: Colors.yellowAccent,
      middleCount: 15,
      middleColor: Colors.greenAccent,
      longCount: 30,
      longColor: Colors.deepPurpleAccent,
      duration: Duration(milliseconds: 200)),
  mhStyle: defaultMHStyle,
  rsiStyle: defaultRsiStyle,
  wrStyle: defaultWrStyle,
  kdjStyle: defaultKdjStyle,
  macdStyle: defaultMacdStyle,
);

class CandlesticksStyle {
  final Duration cameraDuration;
  final int initAfterNData;
  final int defaultViewPortX;
  final int minViewPortX;
  final int maxViewPortX;
  final Color backgroundColor;
  final Color lineColor;
  final double durationMs; //k线时间间隔
  //标线
  final int fractionDigits;
  final double paddingY;
  final int nX;
  final int nY;

  final FloatingStyle floatingStyle;
  final CandlesStyle candlesStyle;
  final MaStyle maStyle;
  final MHStyle mhStyle;
  final RsiStyle rsiStyle;
  final WrStyle wrStyle;
  final KdjStyle kdjStyle;
  final MacdStyle macdStyle;

  final double middleHeight;
  final double bottomHeight;

  CandlesticksStyle({this.minViewPortX,
    this.maxViewPortX,
    this.floatingStyle,
    this.lineColor,
    this.candlesStyle,
    this.maStyle,
    this.mhStyle,
    this.rsiStyle,
    this.wrStyle,
    this.kdjStyle,
    this.macdStyle,
    this.cameraDuration,
    this.initAfterNData,
    this.backgroundColor,
    this.defaultViewPortX,
    this.fractionDigits,
    this.paddingY,
    this.nX,
    this.nY,
    this.durationMs,
    this.middleHeight,
    this.bottomHeight});
}
