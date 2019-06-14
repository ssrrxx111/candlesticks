import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:candlesticks/candlesticks.dart';

const BASE_URL = "wss://market-api.dxb.com/sub";

class DataSource {
  static DataSource get instance => _getInstance();

  factory DataSource() => _getInstance();

  static DataSource _instance;
  DataSource._internal();
  static DataSource _getInstance() {
    if (_instance == null) {
      _instance = DataSource._internal();
    }
    return _instance;
  }

  ReplaySubject<CandleData> tickerInfoSubject;

  IOWebSocketChannel socketChannel;

  Future<ReplaySubject<CandleData>> initTZB(int minute) async {
    if (tickerInfoSubject != null) {
      tickerInfoSubject.close();
      tickerInfoSubject = null;
    }
    tickerInfoSubject = ReplaySubject<CandleData>();
    var symbol = "eth_usdt";
    if (socketChannel != null) {
      socketChannel.sink.close();
      socketChannel = null;
    }

    socketChannel = IOWebSocketChannel.connect("wss://ws.tokenbinary.io/sub");
    /*
        channel.sink.add(
            '{"method":"pull_heart","data":{"time":"1541066934853"}}');
            */
    socketChannel.sink
        .add('{"method":"pull_gamble_user_market","data":{"market":"${symbol}","gamble":true}}');
    socketChannel.sink.add(
        '{"method":"pull_gamble_kline_graph","data":{"market":"${symbol}","k_line_type":"${minute}","k_line_count":"500"}}');

    socketChannel.stream.listen((request) {
      var msg = json.decode(utf8.decode(request));
      int now = DateTime.now().millisecond;
      socketChannel.sink.add('{"method":"pull_heart","data":{"time":"${now}"}}');
      if (msg['method'] == 'push_gamble_kline_graph') {
        //print(msg['data']);
        List dataK = [];
        msg['data'].forEach((item) {
          var d = {};
          try {
            d['time'] = int.parse(item[0]);
            d['open'] = double.parse(item[1]);
            d['high'] = double.parse(item[2]);
            d['low'] = double.parse(item[3]);
            d['close'] = double.parse(item[4]);
            d['volume'] = double.parse(item[5]);
            d['virgin'] = item;
          } catch (e) {
            //print(e);
          }

          tickerInfoSubject.add(CandleData.fromArray(item));
        });
      }
    });
    return tickerInfoSubject.stream;
  }

  Future<ReplaySubject<CandleData>> initRBTC(int minute) async {
    if (tickerInfoSubject != null) {
      tickerInfoSubject.close();
      tickerInfoSubject = null;
    }
    tickerInfoSubject = ReplaySubject<CandleData>();
    if (socketChannel != null) {
      socketChannel.sink.close();
      socketChannel = null;
    }

    var symbol = "btc_usdt";

    socketChannel = IOWebSocketChannel.connect(BASE_URL);
    socketChannel.sink.add('{"method":"pull_heart","data":{"time":"1541066934853"}}');
    socketChannel.sink.add('{"method":"pull_user_market","data":{"market":"${symbol}"}}');
    socketChannel.sink.add(
        '{"method":"pull_kline_graph","data":{"market":"${symbol}","k_line_type":"${minute}","k_line_count":"80"}}');

    socketChannel.stream.listen((request) {
      var msg = json.decode(utf8.decode(request));
      if (msg['method'] == 'push_kline_graph') {
        //print(msg['data']);
        List dataK = [];
        msg['data'].forEach((item) {
          var d = {};
          try {
            d['time'] = int.parse(item[0]);
            d['open'] = double.parse(item[1]);
            d['high'] = double.parse(item[2]);
            d['low'] = double.parse(item[3]);
            d['close'] = double.parse(item[4]);
            d['volume'] = double.parse(item[5]);
            d['virgin'] = item;
          } catch (e) {
            //print(e);
          }

          dataK.add(d);
          if (dataK.length >= 2) {
//            print(dataK.last['time'] - dataK[dataK.length - 2]['time']);
          }
          tickerInfoSubject.add(CandleData.fromArray(item));
        });
//        kChartsKey.currentState.data = data;
//                print('pull_kline_graph');
//        kChartsKey.currentState.init();
//                channel.sink.close(5678, "raisin");
      }
    });
    return tickerInfoSubject;
  }
}
