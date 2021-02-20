library data_model;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

abstract class DataModel {
  void fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap();
  String toPath();
  DateTime creationDate;
  String id;
  Future save();
  Future load();
}

Future<void> saveModel(DataModel model) async {
  String path = (await getApplicationDocumentsDirectory()).path;
  var file = File(join(path, model.toPath() + '.json'));
  model.creationDate = model.creationDate ?? DateTime.now();
  file.createSync(recursive: true);
  file.writeAsStringSync(jsonEncode(model.toMap()));
  var db = await loadDB();
  if (db.containsKey(model.toString())) {
    db[model.toString()].add(model.id);
  } else {
    db[model.toString()] = [];
    db[model.toString()].add(model.id);
  }
  var fileDB = File(join(path, 'db.json'));
  fileDB.writeAsStringSync(jsonEncode(db));
}

Future<DataModel> loadModel(DataModel model) async {
  String path = (await getApplicationDocumentsDirectory()).path;
  var file = File(join(path, model.toPath() + '.json'));
  var dataString = file.readAsStringSync();
  model.fromMap(jsonDecode(dataString));
  return model;
}

Future<Map<String, dynamic>> loadDB() async {
  String path = (await getApplicationDocumentsDirectory()).path;
  try {
    var file = File(join(path, 'db.json'));
    var data = jsonDecode(file.readAsStringSync());
    return data;
  } catch (e) {
    print(e.toString());
    return <String, dynamic>{};
  }
}
