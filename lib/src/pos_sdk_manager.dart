import 'package:esc_pos_blue/esc_pos_bluetooth.dart' hide PosPrintResult;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_pos_plugin/mobile_pos_plugin.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:pos_sdk/src/models/capture_result.dart';
import 'package:pos_sdk/src/models/printer_type.dart';

class PosSdkManager {
  BluetoothPrinterManager bluetoothPrinterManager;
  MobilePosPlugin mobilePosPlugin;
  PrinterNetworkManager networkPrinterManager;
  PrinterType _printerType;
  HostApp hostApp;

  PosSdkManager() {
    bluetoothPrinterManager = BluetoothPrinterManager();
    mobilePosPlugin = MobilePosPlugin();
    networkPrinterManager = PrinterNetworkManager();
  }

  Future<void> init(
      {String ipAddress,
      String bluetoothAddress,
      int port,
      PrinterType printerType}) async {
    networkPrinterManager.selectPrinter(ipAddress, port: port);
    bluetoothPrinterManager.selectPrinter(bluetoothAddress);
    hostApp = await mobilePosPlugin.init();
    this._printerType = printerType;
  }

  updateNetworkPrinter({@required String address, @required int port}) {
    networkPrinterManager.selectPrinter(address, port: port);
  }

  updateBluetoothAddress({@required String address}) {
    bluetoothPrinterManager.selectPrinter(address);
  }

  updatePrinterType({@required PrinterType printerType}) {
    this._printerType = printerType;
  }

  Future<PosPrintResult> print(CaptureResult captureResult) async {
    switch (_printerType) {
      case PrinterType.Bluetooth:
        final Ticket ticket = Ticket(PaperSize.mm80);
        ticket.image(captureResult.image);
        ticket.cut(mode: PosCutMode.partial);
        var result = await bluetoothPrinterManager.printTicket(ticket);
        //todo : refactor
        return PosPrintResult.success;
        break;
      case PrinterType.Network:
        final Ticket ticket = Ticket(PaperSize.mm80);
        ticket.image(captureResult.image);
        ticket.cut(mode: PosCutMode.partial);
        return networkPrinterManager.printTicket(ticket);
        break;
      case PrinterType.Embedded:
        final status = await mobilePosPlugin.getPrinterStatus();
        final result = await mobilePosPlugin.printAsync(captureResult.data);
        return PosPrintResult.success;
        break;
    }
  }

  Future<List<String>> openCardReader() =>
      mobilePosPlugin.openMagneticStripeCardReader();
}
