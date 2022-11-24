import 'package:testdart/expression_parser.dart';
import 'package:testdart/objects/code_block.dart';
import 'package:testdart/objects/expressions.dart';
import 'package:testdart/objects/program.dart';

class SpecificationParser {
  final ExpressionParser parser = ExpressionParser();

  RegExp cleanRegex = RegExp(r'[\n\s]');

  RegExp fsRegex = RegExp(
      r'(?<name>\w+)\((?<input>\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?(?:,\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?)*)?\)(?<output>\w+:(?:N|N1|Z|R|Q|B|(?:[cC][hH][aA][rR]))\*?)pre(?<precon>.+)?post(?<postcon>.+)');

  String clean(String input) {
    return input.replaceAll(cleanRegex, '');
  }

  String parse(String input) {
    input = clean(input);
    var match = fsRegex.firstMatch(input);
    if (match == null) {
      throw Exception('Invalid specification');
    }

    ExpressionContext context = ExpressionContext();
    String parameters = match.namedGroup('input')!;
    var parameterList = <Parameter>[];
    if (parameters.isNotEmpty) {
      parameters.split(',').forEach((parameter) {
        var parts = parameter.split(':');
        context.variableTypes[parts[0]] = TYPE_MAP[parts[1].toLowerCase()]!;
        parameterList
            .add(Parameter(parts[0], TYPE_MAP[parts[1].toLowerCase()]!));
      });
    }

    String output = match.namedGroup('output')!;
    Parameter returnParameter = Parameter('', ValueType.void_type);
    if (output.isNotEmpty) {
      var parts = output.split(':');
      context.variableTypes[parts[0]] = TYPE_MAP[parts[1].toLowerCase()]!;
      returnParameter = Parameter(parts[0], TYPE_MAP[parts[1].toLowerCase()]!);
    }

    var program = Program();

    if (match.namedGroup('precon') != null) {
      var parse = parser.parse(match.namedGroup('precon')!);
      if (parse != null) {
        if (parse is! BooleanExpression) {
          throw 'Precondition must be a boolean expression';
        }

        var method = Method('Validate_${match.namedGroup('name')!}',
            ValueType.bool, parameterList);

        var ifBlock = If(Plain(parse.toCode(0)));
        ifBlock.body.add(Return(Constant(ValueType.bool, 'true')));
        ifBlock.elseBody.add(Return(Constant(ValueType.bool, 'false')));

        method.body.add(ifBlock);
        program.validate = method;
      }
    }

    if (match.namedGroup('postcon') != null) {
      var parse = parser.parse(match.namedGroup('postcon')!);

      var code = parse is CodeBlockExpression
          ? (parse as CodeBlockExpression).toCodeBlock(program, context)
          : null;

      var method = Method(
          match.namedGroup('name')!, returnParameter.type, parameterList);
      if (returnParameter.type != ValueType.void_type) {
        method.body.add(DefineParameter.copy(returnParameter, null));
        method.body.add(code!);
        method.body.add(Return(Plain(returnParameter.name)));
      } else {
        method.body.add(code!);
      }

      program.start = method;
    }

    return program.toCode(0);
  }
}
