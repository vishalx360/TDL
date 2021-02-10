import 'package:sqlite3/sqlite3.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:path/path.dart' as path;
import 'dart:io' as io;
// local dependencies ----
import 'package:tdl/settingsManager.dart';

// constants
String homeDirPath = path.absolute(io.Platform.environment['HOME']);
String dbLocation = path.join(homeDirPath, '.tdl/db/todoLists');
// db setup

final db = sqlite3.open(dbLocation);
// Helper Functions -------------------------------
// Create a table and insert some data
void initDB() {
  createList('main_list');
  post_initDB();
}

void createList(String listName) {
  try {
    db.execute('''
    CREATE TABLE IF NOT EXISTS ${listName} (
      id INTEGER NOT NULL PRIMARY KEY,
      todo TEXT NOT NULL,
      done INTEGER default 0,
      createdAt INTEGER NOT NULL
    );
  ''');
  } catch (err) {
    print('ERROR : ${err.message}');
  }
}

void deleteList(String listName) {
  try {
    db.execute('DROP TABLE ${listName}');
  } on SqliteException catch (e) {
    if (e.extendedResultCode >= 1 && e.extendedResultCode <= 8) {
      print(
          '\nERROR: Got error while reading the local Database.\nPlease re-check your command for misspelled names\n');
    }
  } catch (err) {
    print('ERROR : ${err.message}');
  }
}

// adds a todo to a particular list
void addTodo(String todoText, String listName) {
  try {
    var now = DateTime.now().microsecondsSinceEpoch;
    db.execute('''
    INSERT INTO ${listName}
    (todo,createdAt)
    VALUES
    ("${todoText}",${now.toString()});
  ''');
    print('Added one todo in ${listName}');
  } on SqliteException catch (e) {
    if (e.extendedResultCode >= 1 && e.extendedResultCode <= 8) {
      print(
          '\nERROR: Got error while reading the local Database.\nPlease re-check your command for misspelled names\n');
    }
  } catch (err) {
    print('ERROR : ${err.message}');
  }
}

// removes a todo to a particular list
void removeTodo(String todoId, String listName) {
  try {
    // find actual todo-id from db
    final notDoneTodos = db.select(
        'SELECT * FROM ${listName} WHERE done == 0 ORDER BY createdAt ASC LIMIT ${todoId}');
    var actualTodoId =
        notDoneTodos.elementAt(int.parse(todoId) - 1)['id'].toString();
    // db operation
    db.execute('''
    DELETE FROM ${listName}
    WHERE id == ${actualTodoId};
  ''');
    print('Removed one todo from ${listName}');
  }
  // error handeling
  on RangeError {
    print(
        '\nERROR: Got error while reading the local Database.\nPlease re-check your given todo-id\n');
  } on SqliteException catch (e) {
    if (e.extendedResultCode >= 1 && e.extendedResultCode <= 8) {
      print(
          '\nERROR: Got error while reading the local Database.\nPlease re-check your command for misspelled names\n');
    }
  } catch (err) {
    print('ERROR : ${err.message}');
  }
}

// lists todos from a particular list
void listTodos(String listName) {
  try {
    final notDoneTodos = db.select(
        'SELECT * FROM ${listName} WHERE done == 0 ORDER BY createdAt ASC');
    print(listName + ' ---------------------------');
    print('Not Done : ' + notDoneTodos.length.toString());

    var count = 1;
    notDoneTodos.forEach((element) {
      var createdAt = DateTime.fromMicrosecondsSinceEpoch(element['createdAt']);
      var dateString = timeago.format(createdAt);
      print('${count} ${element['todo']} : ${dateString}');
      count++;
    });
  }
  // error handeling
  on SqliteException catch (e) {
    if (e.extendedResultCode >= 1 && e.extendedResultCode <= 8) {
      print(
          '\nERROR: Got error while reading the local Database.\nPlease re-check your command for misspelled names\n');
    }
  } catch (err) {
    print('ERROR : ${err.message}');
  }
}

// list all tables
void listTables() {
  final allLists =
      db.select("SELECT name FROM sqlite_master WHERE type='table';");
  print('Found Total ${allLists.length} Lists\n');
  allLists.forEach((table) {
    print(table['name']);
  });
  print('');
}
