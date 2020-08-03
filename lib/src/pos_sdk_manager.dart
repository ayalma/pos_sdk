import 'package:aft_pos_sdk/aft_pos_sdk.dart';
import 'package:esc_pos_blue/esc_pos_bluetooth.dart' hide PosPrintResult;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_pos_plugin/mobile_pos_plugin.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:pos_sdk/src/models/aft_pos_type.dart';
import 'package:pos_sdk/src/models/capture_result.dart';
import 'package:pos_sdk/src/models/printer_type.dart';

class PosSdkManager {
  BluetoothPrinterManager bluetoothPrinterManager;
  MobilePosPlugin mobilePosPlugin;
  PrinterNetworkManager networkPrinterManager;
  PrinterType _printerType;
  AftPosType _aftPosType;
  HostApp hostApp;
  bool isChunked;
  String _networkPrinterAddress;
  int _networkPrinterPort;
  AftPosConnection _aftPosConnection;

  PosSdkManager() {
    bluetoothPrinterManager = BluetoothPrinterManager();
    mobilePosPlugin = MobilePosPlugin();
    networkPrinterManager = PrinterNetworkManager();
  }

  Future<void> init({
    String ipAddress,
    String bluetoothAddress,
    int port,
    PrinterType printerType,
    bool isChunked = true,
    SdkType sdkType,
    AftPosType aftPosType,
    String aftPosIp,
    int aftPosPort,
  }) async {
    _networkPrinterAddress = ipAddress;
    _networkPrinterPort = port;
    networkPrinterManager.selectPrinter(ipAddress, port: port);
    bluetoothPrinterManager.selectPrinter(bluetoothAddress);
    hostApp = await mobilePosPlugin.init(sdkType);
    _aftPosConnection = AftPosConnection(ip: aftPosIp, port: aftPosPort);
    this._aftPosType = aftPosType;
    this._printerType = printerType;
    this.isChunked = isChunked;
  }

  updateAftPosIpAndPort(String aftPosIp, int aftPosPort) {
    _aftPosConnection = AftPosConnection(ip: aftPosIp, port: aftPosPort);
  }

  updateAftPosType(AftPosType aftPosType) {
    _aftPosType = aftPosType;
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

  updateSdkType({@required SdkType sdkType}) {
    mobilePosPlugin.init(sdkType);
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
    }
  }

  Future<List<String>> openCardReader() =>
      mobilePosPlugin.openMagneticStripeCardReader();

  Future<PosResponse> purchase(String invoiceNumber, String amount) async {
    if (_aftPosType == AftPosType.Embedded) {
      mobilePosPlugin.purchase(invoiceNumber, amount, hostApp);
    } else {
      await _aftPosConnection.connect();
      BTLV btlv = new BTLV();
      btlv.addTagValue(Tag.PR, "000000");
      btlv.addTagValue(Tag.AM, amount);
      btlv.addTagValue(Tag.CU, "364");
      btlv.addTagValue(Tag.T1, "");
      btlv.addTagValue(Tag.R1, "");
      btlv.addTagValue(Tag.T2, "");
      btlv.addTagValue(Tag.R2, "");
      btlv.addTagValue(Tag.SV, "");
      btlv.addTagValue(Tag.SG, "");
      btlv.addTagValue(Tag.ST, "1=1002=200");
      btlv.addTagValue(Tag.AV, "ID1=1000ID2=2000");

      var result = await _aftPosConnection.sendRequest(btlv);

      //await _aftPosConnection.response
      await _aftPosConnection.dispose();
    }
  }
}
