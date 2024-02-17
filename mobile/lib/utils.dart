import 'dart:convert';
import 'dart:io';

List<dynamic> readJsonFile(String filePath) {
  var input = File(filePath).readAsStringSync();
  var map = jsonDecode(input);
  return map;
}
