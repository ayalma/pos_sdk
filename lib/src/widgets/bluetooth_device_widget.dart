import 'package:esc_pos_blue/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';

typedef OnSelect = void Function(PrinterBluetooth);

class BluetoothDeviceWidget extends StatelessWidget {
  final PrinterBluetooth device;
  final OnSelect onSelect;
  const BluetoothDeviceWidget({
    Key key,
    @required this.device,
    @required this.onSelect,
  })  : assert(device != null),
        assert(device != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelect(device),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(device.name ?? ''),
                      Text(device.address),
                      Text(
                        device.type.stringValue,
                        style: TextStyle(color: Colors.grey[700]),
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
  }
}
