import 'package:esc_pos_blue/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:pos_sdk/src/widgets/bluetooth_device_widget.dart';

class BlutoothDiscoveryScreen extends StatefulWidget {
  static const route = 'bluetooth_discovery_state';
  final OnSelect onSelect;
  final String title;
  final String searchTitle;
  final String stopTitle;
  BlutoothDiscoveryScreen({
    Key key,
    @required this.onSelect,
    @required this.title,
    @required this.searchTitle,
    @required this.stopTitle,
  })  : assert(onSelect != null),
        assert(title != null),
        assert(searchTitle != null),
        assert(stopTitle != null),
        super(key: key);

  @override
  _BlutoothDiscoveryScreenState createState() =>
      _BlutoothDiscoveryScreenState();
}

class _BlutoothDiscoveryScreenState extends State<BlutoothDiscoveryScreen> {

  BluetoothDiscoveryManager _discoveryManager = BluetoothDiscoveryManager();

  @override
  void initState() {
    _startScanDevices();
    super.initState();
  }

  @override
  void dispose() {
    _discoveryManager.stopScan();
    _discoveryManager.dispose();
    super.dispose();
  }

  void _startScanDevices() {
    _discoveryManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    _discoveryManager.stopScan();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: StreamBuilder<bool>(
          initialData: false,
          stream: _discoveryManager.isScanningStream,
          builder: (context, snapshot) {
            bool isScanning = snapshot.data;
            return FloatingActionButton.extended(
              icon: Icon(isScanning ? Icons.stop : Icons.search),
              onPressed: () {
                isScanning ? _stopScanDevices() : _startScanDevices();
              },
              label: Text(
                isScanning ? widget.stopTitle : widget.searchTitle,
              ),
            );
          }),
      body: StreamBuilder<List<PrinterBluetooth>>(
          initialData: [],
          stream: _discoveryManager.scanResults,
          builder: (context, snapshot) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) =>
                  BluetoothDeviceWidget(
                device: snapshot.data[index],
                onSelect: widget.onSelect,
              ),
            );
          }));
}
