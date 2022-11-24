import 'dart:io';

import 'package:testdart/objects/code_block.dart';
import 'package:testdart/objects/expressions.dart';
import 'package:testdart/expression_parser.dart';
import 'package:testdart/objects/program.dart';
import 'package:testdart/objects/token_type.dart';

final ExpressionParser parser = ExpressionParser();

RegExp cleanRegex = RegExp(r'[\n\s]');

RegExp fsRegex = RegExp(
    r'(?<name>\w+)\((?<input>\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?(?:,\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?)*)?\)(?<output>\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?)pre(?<precon>.+)?post(?<postcon>.+)');

String clean(String input) {
  return input.replaceAll(cleanRegex, '');
}

void parse(String input) {
  var match = fsRegex.firstMatch(input);
  if (match == null) {
    print('No match');
    return;
  }
  print('Match: ${match.group(0)}');
  print('Name: ${match.namedGroup('name')}');
  print('Input: ${match.namedGroup('input')}');

  ExpressionContext context = ExpressionContext();
  String parameters = match.namedGroup('input')!;
  var parameterList = <Parameter>[];
  if (parameters.isNotEmpty) {
    parameters.split(',').forEach((parameter) {
      var parts = parameter.split(':');
      context.variableTypes[parts[0]] = TYPE_MAP[parts[1].toLowerCase()]!;
      parameterList.add(Parameter(parts[0], TYPE_MAP[parts[1].toLowerCase()]!));
    });
  }

  String output = match.namedGroup('output')!;
  Parameter returnParameter = Parameter('', ValueType.void_type);
  if (output.isNotEmpty) {
    var parts = output.split(':');
    context.variableTypes[parts[0]] = TYPE_MAP[parts[1].toLowerCase()]!;
    returnParameter = Parameter(parts[0], TYPE_MAP[parts[1].toLowerCase()]!);
  }

  print('Precondition: ${match.namedGroup('precon')}');
  if (match.namedGroup('precon') != null) {
    var parse = parser.parse(match.namedGroup('precon')!);
    print(parse.toCode(0));
  }
  print('Postcondition: ${match.namedGroup('postcon')}');
  if (match.namedGroup('postcon') != null) {
    var parse = parser.parse(match.namedGroup('postcon')!);
    var program = Program();
    var code = parse is CodeBlockExpression
        ? (parse as CodeBlockExpression).toCodeBlock(program, context)
        : null;

    var method =
        Method(match.namedGroup('name')!, returnParameter.type, parameterList);
    if (returnParameter.type != ValueType.void_type) {
      method.body.add(returnParameter);
      method.body.add(code!);
      method.body.add(Return(Plain(returnParameter.name)));
    } else {
      method.body.add(code!);
    }

    program.start = method;

    print(program.toCode(0));
    print('');
  }
}

void testMatchFolder() {
  var dir = Directory('tests');
  var files = dir.listSync();
  for (var file in files) {
    if (file is File) {
      var contents = file.readAsStringSync();
      print('Test case ${file.path}');
      parse(clean(contents));
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
