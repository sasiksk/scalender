import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static Future<sql.Database> getDatabase() async {
    // Get the database path
    final dbPath = await sql.getDatabasesPath();

    // Open the database
    final db = await sql.openDatabase(
      path.join(dbPath, 'finance3.db'),
      version: 1,
      onCreate: (db, version) async {
        var batch = db.batch();

        // Create EventTask table
        await db.execute('''
      CREATE TABLE EventTask (
        eid INTEGER PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        descr TEXT,
        stdatetime TEXT NOT NULL,
        enddatetime TEXT,
        catid int NOT NULL,
        status TEXT ,
        alarm bool,
        reminder_time TEXT,
        FOREIGN KEY (catid) REFERENCES Categories(catid)
            
        )
    ''');

        // Create Categories table
        await db.execute('''
      CREATE TABLE Categories (
        catid INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT ,
        color TEXT NOT NULL
      )
    ''');

        // Insert default category
        await db.insert('Categories', {'name': 'default', 'color': 'blue'});

        // Create Reminders table

        // Insert default reminder

        await batch.commit();
      },
    );
    return db;
  }

  static Future<int> getNextEventTaskId() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT MAX(eid) as max_id FROM EventTask');
    final currentMaxId = result.first['max_id'] as int?;
    return (currentMaxId != null) ? currentMaxId + 1 : 1;
  }

  static Future<void> dropDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    //final dbPath = await getDatabasePath();
    final pathToDb = path.join(dbPath, 'finance3.db');
    await sql.deleteDatabase(pathToDb);
  }
}

class dbtask {
  static Future<void> insertEventTask(Map<String, dynamic> eventTask) async {
    final db = await DatabaseHelper.getDatabase();
    await db.insert('EventTask', eventTask);
  }

  static Future<int> getCategoryId(String? categoryName) async {
    final db = await DatabaseHelper.getDatabase();

    final List<Map<String, dynamic>> result = await db.query(
      'Categories',
      where: 'name = ?',
      whereArgs: [categoryName],
    );
    if (result.isNotEmpty) {
      return result.first['catid'];
    } else {
      throw Exception('Category not found');
    }
  }

  static Future<void> updateEventTask(Map<String, dynamic> task, int id) async {
    final db = await DatabaseHelper.getDatabase();
    await db.update(
      'EventTask',
      task,
      where: 'eid = ?',
      whereArgs: [id],
    );
  }
}

class dbcategory {
  static Future<void> insertCategory(Map<String, dynamic> category) async {
    final db = await DatabaseHelper.getDatabase();
    await db.insert('Categories', category);
  }
}

class dbreminder {
  static DateTime calculateReminderTime(
      String reminderText, DateTime taskDateTime) {
    DateTime reminderDateTime;

    switch (reminderText) {
      case "1 Min Before":
        reminderDateTime = taskDateTime.subtract(Duration(minutes: 1));
        break;
      case "5 Min Before":
        reminderDateTime = taskDateTime.subtract(Duration(minutes: 5));
        break;
      case "10 Min Before":
        reminderDateTime = taskDateTime.subtract(Duration(minutes: 10));
        break;
      case "30 Min Before":
        reminderDateTime = taskDateTime.subtract(Duration(minutes: 30));
        break;
      case "1 Hour Before":
        reminderDateTime = taskDateTime.subtract(Duration(hours: 1));
        break;
      case "At Start":
        reminderDateTime = taskDateTime;
        break;
      default:
        // Handle custom reminder
        final parts = reminderText.split(' ');
        final value = int.tryParse(parts[0]) ?? 0;
        final unit = parts[1];

        if (unit == "minutes") {
          reminderDateTime = taskDateTime.subtract(Duration(minutes: value));
        } else if (unit == "hours") {
          reminderDateTime = taskDateTime.subtract(Duration(hours: value));
        } else if (unit == "days") {
          reminderDateTime = taskDateTime.subtract(Duration(days: value));
        } else {
          reminderDateTime =
              taskDateTime; // Default to task start time if unit is unrecognized
        }
        break;
    }

    return reminderDateTime;
  }
}
