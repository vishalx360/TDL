import 'dart:io' as io;
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;

// for a file
Future<bool> fileExists(String path) {
  return io.File(path).exists();
}

// for a directory
Future<bool> folderExists(String path) {
  return io.Directory(path).exists();
}

String homeDirPath = path.absolute(io.Platform.environment['HOME']);

// defaults
final APP_DIR = path.join(homeDirPath, '.tdl');
final CONFIG_PATH = path.join(APP_DIR, 'settings.json');
final DB_PATH = path.join(APP_DIR, 'db');
// default settings
Map<String, String> CONFIG = {
  'db_initilized': 'false',
  'default_list': 'main_list',
};

Future<Map> getSettings() async {
  if (!await folderExists(APP_DIR)) {
    // create settings.json config file
    await io.File(CONFIG_PATH).createSync(recursive: true);
    await io.Directory(DB_PATH).create();
    // write defaut settings to it
    await io.File(CONFIG_PATH).writeAsString(json.encode(CONFIG));
    return CONFIG;
  } else {
    // if settings exists, load.
    var localConfig = {};
    await io.File(CONFIG_PATH).readAsString().then((String contents) {
      localConfig = json.decode(contents);
    });
    return localConfig;
  }
}

void post_initDB() async {
  var newConfig = CONFIG;
  newConfig['db_initilized'] = 'true';
  await io.File(CONFIG_PATH).writeAsString(json.encode(newConfig));
}
