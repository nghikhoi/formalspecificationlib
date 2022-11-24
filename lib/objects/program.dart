import 'package:testdart/objects/code_block.dart';

class Program {
  List<Method> methods = <Method>[];
  Method? validate;
  Method? start;

  String nextMethodName() {
    return 'TempMethod${methods.length}';
  }

  final TYPE_NAMES = {
    ValueType.bool: 'bool',
    ValueType.int: 'int',
    ValueType.double: 'double',
    ValueType.string: 'string',
    ValueType.int_array: 'int[]',
    ValueType.double_array: 'double[]',
    ValueType.bool_array: 'bool[]',
    ValueType.string_array: 'string[]',
    ValueType.void_type: 'void',
  };

  final TYPE_DEFAULT_VALUES = {
    ValueType.bool: 'false',
    ValueType.int: '0',
    ValueType.double: '0.0',
    ValueType.string: '""',
    ValueType.int_array: 'new int[0]',
    ValueType.double_array: 'new double[0]',
    ValueType.bool_array: 'new bool[0]',
    ValueType.string_array: 'new string[0]',
    ValueType.void_type: '',
  };

  String _toReadCode(ReadParameter read, [int level = 0]) {
    String tab = '';
    for (int i = 0; i < level; i++) {
      tab += '\t';
    }
    String result = '';
    if (read.parameter.type == ValueType.bool) {
      result +=
          '${tab}${read.parameter.name} = Boolean.Parse(Console.ReadLine());\n';
    } else if (read.parameter.type == ValueType.int) {
      result +=
          '${tab}${read.parameter.name} = Int32.Parse(Console.ReadLine());\n';
    } else if (read.parameter.type == ValueType.double) {
      result +=
          '${tab}${read.parameter.name} = Double.Parse(Console.ReadLine());\n';
    } else if (read.parameter.type == ValueType.string) {
      result += '${tab}${read.parameter.name} = Console.ReadLine();\n';
    } else if (read.parameter.type == ValueType.int_array) {
      result +=
          '${tab}String[] ${read.parameter.name}Str = Console.ReadLine().Split(\' \');\n';
      result +=
          '${tab}${read.parameter.name} = new int[${read.parameter.name}Str.Length];\n';
      result +=
          '${tab}for (int i = 0; i < ${read.parameter.name}Str.Length; i++) {\n';
      result +=
          '${tab}\t${read.parameter.name}[i] = Int32.Parse(${read.parameter.name}Str[i]);\n';
      result += '${tab}}\n';
    } else if (read.parameter.type == ValueType.double_array) {
      result +=
          '${tab}String[] ${read.parameter.name}Str = Console.ReadLine().Split(\' \');\n';
      result +=
          '${tab}${read.parameter.name} = new double[${read.parameter.name}Str.Length];\n';
      result +=
          '${tab}for (int i = 0; i < ${read.parameter.name}Str.Length; i++) {\n';
      result +=
          '${tab}\t${read.parameter.name}[i] = Double.Parse(${read.parameter.name}Str[i]);\n';
      result += '${tab}}\n';
    } else if (read.parameter.type == ValueType.bool_array) {
      result +=
          '${tab}String[] ${read.parameter.name}Str = Console.ReadLine().Split(\' \');\n';
      result +=
          '${tab}${read.parameter.name} = new bool[${read.parameter.name}Str.Length];\n';
      result +=
          '${tab}for (int i = 0; i < ${read.parameter.name}Str.Length; i++) {\n';
      result +=
          '${tab}\t${read.parameter.name}[i] = Boolean.Parse(${read.parameter.name}Str[i]);\n';
      result += '${tab}}\n';
    }
    return result;
  }

  String _toCode(CodeBlock block, [int level = 0]) {
    String tab = '';
    for (int i = 0; i < level; i++) {
      tab += '\t';
    }
    String result = '';
    if (block is Method) {
      String code = '';
      for (var child in block.body) {
        code += _toCode(child, level + 1);
        if (!(child is If || child is For || child is ReadParameter)) {
          code += ';';
        }
        code += '\n';
      }
      String parameters = '';
      for (var parameter in block.parameters) {
        parameters += '${TYPE_NAMES[parameter.type]} ${parameter.name}, ';
      }
      if (parameters.isNotEmpty) {
        parameters = parameters.substring(0, parameters.length - 2);
      }
      result =
          '${tab}public static ${TYPE_NAMES[block.returnType]} ${block.name}($parameters) {\n$code${tab}}';
    } else if (block is If) {
      String code = '';
      for (var child in block.body) {
        code += _toCode(child, level + 1);
        if (!(child is If || child is For || child is ReadParameter)) {
          code += ';';
        }
        code += '\n';
      }
      result = '${tab}if (${_toCode(block.condition)}) {\n$code$tab}';
      if (block.elseBody.isNotEmpty) {
        code = '';
        for (var child in block.elseBody) {
          code += _toCode(child, level + 1);
          if (!(child is If || child is For || child is ReadParameter)) {
            code += ';';
          }
          code += '\n';
        }
        result += ' else {\n$code$tab}';
      }
    } else if (block is For) {
      String code = '';
      for (var child in block.body) {
        code += _toCode(child, level + 1);
        if (!(child is If || child is For)) {
          code += ';';
        }
        code += '\n';
      }
      result =
          '${tab}for (int ${block.name} = ${_toCode(block.start)} - 1; ${block.name} <= ${_toCode(block.end)} - 1; ${block.name}++) {\n$code$tab}';
    } else if (block is Return) {
      result = '${tab}return ${_toCode(block.code)}';
    } else if (block is ReturnVoid) {
      result = '${tab}return';
    } else if (block is Caller) {
      result =
          '$tab${block.name}(${block.arguments.map((e) => _toCode(e)).join(', ')})';
    } else if (block is Assign) {
      result = '$tab${block.name} = ${_toCode(block.code)}';
    } else if (block is Constant) {
      if (block.type == ValueType.int) {
        result = '$tab${block.value}';
      } else if (block.type == ValueType.double) {
        result = '$tab${block.value}';
      } else if (block.type == ValueType.string) {
        result = '$tab"${block.value}"';
      } else if (block.type == ValueType.bool) {
        result = '$tab${block.value.toString().toLowerCase()}';
      }
    } else if (block is DefineParameter) {
      var value = block.value ?? TYPE_DEFAULT_VALUES[block.type];
      result = '$tab${TYPE_NAMES[block.type]} ${block.name} = $value';
    } else if (block is Parameter) {
      result = '$tab${TYPE_NAMES[block.type]} ${block.name}';
    } else if (block is Negate) {
      result = '$tab!(${_toCode(block.code)})';
    } else if (block is Plain) {
      result = '$tab${block.text}';
    } else if (block is ReadParameter) {
      result = '$tab${_toCode(DefineParameter.copy(block.parameter, null))};\n';
      result += _toReadCode(block, level);
    } else if (block is Variable) {
      result = '$tab${block.name}';
    }
    return result;
  }

  String toCode(int language) {
    var methods = <Method>[];
    methods.addAll(this.methods);

    if (start != null) {
      methods.add(start!);

      Method main = Method('Main', ValueType.void_type,
          [Parameter('args', ValueType.string_array)]);

      for (var element in start!.parameters) {
        main.body.add(ReadParameter(element));
      }

      if (validate != null) {
        methods.add(validate!);
        var ifBlock = If(Negate(Caller(validate!.name,
            validate!.parameters.map((e) => Variable(e.name)).toList())));
        ifBlock.body.add(Caller('Console.WriteLine',
            [Constant(ValueType.string, 'Invalid input')]));
        ifBlock.body.add(ReturnVoid());
        main.body.add(ifBlock);
      }

      main.body.add(
          Caller('Console.Write', [Constant(ValueType.string, 'Result: ')]));
      main.body.add(Caller('Console.WriteLine', [
        Caller(start!.name,
            start!.parameters.map((e) => Variable(e.name)).toList())
      ]));

      methods.add(main);
    }

    String code = '';
    for (var method in methods) {
      code += '${_toCode(method, 1)}\n';
    }
    String result = 'using System;\n\npublic class Program {\n$code}';

    return result;
  }
}
