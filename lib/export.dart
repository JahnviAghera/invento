import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportDataScreen extends StatefulWidget {
  @override
  _ExportDataScreenState createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  String? exportedFilePath;

  Future<void> exportInventoryToExcel() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('inventory').get();
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Inventory'];

      //  Add Headers
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue("Name");
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue("SKU");
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue("Quantity");
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue("Price");
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = TextCellValue("Cost");

      //  Add Data Rows
      int rowIndex = 1;
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value =
            TextCellValue(data['name'] ?? 'N/A');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value =
            TextCellValue(data['sku'] ?? 'N/A');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value =
            IntCellValue((data['quantity'] as num?)?.toInt() ?? 0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value =
            DoubleCellValue((data['price'] as num?)?.toDouble() ?? 0.0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value =
            DoubleCellValue((data['cost'] as num?)?.toDouble() ?? 0.0);
        rowIndex++;
      }

      //  Fix: Use Internal Storage Instead of `getExternalStorageDirectory()`
      Directory directory = await getApplicationDocumentsDirectory(); // 🔥 Works on all Android versions!
      String filePath = "${directory.path}/inventory.xlsx";
      File file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      setState(() {
        exportedFilePath = filePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Excel exported to: $filePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error exporting: $e")),
      );
    }
  }

  void shareFile() {
    if (exportedFilePath != null) {
      Share.shareXFiles([XFile(exportedFilePath!)], text: "📂 Here is the exported file.");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ No file to share. Please export first.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Export Data")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: exportInventoryToExcel,
              child: Text("📊 Export Inventory to Excel"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: shareFile,
              child: Text("📤 Share Exported File"),
            ),
            SizedBox(height: 30),
            exportedFilePath != null
                ? Text("📂 File saved at:\n$exportedFilePath", textAlign: TextAlign.center)
                : Text("⚠ No files exported yet"),
          ],
        ),
      ),
    );
  }
}
