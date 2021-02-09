import 'package:sqlite3/sqlite3.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tdl/settingsManager.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;
// local dependencies

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
  db.execute('''
    CREATE TABLE IF NOT EXISTS ${listName} (
      id INTEGER NOT NULL PRIMARY KEY,
      todo TEXT NOT NULL,
      done INTEGER default 0,
      createdAt INTEGER NOT NULL
    );
  ''');
}

void deleteList(String listName) {
  db.execute('DROP TABLE ${listName}');
}

// adds a todo to a particular list
void addTodo(String todoText, String listName) {
  var now = DateTime.now().microsecondsSinceEpoch;
  db.execute('''
    INSERT INTO ${listName}
    (todo,createdAt)
    VALUES
    ("${todoText}",${now.toString()});
  ''');
}

// removes a todo to a particular list
void removeTodo(String todoId, String listName) {
  // find actual todo-id from db
  final notDoneTodos = db.select(
      'SELECT * FROM ${listName} WHERE done == 0 ORDER BY createdAt ASC LIMIT ${todoId}');
  String actualTodoId =
      notDoneTodos.elementAt(int.parse(todoId) - 1)['id'].toString();
  // db operation
  db.execute('''
    DELETE FROM ${listName}
    WHERE id == ${actualTodoId};
  ''');
}

// lists todos from a particular list
void listTodos(String listName) {
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

// list all tables
void listTables() {
  final allLists =
      db.select("SELECT name FROM sqlite_master WHERE type='table';");
  print('Total ${allLists.length} Lists');
  allLists.forEach((table) {
    print(table['name']);
  });
  print('');
}
