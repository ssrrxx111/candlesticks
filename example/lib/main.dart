import 'package:flutter/material.dart';

import 'package:candlesticks/gudashi/k_line.dart';
import 'package:candlesticks/candlesticks.dart';
import 'dataSource.dart';

const minute = 1;

void main() async {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    dataStreamFuture = DataSource.instance.initTZB(minute);
  }

  GlobalKey<KChartsState> kChartsKey = new GlobalKey<KChartsState>();

  Future<Stream<CandleData>> getStream() async {
    return DataSource.instance.subject.stream;
  }

  Future<Stream<CandleData>> dataStreamFuture;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(children: <Widget>[
          Expanded(
              flex: 1,
              child: Row(children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    this.dataStreamFuture = getStream();
                    setState(() {

                    });
                    print(
                        '切换K线');
                  },
                )
              ])),
          Expanded(
            flex: 10,
            child: FutureBuilder<Stream<CandleData>>(
                future: dataStreamFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<Stream<CandleData>> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container();
                  }
                  return CandlesticksWidget(
                    dataStream: snapshot.data,
                    candlesticksStyle: CandlesticksStyle(
                      backgroundColor: Color(0xff21232e),
                      cameraDuration: Duration(milliseconds: 500),
                      viewPortX: 40,
                      durationMs: 1000 * 60 * minute,
                      candlesStyle: CandlesStyle(
                          positiveColor: Colors.redAccent,
                          negativeColor: Colors.greenAccent,
                          paddingX: 0.5,
                          duration: Duration(milliseconds: 200)),
                      maStyle: MaStyle(
                          shortCount: 5,
                          maShort: Colors.yellowAccent,
                          middleCount: 15,
                          maMiddle: Colors.greenAccent,
                          longCount: 30,
                          maLong: Colors.deepPurpleAccent,
                          duration: Duration(milliseconds: 200)),
                    ),
                  );
                }),
          ),
          /*
                    Expanded(
                        flex: 1,
                        child: KCharts(
                            key: kChartsKey,
                            data: data,
                        ),
                    ),
                    */
        ]
        ),)
      ,
    );
  }
}
