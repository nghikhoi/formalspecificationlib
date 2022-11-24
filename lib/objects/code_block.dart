import 'package:testdart/objects/expressions.dart';

abstract class CodeBlock {}

abstract class Definition {}

enum ValueType {
  int,
  double,
  string,
  bool,
  list,
  map,
  object,
}

class Parameter {
  final String name;
  final ValueType type;

  Parameter(this.name, this.type);
}

class Method extends Definition {
  final String name;
  final ValueType returnType;
  final List<Parameter> parameters;
  final List<CodeBlock> body;

  Method(this.name, this.returnType, this.parameters, this.body);
}

class If extends CodeBlock {
  final BooleanExpression condition;
  final List<CodeBlock> body;
  final List<CodeBlock> elseBody;

  If(this.condition, this.body, this.elseBody);
}
