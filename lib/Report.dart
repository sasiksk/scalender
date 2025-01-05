import 'package:flutter/material.dart';
import 'package:scalender/Data/DatabaseHelper.dart'; // Import the database helper

class DatabaseHelperPage extends StatefulWidget {
  @override
  _DatabaseHelperPageState createState() => _DatabaseHelperPageState();
}

class _DatabaseHelperPageState extends State<DatabaseHelperPage> {
  String? selectedTable;
  List<String> tables = [
    'EventTask',
    'Categories',
  ]; // Example table names
  List<Map<String, dynamic>> tableData = []; // Example table data

  void fetchTableData(String tableName) async {
    final db = await DatabaseHelper.getDatabase();
    final data = await db.query(tableName);
    setState(() {
      tableData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Helper'),
      ),
      body: Center(
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Table'),
              value: selectedTable,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTable = newValue;
                  fetchTableData(newValue!);
                });
              },
              items: tables.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: tableData.isNotEmpty
                    ? DataTable(
                        columns: tableData.first.keys
                            .map((key) => DataColumn(label: Text(key)))
                            .toList(),
                        rows: tableData.map((data) {
                          return DataRow(
                            cells: data.values
                                .map(
                                    (value) => DataCell(Text(value.toString())))
                                .toList(),
                          );
                        }).toList(),
                      )
                    : Center(child: Text('No data available')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
