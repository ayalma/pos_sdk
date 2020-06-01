import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';


void main() {
  Future<Ticket> testTicket() async {
    final Ticket ticket = Ticket(PaperSize.mm80);
/// Arabic
/// Possible charsets for CharsetConverter.encode: cp864, windows-1256
/// Possible codeTables for PosStyles: arabic, pc864_1, pc864_2, pc1001_1, pc1001_2, wp1256, pc720
Uint8List encArabic = await CharsetConverter.encode("windows-1256", "اهلا");
ticket.textEncoded(encArabic,
    styles: PosStyles(codeTable: PosCodeTable.arabic));

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  test('printer test', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter('192.168.1.108', port: 9100);
    var test = await testTicket();
    final resutl = await printerManager.printTicket(test);
    print(resutl);
  });
}
