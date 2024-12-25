import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        value REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // บันทึกลงฐานข้อมูล
  Future<int> createRecord(Record record) async {
    final db = await database;
    return await db.insert('records', record.toMap());
  }

  Future<List<Record>> readRecordsByMonth(String month) async {
    final db = await database;
    final result = await db.query(
      'records',
      where: "strftime('%Y-%m', date) = ?",
      whereArgs: [month],
      orderBy: 'date ASC', // Order by date in ascending order
    );
    return result.map((json) => Record.fromMap(json)).toList();
  }

  Future<double> calculateSummary(String? month) async {
    final db = await database;
    String query = "SELECT SUM(value) as total FROM records";
    if (month != null) {
      query += " WHERE strftime('%Y-%m', date) = '$month'";
    }
    final result = await db.rawQuery(query);
    return result[0]['total'] != null ? result[0]['total'] as double : 0.0;
  }
}
