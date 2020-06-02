import 'package:esc_pos_blue/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:pos_sdk/src/widgets/bluetooth_device_widget.dart';

class BlutoothDiscoveryScreen extends StatefulWidget {
  final OnSelect onSelect;
  BlutoothDiscoveryScreen({
    Key key,
    @required this.onSelect,
  })  : assert(onSelect != null),
        super(key: key);

  @override
  _BlutoothDiscoveryScreenState createState() =>
      _BlutoothDiscoveryScreenState();
}

class _BlutoothDiscoveryScreenState extends State<BlutoothDiscoveryScreen> {
  List<PrinterBluetooth> _devices = [];
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
          body: StreamBuilder<List<PrinterBluetooth>>(
            initialData: [],
            stream:  _discoveryManager.scanResults,
            builder: (context, snapshot) {
              return ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (BuildContext context, int index) => BluetoothDeviceWidget(
              device: _devices[index],
              onSelect: widget.onSelect,
        ),
      );
            }
          ));
}
