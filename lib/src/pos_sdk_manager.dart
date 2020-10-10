import 'package:aft_pos_sdk/aft_pos_sdk.dart';
import 'package:commons/commons.dart';
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
  bool isChunked;
  String _networkPrinterAddress;
  int _networkPrinterPort;
  NetworkConnection _aftPosConnection;

  PosSdkManager() {
    bluetoothPrinterManager = BluetoothPrinterManager();
    mobilePosPlugin = MobilePosPlugin();
    networkPrinterManager = PrinterNetworkManager();
  }

  Future<void> initPrinters({
    String ipAddress,
    String bluetoothAddress,
    int port,
    PrinterType printerType,
    bool isChunked = true,
  }) async {
    _networkPrinterAddress = ipAddress;
    _networkPrinterPort = port;
    networkPrinterManager.selectPrinter(ipAddress, port: port);
    bluetoothPrinterManager.selectPrinter(bluetoothAddress);
    this._printerType = printerType;
    this.isChunked = isChunked;
  }

  updateIsChunked(bool isChunked) {
    this.isChunked = isChunked;
  }

  updateNetworkPrinter({@required String address, @required int port}) {
    networkPrinterManager.selectPrinter(address, port: port);
  }

  Future<void> updateBluetoothAddress({@required String address}) async {
    await bluetoothPrinterManager.selectPrinter(address);
  }

  updatePrinterType({@required PrinterType printerType}) {
    this._printerType = printerType;
  }

  Future<PosPrintResult> printViaNetwork(
      CaptureResult captureResult, String host,
      {int port = 9100}) async {
    final Ticket ticket = Ticket(PaperSize.mm80);
    ticket.image(captureResult.image);
    ticket.cut(mode: PosCutMode.partial);
    networkPrinterManager.selectPrinter(host, port: port);
    final printResult = await networkPrinterManager.printTicket(ticket);
    networkPrinterManager.selectPrinter(_networkPrinterAddress,
        port: _networkPrinterPort);
    return printResult;
  }

  Future<PosPrintResult> print(CaptureResult captureResult) async {
    switch (_printerType) {
      case PrinterType.Bluetooth:
        final Ticket ticket = Ticket(PaperSize.mm80);
        if (isChunked)
          ticket.image(captureResult.image);
        else
          ticket.imageRaster(captureResult.image);
        ticket.cut(mode: PosCutMode.partial);

        if (!bluetoothPrinterManager.isConnected())
          await bluetoothPrinterManager.connect();

        var result = await bluetoothPrinterManager.printTicket(
          ticket,
          isChunked: this.isChunked,
        );
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
      default:
        throw Exception("Printer type is not supported");
    }
  }



  Future<List<String>> openCardReader() =>
      mobilePosPlugin.openMagneticStripeCardReader();
  PcPosConfig _pcPosConfig;
  Future<void> initPcPos(PcPosConfig config) async {
    this._pcPosConfig = config;
    if (config.isEmbeded) {
      hostApp = await mobilePosPlugin.init(config);
    } else {
      _aftPosConnection =
          NetworkConnection(ip: _pcPosConfig.ip, port: _pcPosConfig.listenPort);
    }
  }

  Future<PurchaseResponse> purchase(String invoiceNumber, String amount) async {
    if (_pcPosConfig.isEmbeded) {
      return mobilePosPlugin.purchase(invoiceNumber, amount, hostApp);
    } else {
      Purchase purchase =
          PurchaseFactory.create(_pcPosConfig, _aftPosConnection)
            ..setAmount(amount)
            ..setCurrentcy(364);
      try {
        return purchase.send();
      } catch (e) {
        print(e);
      }
    }
  }
}
