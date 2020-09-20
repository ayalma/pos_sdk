import 'package:flutter/material.dart';
import 'package:pos_sdk/pos_sdk.dart';
import 'package:mobile_pos_plugin/mobile_pos_plugin.dart';
import 'package:provider/provider.dart';
import 'package:commons/commons.dart';
import 'package:aft_pos_sdk/aft_pos_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PosSdkManager _posSdkManager = PosSdkManager();
  await _posSdkManager.initPrinters(
    ipAddress: '192.168.1.1010',
    port: 92100,
    isChunked: true,
  );

  runApp(MultiProvider(
      providers: [Provider(create: (context) => _posSdkManager)],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SdkManager Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Pos Sdk Manager Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PurchaseResponse result;
  @override
  Widget build(BuildContext context) {
    final PosSdkManager posSdkManager = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sdk manager test app'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          RaisedButton.icon(
              onPressed: () {
                posSdkManager.purchase("", "1000").then(
                      (value) => setState(
                        () {
                          print(value);
                          result = value;
                        },
                      ),
                    );
              },
              icon: Icon(Icons.payment),
              label: Text("Make payment")),
          // Text((result as PurchaseFailed)?.bankType ?? "")
        ],
      )),
    );
  }
}
