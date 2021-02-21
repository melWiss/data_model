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
  Future<void> save() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    var file = File(join(path, 'db', toPath() + '.json'));
    creationDate = creationDate ?? DateTime.now();
    file.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(toMap()));
    var db = await loadDB();
    if (db.containsKey(toString())) {
      db[toString()].add(id);
    } else {
      db[toString()] = [];
      db[toString()].add(id);
    }
    var fileDB = File(join(path, 'db', 'db.json'));
    fileDB.writeAsStringSync(jsonEncode(db));
  }

  /// This method lets you load your model from local storage.
  Future<void> load() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    var file = File(join(path, 'db', toPath() + '.json'));
    var dataString = file.readAsStringSync();
    fromMap(jsonDecode(dataString));
  }

  /// This method gives you the path of your DataModel
  String toPath() => '${toString()}/$id';
}

/// This method let's you load your DataModels local Database
Future<Map<String, dynamic>> loadDB() async {
  String path = (await getApplicationDocumentsDirectory()).path;
  try {
    var file = File(join(path, 'db', 'db.json'));
    file.createSync(recursive: true);
    if (file.readAsStringSync() == '') return {};
    var data = jsonDecode(file.readAsStringSync());
    return data;
  } catch (e) {
    print(e.toString());
    return <String, dynamic>{};
  }
}
