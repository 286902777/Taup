import 'package:get_it/get_it.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

enum DataType {
  video('video'), //媒体
  channel('channel'); //频道

  final String value;
  const DataType(this.value);
}

class DataTool {
  static DataTool get _interest => GetIt.instance<DataTool>();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final userPath = 'jotted.db';
    String path = join(await getDatabasesPath(), userPath);
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _executeChannelTable(db: db);
        await _executeVideoTable(db: db);
      },
    );
    return _database!;
  }

  /// 创建video表
  Future<void> _executeVideoTable({required Database db}) {
    return db.execute(
      'CREATE TABLE ${DataType.video.value}('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'time INTEGER NOT NULL,'
      'fileId TEXT NOT NULL,'
      'fileCount INTEGER NOT NULL,'
      'fileName TEXT NOT NULL,'
      'thumbnail TEXT,'
      'email TEXT,'
      'directory INTEGER NOT NULL,'
      'file INTEGER NOT NULL,'
      'local INTEGER NOT NULL,'
      'history INTEGER NOT NULL,'
      'video INTEGER NOT NULL,'
      'recommend INTEGER NOT NULL,'
      'platform TEXT NOT NULL,'
      'userId TEXT NOT NULL,'
      'linkId TEXT NOT NULL,'
      'size INTEGER NOT NULL,'
      'path TEXT NOT NULL,'
      'duration INTEGER NOT NULL,'
      'position INTEGER NOT NULL'
      ')',
    );
  }

  /// 创建频道表
  Future<void> _executeChannelTable({required Database db}) {
    return db.execute(
      'CREATE TABLE ${DataType.channel.value}('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'username TEXT NOT NULL,'
      'email TEXT NOT NULL,'
      'userId TEXT NOT NULL,'
      'avtarUrl TEXT NOT NULL,'
      'platform TEXT NOT NULL,'
      'linkId TEXT NOT NULL,'
      'label TEXT NOT NULL,'
      'recommend INTEGER NOT NULL'
      ')',
    );
  }

  ///  插入数据
  static Future<int> insert({
    required DataType type,
    required Map<String, dynamic> map,
  }) async {
    final sqliteDb = await DataTool._interest.database;
    try {
      int result = await sqliteDb.insert(
        type.value,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  /// 查询数据 升：ASC 降：DESC 'key = ?'
  static Future<List<Map<String, Object?>>> query({
    required DataType type,
    String where = 'id = ?',
    String orderBy = 'id DESC',
    List<Object?>? args,
    int? limit,
  }) async {
    final sqliteDb = await DataTool._interest.database;
    try {
      List<Map<String, Object?>> list = await sqliteDb.query(
        type.value,
        limit: limit,
        where: args == null ? null : where,
        whereArgs: args,
        orderBy: orderBy,
      );
      print(list);
      return list;
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// 删除数据
  static Future<int> delete({
    required DataType type,
    required List<Object?> args,
    String where = 'id = ?',
  }) async {
    final sqliteDb = await DataTool._interest.database;
    return await sqliteDb.delete(type.value, where: where, whereArgs: args);
  }

  /// 更新数据
  static Future<int> update({
    required DataType type,
    required Map<String, dynamic> values,
    String key = 'id',
  }) async {
    final sqliteDb = await DataTool._interest.database;
    final dynamic value = values[key];
    if (value == null) {
      final result = await DataTool.insert(type: type, map: values);
      return result;
    } else {
      return await sqliteDb.update(
        type.value,
        values,
        where: '$key = ?',
        whereArgs: [values[key]],
      );
    }
  }
}
