import 'package:flutter_test/flutter_test.dart';

import 'package:data_model/data_model.dart';

void main() {
  test('check whether loadDB is working or not', () async {
    expect(await loadDB(), {});
  });
}
