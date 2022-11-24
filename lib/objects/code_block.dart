abstract class CodeBlock {}

abstract class Definition {}

enum ValueType {
  int,
  double,
  string,
  bool,
  int_array,
  double_array,
  bool_array,
  string_array,
  void_type
}

final TYPE_MAP = {
  'z': ValueType.int,
  'n': ValueType.int,
  'n1': ValueType.int,
  'r': ValueType.double,
  'q': ValueType.double,
  'b': ValueType.bool,
  'z*': ValueType.int_array,
  'n*': ValueType.int_array,
  'n1*': ValueType.int_array,
  'r*': ValueType.double_array,
  'q*': ValueType.double_array,
  'b*': ValueType.bool_array,
  'char*': ValueType.string,
};

class Parameter extends CodeBlock {
  final String name;
  final ValueType type;

  Parameter(this.name, this.type);
}

class ReadParameter extends CodeBlock {
  final Parameter parameter;

  ReadParameter(this.parameter);
}

class Negate extends CodeBlock {
  final CodeBlock code;

  Negate(this.code);
}

class Constant extends CodeBlock {
  final ValueType type;
  final dynamic value;

  Constant(this.type, this.value);
}

class Plain extends CodeBlock {
  final String text;

  Plain(this.text);
}

class Return extends CodeBlock {
  final CodeBlock code;

  Return(this.code);
}

class Variable extends CodeBlock {
  final String name;

  Variable(this.name);
}

class Caller extends CodeBlock {
  final String name;
  final List<CodeBlock> arguments;

  Caller(this.name, this.arguments);
}

class Assign extends CodeBlock {
  final String name;
  final CodeBlock code;

  Assign(this.name, this.code);
}

class Method extends CodeBlock {
  final String name;
  final ValueType returnType;
  final List<Parameter> parameters;
  final List<CodeBlock> body;

  Method(this.name, this.returnType, this.parameters) : body = <CodeBlock>[];
}

class If extends CodeBlock {
  final CodeBlock condition;
  final List<CodeBlock> body;
  final List<CodeBlock> elseBody;

  If(this.condition)
      : this.body = <CodeBlock>[],
        this.elseBody = <CodeBlock>[];
}

class For extends CodeBlock {
  final String name;
  final CodeBlock start;
  final CodeBlock end;
  final List<CodeBlock> body;

  For(this.name, this.start, this.end) : this.body = <CodeBlock>[];
}
