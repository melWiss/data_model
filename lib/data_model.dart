library data_model;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

abstract class DataModel {
  /// This method takes a Map<String,dynamic> as an argument and applies
  /// it's data to the DataModel.
  void fromMap(Map<String, dynamic> map);

  /// This method returns DataModel's data as a Map of <String,dynamic>.
  Map<String, dynamic> toMap();

  /// This field is the id of the DataModel.
  String id;

  /// This field gives you the creationDate of the current DataModel.
  /// (This field is used to update your DataModel safely, it compares the
  /// creationDate of the saved DataModel and the creationDate of the
  /// current DataModel)
  DateTime creationDate;
}

extension CRUD on DataModel {
  /// This method let's you save your model locally.
  // TODO: prevent save() method from replacing old files with new ones
  Future<File> _createDB() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    var file = File(join(path, 'db.json'));
    if (!file.existsSync()) {
      creationDate = creationDate ?? DateTime.now();
      file.createSync(recursive: true);
      file.writeAsStringSync(jsonEncode(toMap()));
    }
    return file;
  }

  Future<void> save() async {
    var db = await loadDB();
    if (db.containsKey(toString())) {
      if (!db[toString()].containsKey(id)) db[toString()][id] = toMap();
    } else {
      db[toString()] = {};
      db[toString()][id] = toMap();
    }
    var appDoc = await getApplicationDocumentsDirectory();
    var fileDB = File(join(appDoc.path, 'db', 'db.json'));
    fileDB.writeAsStringSync(jsonEncode(db));
  }

  /// This method lets you load your model from local storage.
  Future<void> load() async {
    var db = await loadDB();
    if (db.containsKey(toString())) {
      if (db[toString()].containsKey(id)) {
        fromMap(db[toString()][id]);
      }
    }
  }

  /// This method lets you update your model from local storage.
  Future<void> update() async {
    var db = await loadDB();
    if (db.containsKey(toString())) {
      if (db[toString()].containsKey(id)) {
        db[toString()][id] = toMap();
        var appDoc = await getApplicationDocumentsDirectory();
        var fileDB = File(join(appDoc.path, 'db', 'db.json'));
        fileDB.writeAsStringSync(jsonEncode(db));
      }
    }
  }

  /// This method lets you delete your model from local storage.
  Future<void> delete() async {
    var db = await loadDB();
    if (db.containsKey(toString())) {
      if (db[toString()].containsKey(id)) {
        db[toString()].remove(id);
        var appDoc = await getApplicationDocumentsDirectory();
        var fileDB = File(join(appDoc.path, 'db', 'db.json'));
        fileDB.writeAsStringSync(jsonEncode(db));
      }
    }
  }

  /// This method gives you the path of your DataModel
  // String toPath() => '${toString()}/$id';

  /// This method let's you load your DataModels local Database
  Future<Map<String, dynamic>> loadDB() async {
    var file = await _createDB();
    var data = jsonDecode(file.readAsStringSync());
    return data;
  }
}
