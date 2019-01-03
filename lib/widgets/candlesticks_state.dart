import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:candlesticks/widgets/candlesticks_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/treedlist.dart';
import 'package:candlesticks/2d/candle_data.dart';

const ZERO = 0.00000001;
//const countMax = 128;
const countMax = 16;
const countMin = 16;

abstract class CandlesticksState extends State<CandlesticksWidget>
    with TickerProviderStateMixin {
//    UICamera uiCamera;
    List<CandleData> initData;
    Stream<CandleData> dataStream;

    AnimationController uiCameraAnimationController;
    Animation<UICamera> uiCameraAnimation;

    TreedListMin<double> candlesMaxY = TreedListMin(null, reverse: -1);
    TreedListMin<double> candlesMinY = TreedListMin(null);

    List<double> candlesX = List<double>();


    CandlesticksState({List<CandleData> initData, Stream<CandleData> dataStream})
        : super() {
        this.initData = initData;
        this.dataStream = dataStream;

        initData.forEach((CandleData p) {
            var uio = UIOCandle.fromData(p, 0, null);
            var aabb = uio.aabb();
            this.candlesMaxY.add(max(aabb.max.y, aabb.min.y));
            this.candlesMinY.add(min(aabb.max.y, aabb.min.y));
            this.candlesX.add(aabb.min.x);
        });

        var viewPort = calViewPort(
            candlesMinY.length - countMax, candlesMaxY.length - 1);
        var uiCamera = UICamera(viewPort);
        uiCameraAnimationController = AnimationController(
            duration: const Duration(milliseconds: 500), vsync: this);
        uiCameraAnimation = Tween(begin: uiCamera, end: uiCamera).animate(
            uiCameraAnimationController);
    }

    UIORect calViewPort(int from, int to) {
        if (this.candlesX.length <= 0) {
            return UIORect(UIOPoint(0, 0), UIOPoint(0, 0));
        }

        if (from < 0) {
            from = 0;
        }
        if (to > this.candlesX.length) {
            to = this.candlesX.length - 1;
        }
        var minY = this.candlesMinY.min(from, to);
        if (minY == null) {
            minY = 0;
        }
        var maxY = this.candlesMaxY.min(from, to);
        if (maxY == null) {
            maxY = 0;
        }
        var durationMs = 60 * 1000;
        if (from < 0) {
            return null;
        }
        var minX = this.candlesX[from];
        var maxX = this.candlesX[to] + durationMs;
        return UIORect(UIOPoint(minX, minY), UIOPoint(maxX, maxY));
    }

    void onCandleUpdate(int index, UIOCandle candle) {
        var aabb = candle.aabb();
        if (index >= this.candlesX.length) {
            this.candlesMaxY.add(max(aabb.max.y, aabb.min.y));
            this.candlesMinY.add(min(aabb.max.y, aabb.min.y));
            this.candlesX.add(aabb.min.x);
        }
        this.candlesMaxY.update(index, max(aabb.max.y, aabb.min.y));
        this.candlesMinY.update(index, min(aabb.max.y, aabb.min.y));

        var uiCamera = uiCameraAnimation.value;
        if (uiCamera.viewPort.cross(candle.aabb())) {
            var viewPort = calViewPort(index - countMax, index);
            var uiCamera = UICamera(viewPort);
            uiCameraAnimation =
                Tween(begin: uiCameraAnimation.value.clone(), end: uiCamera)
                    .animate(uiCameraAnimationController);
            uiCameraAnimationController.reset();
            uiCameraAnimationController.forward();
        }
    }

    void onMaUpdate(int index, UIOPoint point) {
        if(this.candlesX == null) {
            return;
        }
        for (index = this.candlesX.length - 1; (index >= 0) &&
            (point.x < this.candlesX[index]); index--) {

        }
        if(index < 0) {
            return;
        }

        var aabb = point.aabb();
        if (index >= this.candlesX.length) {
            this.candlesMaxY.add(max(aabb.max.y, aabb.min.y));
            this.candlesMinY.add(min(aabb.max.y, aabb.min.y));
            this.candlesX.add(aabb.min.x);
            return;
        }
        this.candlesMaxY.update(index, point.y);
        this.candlesMinY.update(index, point.y);
    }

    void onHorizontalDragEnd(DragEndDetails details) {
        return;
        //区间的最大值， 最小值。
        var uiCamera = uiCameraAnimation.value;
        var baseX = this.candlesX.first;
        var startIndex = (uiCamera.viewPort
            .aabb()
            .min
            .x - baseX) ~/ (60 * 1000);
        var endIndex = (uiCamera.viewPort
            .aabb()
            .max
            .x - baseX) ~/ (60 * 1000);

        var viewPort = calViewPort(startIndex, endIndex);
        print("{${viewPort.min.x}, ${viewPort.min.y}} {${viewPort.max
            .x}, ${viewPort.max.y}}");
        var newUICamera = UICamera(viewPort);
        uiCameraAnimation =
            Tween(begin: uiCamera, end: newUICamera)
                .animate(uiCameraAnimationController);
        uiCameraAnimationController.reset();
        uiCameraAnimationController.forward();
    }

    void onHorizontalDragUpdate(DragUpdateDetails details) {
        var dr = details.primaryDelta / context.size.width;
        var dx = uiCameraAnimation.value.viewPort.width * dr;
        var uiCamera = uiCameraAnimation.value;
        var minX = uiCamera.viewPort.min.x;
        var maxX = uiCamera.viewPort.max.x;
        minX -= dx;
        maxX -= dx;

        var baseX = this.candlesX.first;
        var startIndex = (minX - baseX) ~/ (60 * 1000);
        var endIndex = (maxX - baseX) ~/ (60 * 1000);
        var minY = this.candlesMinY.min(startIndex, endIndex);
        if (minY == null) {
            minY = 0;
        }
        var maxY = this.candlesMaxY.min(startIndex, endIndex);
        if (maxY == null) {
            maxY = 0;
        }

        var newCamera = UICamera(
            UIORect(UIOPoint(minX, minY), UIOPoint(maxX, maxY)));

        uiCameraAnimationController.reset();
        uiCameraAnimation =
            Tween(begin: newCamera, end: newCamera).animate(
                uiCameraAnimationController);
        setState(() {

        });
    }


    @override
    void initState() {
        // TODO: implement initState
        super.initState(); //插入监听器
    }

    @override
    void deactivate() {
        // TODO: implement deactivate
        super.deactivate();
    }

    @override
    void dispose() {
        super.dispose(); //删除监听器
    }
}
