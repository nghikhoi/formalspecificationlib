import 'dart:io';

import 'package:testdart/expressions.dart';
import 'package:testdart/token_type.dart';

RegExp cleanRegex = RegExp(r'[\n\s]');

RegExp typeIregex = RegExp(
    r'(?<name>\w+)\((?<input>\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?(?:,\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?)*)?\)(\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?)pre(?<precon>[()\w!=><|&+\-/%".]+)?post(?<postcon>[()\w!=><|&+\-/%".]+)');

String clean(String input) {
  return input.replaceAll(cleanRegex, '');
}

void parse(String input) {
  var match = typeIregex.firstMatch(input);
  if (match == null) {
    print('No match');
    return;
  }
  print('Match: ${match.group(0)}');
  print('Name: ${match.namedGroup('name')}');
  print('Input: ${match.namedGroup('input')}');
  print('Precondition: ${match.namedGroup('precon')}');
  print('Postcondition: ${match.namedGroup('postcon')}');
}

void testMatchFolder() {
  var dir = Directory('tests');
  var files = dir.listSync();
  for (var file in files) {
    if (file is File) {
      var contents = file.readAsStringSync();
      parse(clean(contents));
    }
  }
}

RegExp typeIIRegex = RegExp(r'(VM|TT)(\w+)TH{([\w-+]+)..([\w-+]+)}\.(.+)');

int matchTypeII(String input, int start) {
  var i = start;
  var parenCount = 0;
  while (i < input.length && parenCount >= 0) {
    var c = input[i];
    if (c == '(') {
      parenCount++;
    } else if (c == ')') {
      parenCount--;
    }
    i++;
  }

  String sub = input.substring(start, i - 1);
  var match = typeIIRegex.firstMatch(sub);
  if (match == null) {
    return -1;
  }
  return i;
}

void main(List<String> arguments) {
  String input =
      '((kq=FALSE)&&(nam%4!=0))||((kq=FALSE)&&(nam%400!=0)&&(nam%100=0))||((kq=TRUE)&&(nam%4=0)&&(nam%100!=0))||((kq=TRUE)&&(nam%400=0))';
  final RuneIterator iter = input.runes.iterator;
  var result = <String>[];
  var stack = <String>[];
  String buffer = '';
  while (iter.moveNext()) {
    var rune = iter.current;
    var char = String.fromCharCode(rune);
    if (char == '(') {
      stack.add(char);
    } else if (char == ')') {
      if (buffer.isNotEmpty) {
        result.add(buffer);
        buffer = '';
      }
      while (stack.isNotEmpty) {
        var top = stack.removeLast();
        if (top == '(') {
          break;
        }
        result.add(top);
      }
    } else if (matchTypeII(input, iter.rawIndex) != -1) {
      if (buffer.isNotEmpty) {
        result.add(buffer);
        buffer = '';
      }
      var end = matchTypeII(input, iter.rawIndex);
      var sub = input.substring(iter.rawIndex, end);
      result.add(sub);
      iter.rawIndex = end;
    } else if ('=><!|&+-/%'.contains(char)) {
      if (buffer.isNotEmpty) {
        result.add(buffer);
        buffer = '';
      }
      buffer += char;

      iter.moveNext();
      var nextChar = String.fromCharCode(iter.current);
      if ('=><!|&+-/%'.contains(nextChar) &&
          TOKEN_TYPES.containsKey(buffer + nextChar)) {
        buffer += nextChar;
      } else {
        iter.movePrevious();
      }

      if (TOKEN_TYPES.containsKey(buffer)) {
        iter.movePrevious();
        var prevChar = String.fromCharCode(iter.current);
        iter.moveNext();
        if (buffer == '-' && '=><!|&+-/%'.contains(prevChar)) {
          buffer = '-1*';
        }
        while (stack.isNotEmpty &&
            TOKEN_TYPES[stack.last]!.priority >=
                TOKEN_TYPES[buffer]!.priority) {
          result.add(stack.removeLast());
        }
        stack.add(buffer);
        buffer = '';
      }
    } else {
      buffer += char;
    }
  }

  if (buffer.isNotEmpty) {
    result.add(buffer);
    buffer = '';
  }

  while (stack.isNotEmpty) {
    result.add(stack.removeLast());
  }

  var expStack = <Expression>[];
  for (var token in result) {
    if (TOKEN_TYPES.containsKey(token)) {
      var type = TOKEN_TYPES[token]!;
      var inputs = <Expression>[];
      for (int i = 0; i < type.inputs; i++) {
        inputs.add(expStack.removeLast());
      }
      expStack.add(type.creator(inputs));
    } else {
      expStack.add(VariableExpression(token));
    }
  }

  Expression expResult = expStack.removeLast();
  expResult = expResult.rehearsal();

  print(expResult.toCode(0));
}
