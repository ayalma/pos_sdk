import 'package:flutter/material.dart';
import 'package:pos_sdk/pos_sdk.dart';
import 'package:mobile_pos_plugin/mobile_pos_plugin.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PosSdkManager _posSdkManager = PosSdkManager();
  await _posSdkManager.init(
      sdkType: SdkType.Rahyab,
      ipAddress: '192.168.1.1010',
      port: 92100,
      isChunked: true,
      aftPosIp: '192.168.1.241',
      aftPosPort: 1010,
      aftPosType: AftPosType.Lan);

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
  @override
  Widget build(BuildContext context) {
    final PosSdkManager posSdkManager = Provider.of(context);

    posSdkManager.purchase("", "90000");
    return Scaffold(
      appBar: AppBar(
        title: Text('Sdk manager test app'),
      ),
      body: SingleChildScrollView(child: Column()),
    );
  }
}
