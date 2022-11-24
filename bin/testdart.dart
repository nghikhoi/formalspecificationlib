import 'dart:io';

import 'package:testdart/specification_parser.dart';

void testMatchFolder() {
  var dir = Directory('tests');
  var files = dir.listSync();
  for (var file in files) {
    if (file is File) {
      var contents = file.readAsStringSync();
      print('Test case ${file.path}');
      print(SpecificationParser().parse(contents));
    }
  }
}

void main(List<String> arguments) {
  testMatchFolder();
  // RegExp variableRegex =
  //     RegExp(r'([_a-zA-Z][_\w+]*)(?:[\[(]([_a-zA-Z][_\w+]*)[\])])?');
  // String test = '(VM i TH {1..n-1}.2a(i) <= a(i+1))';
  // print('Test: $test');
  // print('Substring: ${test.substring(19)}');
  // var match = variableRegex.matchAsPrefix(test, 19);
  // if (match != null) {
  //   print('Match: ${match.group(0)}');
  //   print('Name: ${match.group(1)}');
  //   print('Index: ${match.group(2)}');
  // } else {
  //   print('No match');
  // }
}
