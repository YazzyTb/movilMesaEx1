import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBSQLiteLocal {
  late Database _dataBase;

  Future<void> openDataBaseLocal() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    _dataBase = await openDatabase(path);
  }

  Future<List<Map<String, dynamic>>> getAllItems(String table) async {
    final List<Map<String, dynamic>> allItems = await _dataBase.query(table);
    return allItems;
  }

  Future<void> insert(String table, Map<String, dynamic> newItem) async {
    await _dataBase.insert(table, newItem);
  }

  Future<bool> isTheTableEmpty(String table) async {
    final List<Map<String, dynamic>> allItems = await _dataBase.query(table);

    return allItems.isEmpty;
  }

  Future<void> clearTable(String table) async {
    await _dataBase.delete(table);
  }

  Future<void> closeDataBase() async {
    await _dataBase.close();
  }
}
