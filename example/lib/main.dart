import 'dart:typed_data';
import 'package:image/image.dart' as image;

import 'package:charset_converter/charset_converter.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:pos_sdk/pos_sdk.dart';
import 'package:mobile_pos_plugin/mobile_pos_plugin.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  BluetoothPrinterManager printerManager;
  BluetoothDiscoveryManager discoveryManager = BluetoothDiscoveryManager();
  List<PrinterBluetooth> _devices = [];
  MobilePosPlugin mobilePosPlugin;

  @override
  void initState() {
    super.initState();
    mobilePosPlugin = MobilePosPlugin();
    discoveryManager.scanResults.listen((devices) async {
      // print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    discoveryManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    discoveryManager.stopScan();
  }

  void _testPrint(PrinterBluetooth printer) async {
    // TODO Don't forget to choose printer's paper
    const PaperSize paper = PaperSize.mm80;

    // TEST PRINT
    // final PosPrintResult res =
    // await printerManager.printTicket(await testTicket(paper));

    final captureResult =
        await OffScreenCaptureWidget.of(context).captureImage();

    var test = await testTicket();

    test.image(captureResult.image);
    // test.imageRaster(image);
    test.cut();
    // DEMO RECEIPT
    //final res = await printerManager.printTicket(test,chunkSizeBytes: 50,queueSleepTimeMs: 0);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return OffScreenCaptureWidget(
        capture: Material(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'عنوان',
                  style: Theme.of(context).textTheme.title,
                ),
                Container(
                  child: Table(
                    border: TableBorder.all(color: Colors.black),
                    children: [
                      TableRow(children: [
                        Text('فراموشی '),
                        Text('Cell 2'),
                        Text('Cell 3'),
                      ]),
                      TableRow(children: [
                        Text('Cell 4'),
                        Text('Cell 5'),
                        Text('Cell 6'),
                      ]),
                      TableRow(children: [
                        Text('Cell 4'),
                        Text('Cell 5'),
                        Text('Cell 6'),
                      ]),
                      TableRow(children: [
                        Text('Cell 4'),
                        Text('Cell 5'),
                        Text('Cell 6'),
                      ]),
                      TableRow(children: [
                        Text('Cell 4'),
                        Text('Cell 5'),
                        Text('Cell 6'),
                      ]),
                      TableRow(children: [
                        Text('Cell 4'),
                        Text('Cell 5'),
                        Text('Cell 6'),
                      ]),
                      TableRow(children: [
                        Text('Cell 4'),
                        Text('Cell 5'),
                        Text('Cell 6'),
                      ]),
                      TableRow(children: [
                        Text('Cell 4'),
                        Text('Cell 5'),
                        Text('Cell 6'),
                      ])
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Column(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    final captureResult =
                        await OffScreenCaptureWidget.of(context).captureImage(width: PaperSize.mm80.width);

                    await mobilePosPlugin.init();

                    //  final img = copyResize(image, width: 500, height: image.height);

                    mobilePosPlugin.print(captureResult.data, (data) {
                      print(data);
                    });
                  },
                  child: Text('print via default termal printer'),
                ),
                RaisedButton(
                  onPressed: () async {
                    final captureResult =
                        await OffScreenCaptureWidget.of(context).captureImage(width: PaperSize.mm58.width);

                    var test = await testTicket();
      
                    test.image(captureResult.image);
                    // test.imageRaster(image);
                    test.cut();
                    printerManager.printTicket(test,
                        chunkSizeBytes: 50, queueSleepTimeMs: 0);
                  },
                  child: Text('print via selected bluetoothDevice'),
                ),
                RaisedButton(
                  onPressed: () async {
                    final PrinterNetworkManager netPrinterManager =
                        PrinterNetworkManager();
                    netPrinterManager.selectPrinter('192.168.1.108',
                        port: 9100);
                    final captureResult =
                        await OffScreenCaptureWidget.of(context).captureImage(width: PaperSize.mm80.width);

                    var test = await testTicket();

                    test.image(captureResult.image);
                    // test.imageRaster(image);
                    test.cut(mode: PosCutMode.partial);
                    final resutl = await netPrinterManager.printTicket(test);
                    print(resutl);
                  },
                  child: Text('print via wifi'),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () async {
                            printerManager = BluetoothPrinterManager(
                                address: _devices[index].address);
                            await printerManager.connect();
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 60,
                                padding: EdgeInsets.only(left: 10),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.print),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(_devices[index].name ?? ''),
                                          Text(_devices[index].address),
                                          Text(
                                            'Click to print a test receipt',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
            floatingActionButton: StreamBuilder<bool>(
              stream: discoveryManager.isScanningStream,
              initialData: false,
              builder: (c, snapshot) {
                if (snapshot.data) {
                  return FloatingActionButton(
                    child: Icon(Icons.stop),
                    onPressed: _stopScanDevices,
                    backgroundColor: Colors.red,
                  );
                } else {
                  return FloatingActionButton(
                    child: Icon(Icons.search),
                    onPressed: _startScanDevices,
                  );
                }
              },
            ),
          ),
        ));
  }

  Future<Ticket> testTicket() async {
    final Ticket ticket = Ticket(PaperSize.mm80);

    /// Arabic
    /// Possible charsets for CharsetConverter.encode: cp864, windows-1256
    /// Possible codeTables for PosStyles: arabic, pc864_1, pc864_2, pc1001_1, pc1001_2, wp1256, pc720
    Uint8List encArabic =
        await CharsetConverter.encode("windows-1256", "سلام علیکم");
    // ticket.textEncoded(encArabic,
    //     styles: PosStyles(codeTable: PosCodeTable.iran1));

    return ticket;
  }
}
