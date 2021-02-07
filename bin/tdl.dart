import 'package:args/args.dart';

// local dependencies
import 'package:tdl/dbManager.dart';
import 'package:tdl/settingsManager.dart';

void main(List<String> arguments) {
  // fetch-config
  getSettings().then((Map<dynamic, dynamic> value) => {
        if (value['db_initilized'] == 'false') {initDB()}
      });

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
  var argResults = parser.parse(arguments);

// create -flow
  if (argResults.command.name == 'create') {
    if (argResults.arguments.length == 2) {
      createList(argResults.arguments[1]);
      print('Created new list named ${argResults.arguments[1]} ');
    } else {
      print('''Error : create command takes one argument - listname
      (for example : create myList)
          ''');
    }
  }
// add -flow
  else if (argResults.command.name == 'add') {
    if (argResults.arguments.length == 1) {
      print(
          '''Error : add command takes one argument todo text and a optional -l list-name - todo
      (for example : add "buy grossery from shop" -l "shopping")
          ''');
    } else {
      addTodo(argResults.arguments[1], argResults['list']);
      print("Added one todo in ${argResults['list']}");
    }
  }
  // delete-flow
  else if (argResults.command.name == 'delete') {
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
  else if (argResults.command.name == 'lists') {
    listTables();
  }

  // list-todo -flow
  else if (argResults.command.name == 'todos') {
    listTodos(argResults['list']);
  } else {
    print('commands : create, add, todos, lists,remove, delete');
  }
// main-end
}
