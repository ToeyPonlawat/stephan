import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/record.dart';

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final DatabaseHelper db = DatabaseHelper.instance;

  String selectedMonth = DateFormat('MM').format(DateTime.now());
  String selectedYear = DateFormat('yyyy').format(DateTime.now());

  Future<List<Record>> _fetchFilteredRecords() async {
    String filter = "$selectedYear-$selectedMonth";
    return db.readRecordsByMonth(filter);
  }

  Future<double> _fetchMonthlyTotal() async {
    String filter = "$selectedYear-$selectedMonth";
    return db.calculateSummary(filter);
  }

  Future<double> _fetchAllTimeTotal() async {
    return db.calculateSummary(null);
  }

  List<String> months = [
    "01", "02", "03", "04", "05", "06",
    "07", "08", "09", "10", "11", "12"
  ];

  List<String> years = List.generate(
    50,
        (index) => (DateTime.now().year - index).toString(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Summary')),
      body: Column(
        children: [
          // Filters Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month Dropdown
                DropdownButton<String>(
                  value: selectedMonth,
                  items: months
                      .map((month) => DropdownMenuItem(
                    value: month,
                    child: Text(
                      DateFormat.MMMM().format(DateTime(0, int.parse(month))),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),
                // Year Dropdown
                DropdownButton<String>(
                  value: selectedYear,
                  items: years
                      .map((year) => DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: Future.wait([
              _fetchFilteredRecords(),
              _fetchMonthlyTotal(),
              _fetchAllTimeTotal(),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              final records = snapshot.data![0] as List<Record>;
              final monthlyTotal = snapshot.data![1] as double;
              final allTimeTotal = snapshot.data![2] as double;

              return Expanded(
                child: Column(
                  children: [
                    // Summary Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Summary for ${DateFormat.MMMM().format(DateTime(0, int.parse(selectedMonth)))} $selectedYear:",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "\$${monthlyTotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              color: monthlyTotal >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "All Time Summary:",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "\$${allTimeTotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              color: allTimeTotal >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Records List
                    Expanded(
                      child: ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Container(
                            color: record.value < 0
                                ? Colors.yellow[100] // Expense color
                                : Colors.blue[100], // Income color
                            margin: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            child: ListTile(
                              title: Text(record.name),
                              subtitle: Text(record.date),
                              trailing: Text(
                                record.value.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
