import 'package:testdart/objects/expressions.dart';
import 'package:testdart/objects/token_type.dart';

class ExpressionParser {
  late RegExp cleanRegex,
      typeIregex,
      typeIIRegex,
      variableRegex,
      variableRegexFull,
      tokenRegex,
      stringRegex,
      stringRegexFull,
      doubleRegex,
      doubleRegexFull;

  ExpressionParser() {
    cleanRegex = RegExp(r'[\n\s]');
    typeIregex = RegExp(
        r'(?<name>\w+)\((?<input>\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?(?:,\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?)*)?\)(\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?)pre(?<precon>[()\w!=><|&+\-/%".]+)?post(?<postcon>[()\w!=><|&+\-/%".]+)');
    typeIIRegex = RegExp(
        r'(?<type>VM|TT)(?<var>\w+)TH{(?<start>[\w-+]+)..(?<end>[\w-+]+)}\.(?<exp>.+)');

    String variableRegexStr =
        r'([_a-zA-Z][_\w]*)(?:[\[(]([_a-zA-Z][_\w+-]*)[\])])?';
    variableRegex = RegExp(variableRegexStr);
    variableRegexFull = RegExp('^$variableRegexStr\$');

    tokenRegex = RegExp(r'(>=|<=|!=|\|\||&&|=|\+|-|\*|\/|%|>|<)');

    String stringRegexStr = r'"([^"]*)"';
    stringRegex = RegExp(stringRegexStr);
    stringRegexFull = RegExp('^$stringRegexStr\$');

    String doubleRegexStr = r'(\-?\d*\.?\d+)';
    doubleRegex = RegExp(doubleRegexStr);
    doubleRegexFull = RegExp('^$doubleRegexStr\$');
  }

  String _clean(String input) {
    return input.replaceAll(cleanRegex, '');
  }

  int _matchTypeII(String input, int start) {
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

    if (parenCount < 0) i--;
    String sub = input.substring(start, i);
    var match = typeIIRegex.matchAsPrefix(sub);
    if (match == null) {
      return -1;
    }
    return i;
  }

  bool _nextMatch(String source, RuneIterator iter, RegExp regExp,
      void Function(Match match, String matchStr) callback) {
    int current = iter.rawIndex;
    var match = regExp.matchAsPrefix(source, current);
    if (match != null) {
      current = match.end;
      iter.rawIndex = current - 1;
      callback(match, match.group(0)!);
      return true;
    }
    return false;
  }

  Expression parse(String input) {
    input = _clean(input);
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
      } else if (_matchTypeII(input, iter.rawIndex) != -1) {
        if (buffer.isNotEmpty) {
          result.add(buffer);
          buffer = '';
        }
        var end = _matchTypeII(input, iter.rawIndex);
        var sub = input.substring(iter.rawIndex, end);

        var match = typeIIRegex.firstMatch(sub)!;
        var type = match.namedGroup('type')!;
        var varName = match.namedGroup('var')!;
        var startVar = match.namedGroup('start')!;
        var endVar = match.namedGroup('end')!;
        var exp = match.namedGroup('exp')!;

        result.add(varName);
        result.add(startVar);
        result.add(endVar);
        result.add(exp);
        if (type == 'TT') {
          result.add(FORANY.token);
        } else {
          result.add(FORALL.token);
        }

        iter.rawIndex = end - 1;
      } else if (_nextMatch(input, iter, tokenRegex, (match, matchStr) {
        if (buffer.isNotEmpty) {
          result.add(buffer);
          buffer = '';
        }
        if (TOKEN_TYPES.containsKey(matchStr)) {
          iter.movePrevious();
          var prevChar = String.fromCharCode(iter.current);
          iter.moveNext();
          if (matchStr == '-' && '=><!|&+-/%'.contains(prevChar)) {
            matchStr = '-1*';
          }
          while (stack.isNotEmpty &&
              TOKEN_TYPES[stack.last]!.priority >=
                  TOKEN_TYPES[matchStr]!.priority) {
            result.add(stack.removeLast());
          }
          stack.add(matchStr);
        }
      })) {
        continue;
      } else if (_nextMatch(input, iter, variableRegex, (match, matchStr) {
        buffer = matchStr;
      })) {
        continue;
      } else if (_nextMatch(input, iter, stringRegex, (match, matchStr) {
        buffer = matchStr;
      })) {
        continue;
      } else if (_nextMatch(input, iter, doubleRegex, (match, matchStr) {
        buffer = matchStr;
      })) {
        continue;
      } else {
        // buffer += char;
        throw Exception('Invalid character: $char');
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
        var exp;
        if (stringRegexFull.hasMatch(token)) {
          exp = ConstantsExpression(token.substring(1, token.length - 1));
        } else {
          try {
            int parsed = int.parse(token);
            exp = ConstantsExpression(parsed);
          } on FormatException {
            try {
              double parsed = double.parse(token);
              exp = ConstantsExpression(parsed);
            } on FormatException {
              if (token.toLowerCase() == 'true' ||
                  token.toLowerCase() == 'false') {
                exp = ConstantsExpression(token.toLowerCase() == 'true');
              } else {
                var match = variableRegexFull.firstMatch(token);
                if (match != null) {
                  var access = match.group(2);
                  exp = VariableExpression(match.group(1)!);
                  if (access != null) {
                    exp = ArrayAccessExpression(exp, parse(access));
                  }
                } else {
                  try {
                    exp = parse(token);
                  } catch (e) {
                    throw Exception('Invalid token: $token');
                  }
                }
              }
            }
          }
        }
        expStack.add(exp);
      }
    }

    return expStack.removeLast().rehearsal();
  }
}
