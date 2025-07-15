import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ExportService {
  static Future<void> exportJson(Map<String, dynamic> data) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup.json');
    await file.writeAsString(jsonEncode(data));
    await launchUrl(Uri.file(file.path));
  }

  static Future<void> exportCsv(Map<String, dynamic> data) async {
    List<List<dynamic>> rows = [];
    rows.add(['Type', 'Amount', 'Date', 'Category', 'Description']);
    for (var inc in data['income']) {
      rows.add(['Income', inc['amount'], inc['date'], inc['category'], inc['description']]);
    }
    for (var exp in data['expense']) {
      rows.add(['Expense', exp['amount'], exp['date'], exp['category'], exp['description']]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup.csv');
    await file.writeAsString(csv);
    await launchUrl(Uri.file(file.path));
  }
}