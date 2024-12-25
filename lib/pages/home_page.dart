import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/record.dart';
import '../database/database_helper.dart';
import 'summary_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String _type = "Income";
  DateTime _selectedDate = DateTime.now();
  final DatabaseHelper db = DatabaseHelper.instance;

  void _saveRecord() async {
    final name = _nameController.text.trim();
    final value = double.tryParse(_valueController.text) ?? 0.0;

    if (name.isEmpty || value <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter valid data')));
      return;
    }

    final record = Record(
      name: name,
      type: _type,
      value: _type == "Expense" ? -value : value,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    await db.createRecord(record);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Record Saved')));
    _nameController.clear();
    _valueController.clear();
    setState(() {
      _type = "Income";
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Record')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Value'),
            ),
            DropdownButton<String>(
              value: _type,
              items: ['Income', 'Expense']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
            ),
            Row(
              children: [
                Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRecord,
              child: Text('Save'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SummaryPage()),
                );
              },
              child: Text('View Summary'),
            ),
          ],
        ),
      ),
    );
  }
}
