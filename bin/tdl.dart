import 'dart:io';

import 'package:args/args.dart';

// local dependencies
import 'package:tdl/dbManager.dart';
import 'package:tdl/settingsManager.dart';

// CONSTANTS
const LIST_NAME_MAX_SIZE = 20;
const TODO_MAX_SIZE = 280;
const USAGE = '''
Usage : `tdl [command] [option] ...`

    Commands      Description
-------------------------------------------
    create        creates new list.
    add           adds a todo to a particular list.
    todos         display all not finished todos.
    lists         displays all lists.
    remove        removes a particular todo.
    delete        deletes a list.
''';

void main(List<String> arguments) {
  // fetch-config
  getSettings().then((Map<dynamic, dynamic> value) => {
        if (value['db_initilized'] == 'false') {initDB()}
      });
  // init parser
  final parser = ArgParser();

  // options -----------
  parser.addOption('list', abbr: 'l', defaultsTo: 'main_list');

  // commands -----------
  // create command
  parser.addCommand('create');
  // add command
  parser.addCommand('add');
  // listTodos command
  parser.addCommand('todos');
  // lists command
  parser.addCommand('lists');
  // removeTodo command
  parser.addCommand('remove');
  // delete command
  parser.addCommand('delete');

  // parser-result
  var argResults;
  try {
    argResults = parser.parse(arguments);
  } on FormatException catch (e) {
    // print the error
    print('ERROR : ${e.message}\n');
    // print the usage
    print(USAGE);
    // exit out of the program
    exit(1);
  } catch (e) {
    // other errors
    print('ERROR ${e.message}');
  }
  var command;
  // error checking
  if (argResults.command != null) {
    command = argResults.command.name;
  }
// create -flow
  if (command == 'create') {
    if (argResults.arguments.length == 2) {
      if (argResults.arguments[1].length > LIST_NAME_MAX_SIZE) {
        print('List-Name should be under ${LIST_NAME_MAX_SIZE} characters.');
        // exit out of the program
        exit(1);
      }
      createList(argResults.arguments[1]);
      print('Created new list named ${argResults.arguments[1]} ');
    } else {
      print('''Error : create command takes one argument - listname
      (for example : create myNewList)
          ''');
    }
  }
// add -flow
  else if (command == 'add') {
    if (argResults.arguments.length == 1) {
      print(
          '''Error : add command takes one argument todo text and a optional -l list-name - todo
      (for example : add "buy grossery from shop" -l "shopping")
          ''');
    } else {
      if (argResults.arguments[1].length > TODO_MAX_SIZE) {
        print('ERROR: each Todo should be under ${TODO_MAX_SIZE} characters.');
        // exit out of the program
        exit(1);
      }
      addTodo(argResults.arguments[1], argResults['list']);
    }
  }

  // remove -flow
  else if (command == 'remove') {
    if (argResults.arguments.length == 1) {
      print(
          '''Error : remove command takes one argument todo-id and a optional -l list-name - todo
      (for example : remove 3 -l "shopping")
          ''');
    } else {
      removeTodo(argResults.arguments[1], argResults['list']);
    }
  }

  // delete-flow
  else if (command == 'delete') {
    if (argResults.arguments.length == 2) {
      if (argResults.arguments[1] != 'main_list') {
        deleteList(argResults.arguments[1]);
        print('Deleted list named ${argResults.arguments[1]} ');
      } else {
        print('You can not delete default main_list');
      }
    } else {
      print('''Error : delete command takes one argument - listname
      (for example : delete myList)
          ''');
    }
  }

  // list -flow
  else if (command == 'lists') {
    listTables();
  }

  // list-todo -flow
  else if (command == 'todos') {
    listTodos(argResults['list']);
  }

  // default-flow
  else {
    print(USAGE);
    // exit code for command not found
    exit(127);
  }
// main-method-end
}
