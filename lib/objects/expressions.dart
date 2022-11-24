import 'package:testdart/objects/code_block.dart';
import 'package:testdart/objects/program.dart';

class ExpressionContext {
  Map<String, dynamic> variables = {};
  Map<String, ValueType> variableTypes = {};
}

abstract class CodeBlockExpression {
  CodeBlock? toCodeBlock(Program program, ExpressionContext context);
}

abstract class Expression {
  dynamic calculate(ExpressionContext context);

  Expression rehearsal();

  String toCode(int languageCode);
}

abstract class UnityExpression {
  List<Expression> get expressions;
}

class VariableExpression implements Expression {
  final String name;

  VariableExpression(this.name);

  @override
  dynamic calculate(ExpressionContext context) {
    return context.variables[name];
  }

  @override
  Expression rehearsal() {
    return this;
  }

  @override
  String toCode(int languageCode) {
    return name;
  }
}

class ArrayAccessExpression implements Expression, UnityExpression {
  final VariableExpression array;
  final Expression index;

  ArrayAccessExpression(this.array, this.index);

  @override
  dynamic calculate(ExpressionContext context) {
    return array.calculate(context)[index.calculate(context)];
  }

  @override
  Expression rehearsal() {
    return this;
  }

  @override
  String toCode(int languageCode) {
    return '${array.toCode(languageCode)}[${index.toCode(languageCode)}]';
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [array, index];
}

class ConstantsExpression implements Expression, CodeBlockExpression {
  final dynamic value;

  ConstantsExpression(this.value);

  @override
  dynamic calculate(ExpressionContext context) {
    return value;
  }

  @override
  Expression rehearsal() {
    return this;
  }

  @override
  String toCode(int languageCode) {
    return value.toString();
  }

  @override
  CodeBlock toCodeBlock(Program program, ExpressionContext context) {
    if (value is String) {
      return Constant(ValueType.string, value);
    } else if (value is int) {
      return Constant(ValueType.int, value);
    } else if (value is double) {
      return Constant(ValueType.double, value);
    } else if (value is bool) {
      return Constant(ValueType.bool, value);
    } else {
      return Plain('null');
    }
  }
}

abstract class MathExpression extends Expression {
  final Expression left;

  final Expression right;

  MathExpression(this.left, this.right);
}

class AddExpression extends MathExpression implements UnityExpression {
  AddExpression(Expression left, Expression right) : super(left, right);

  @override
  dynamic calculate(ExpressionContext context) {
    return left.calculate(context) + right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '(${left.toCode(languageCode)} + ${right.toCode(languageCode)})';
  }

  @override
  Expression rehearsal() {
    return AddExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  List<Expression> get expressions => [left, right];
}

class SubtractExpression extends MathExpression implements UnityExpression {
  SubtractExpression(Expression left, Expression right) : super(left, right);

  @override
  dynamic calculate(ExpressionContext context) {
    return left.calculate(context) - right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '(${left.toCode(languageCode)} - ${right.toCode(languageCode)})';
  }

  @override
  Expression rehearsal() {
    return SubtractExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

class MultiplyExpression extends MathExpression implements UnityExpression {
  MultiplyExpression(Expression left, Expression right) : super(left, right);

  @override
  dynamic calculate(ExpressionContext context) {
    return left.calculate(context) * right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '(${left.toCode(languageCode)} * ${right.toCode(languageCode)})';
  }

  @override
  Expression rehearsal() {
    return MultiplyExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

class NegateExpression extends Expression implements UnityExpression {
  final Expression expression;

  NegateExpression(this.expression);

  @override
  dynamic calculate(ExpressionContext context) {
    return -expression.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '(-${expression.toCode(languageCode)})';
  }

  @override
  Expression rehearsal() {
    return NegateExpression(expression.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [expression];
}

class DivideExpression extends MathExpression implements UnityExpression {
  DivideExpression(Expression left, Expression right) : super(left, right);

  @override
  dynamic calculate(ExpressionContext context) {
    return left.calculate(context) / right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '(${left.toCode(languageCode)} / ${right.toCode(languageCode)})';
  }

  @override
  Expression rehearsal() {
    return DivideExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

class ModuloExpression extends MathExpression implements UnityExpression {
  ModuloExpression(Expression left, Expression right) : super(left, right);

  @override
  dynamic calculate(ExpressionContext context) {
    return left.calculate(context) % right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '(${left.toCode(languageCode)} % ${right.toCode(languageCode)})';
  }

  @override
  Expression rehearsal() {
    return ModuloExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

abstract class BooleanExpression extends Expression {
  @override
  bool calculate(ExpressionContext context) {
    return calculateBoolean(context);
  }

  bool calculateBoolean(ExpressionContext context);

  @override
  BooleanExpression rehearsal() {
    return this;
  }
}

class GreaterThanExpression extends BooleanExpression
    implements UnityExpression {
  final Expression left;

  final Expression right;

  GreaterThanExpression(this.left, this.right);

  @override
  bool calculateBoolean(ExpressionContext context) {
    return left.calculate(context) > right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} > ${right.toCode(languageCode)}';
  }

  @override
  BooleanExpression rehearsal() {
    return GreaterThanExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

class GreaterThanEqualExpression extends BooleanExpression
    implements UnityExpression {
  final Expression left;

  final Expression right;

  GreaterThanEqualExpression(this.left, this.right);

  @override
  bool calculateBoolean(ExpressionContext context) {
    return left.calculate(context) >= right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} >= ${right.toCode(languageCode)}';
  }

  @override
  BooleanExpression rehearsal() {
    return GreaterThanEqualExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

class LessThanExpression extends BooleanExpression implements UnityExpression {
  final Expression left;

  final Expression right;

  LessThanExpression(this.left, this.right);

  @override
  bool calculateBoolean(ExpressionContext context) {
    return left.calculate(context) < right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} < ${right.toCode(languageCode)}';
  }

  @override
  BooleanExpression rehearsal() {
    return LessThanExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

class LessThanEqualExpression extends BooleanExpression
    implements UnityExpression {
  final Expression left;

  final Expression right;

  LessThanEqualExpression(this.left, this.right);

  @override
  bool calculateBoolean(ExpressionContext context) {
    return left.calculate(context) <= right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} <= ${right.toCode(languageCode)}';
  }

  @override
  BooleanExpression rehearsal() {
    return LessThanEqualExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

class EqualExpression extends BooleanExpression implements UnityExpression {
  final Expression left;

  final Expression right;

  EqualExpression(this.left, this.right);

  @override
  bool calculateBoolean(ExpressionContext context) {
    return left.calculate(context) == right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} == ${right.toCode(languageCode)}';
  }

  @override
  BooleanExpression rehearsal() {
    return EqualExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

class NotEqualExpression extends BooleanExpression implements UnityExpression {
  final Expression left;

  final Expression right;

  NotEqualExpression(this.left, this.right);

  @override
  bool calculateBoolean(ExpressionContext context) {
    return left.calculate(context) != right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} != ${right.toCode(languageCode)}';
  }

  @override
  BooleanExpression rehearsal() {
    return NotEqualExpression(left.rehearsal(), right.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [left, right];
}

class NotExpression extends BooleanExpression implements UnityExpression {
  final BooleanExpression expression;

  NotExpression(this.expression);

  @override
  bool calculateBoolean(ExpressionContext context) {
    return !expression.calculateBoolean(context);
  }

  @override
  String toCode(int languageCode) {
    return '!(${expression.toCode(languageCode)})';
  }

  @override
  BooleanExpression rehearsal() {
    return NotExpression(expression.rehearsal());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [expression];
}

class AssignExpression extends Expression
    implements CodeBlockExpression, UnityExpression {
  final VariableExpression variable;

  final Expression expression;

  AssignExpression(this.variable, this.expression);

  @override
  dynamic calculate(ExpressionContext context) {
    context.variables[variable.name] = expression.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '$variable = ${expression.toCode(languageCode)}';
  }

  EqualExpression toEqual() {
    return EqualExpression(variable, expression);
  }

  @override
  AssignExpression rehearsal() {
    return AssignExpression(variable, expression.rehearsal());
  }

  @override
  Assign toCodeBlock(Program program, ExpressionContext context) {
    var code = expression is CodeBlockExpression
        ? (expression as CodeBlockExpression).toCodeBlock(program, context)
        : Plain(expression.toCode(0));
    return Assign(variable.name, code!);
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [expression];
}

class AssignConditionExpression extends BooleanExpression
    implements CodeBlockExpression, UnityExpression {
  final AssignExpression assign;

  final BooleanExpression expression;

  AssignConditionExpression(this.assign, this.expression);

  AssignConditionExpression.equal(this.assign, AssignExpression temp)
      : expression = temp.toEqual();

  @override
  bool calculateBoolean(ExpressionContext context) {
    if (expression.calculate(context)) {
      assign.calculate(context);
      return true;
    }
    return false;
  }

  @override
  String toCode(int languageCode) {
    return 'if (${expression.toCode(languageCode)}) {\n \t${assign.toCode(languageCode)}\n}\n';
  }

  @override
  BooleanExpression rehearsal() {
    return AssignConditionExpression(
        assign.rehearsal(), expression.rehearsal());
  }

  @override
  If toCodeBlock(Program program, ExpressionContext context) {
    var code = expression is CodeBlockExpression
        ? (expression as CodeBlockExpression).toCodeBlock(program, context)
        : Plain(expression.toCode(0));
    var result = If(code!);
    result.body.add(assign.toCodeBlock(program, context));
    return result;
  }

  @override
  List<Expression> get expressions => [assign, expression];
}

class OrExpression extends BooleanExpression
    implements CodeBlockExpression, UnityExpression {
  @override
  final List<BooleanExpression> expressions;

  OrExpression(this.expressions);

  OrExpression.simple(BooleanExpression left, BooleanExpression right)
      : expressions = [left, right];

  @override
  bool calculateBoolean(ExpressionContext context) {
    for (var expression in expressions) {
      if (expression.calculate(context)) {
        return true;
      }
    }
    return false;
  }

  @override
  BooleanExpression rehearsal() {
    for (int i = 0; i < expressions.length; i++) {
      final expression = expressions[i].rehearsal();
      if (expression is OrExpression) {
        expressions.removeAt(i);
        expressions.insertAll(i, expression.expressions);
      } else {
        expressions[i] = expression.rehearsal();
      }
    }
    return this;
  }

  @override
  String toCode(int languageCode) {
    if (expressions.every((element) => element is AssignConditionExpression)) {
      var code = '';
      var temp = '';
      for (var expression in expressions) {
        if (expression is AssignConditionExpression) {
          code += expression.toCode(languageCode);
        } else {
          code +=
              'if (${expression.toCode(languageCode)}) {\n \treturn true;\n}\n';
        }
      }
      return code;
    }
    return expressions.map((e) => e.toCode(languageCode)).join(' || ');
  }

  @override
  CodeBlock? toCodeBlock(Program program, ExpressionContext context) {
    if (expressions.every((element) => element is AssignConditionExpression)) {
      var head = (expressions[0] as AssignConditionExpression)
          .toCodeBlock(program, context);
      var temp = head;
      for (int i = 1; i < expressions.length; i++) {
        final expression = expressions[i] as AssignConditionExpression;
        final next = expression.toCodeBlock(program, context);
        temp.elseBody.add(next);
        temp = next;
      }
      return head;
    } else {
      return Plain(toCode(0));
    }
  }
}

class AndExpression extends BooleanExpression implements UnityExpression {
  @override
  final List<BooleanExpression> expressions;

  AndExpression(this.expressions);

  AndExpression.simple(BooleanExpression left, BooleanExpression right)
      : expressions = [left, right];

  @override
  bool calculateBoolean(ExpressionContext context) {
    for (var expression in expressions) {
      if (!expression.calculate(context)) {
        return false;
      }
    }
    return true;
  }

  @override
  BooleanExpression rehearsal() {
    if (this.expressions[0] is AssignConditionExpression) {
      final assign = this.expressions[0] as AssignConditionExpression;
      final condition = <BooleanExpression>[assign.expression];
      for (int i = 1; i < expressions.length; i++) {
        final expression = expressions[i];
        condition.add(expression);
      }
      return AssignConditionExpression(
          assign.assign, AndExpression(condition).rehearsal());
    }
    for (int i = 0; i < expressions.length; i++) {
      final expression = expressions[i].rehearsal();
      if (expression is AndExpression) {
        expressions.removeAt(i);
        expressions.insertAll(i, expression.expressions);
      } else {
        expressions[i] = expression;
      }
    }
    return this;
  }

  @override
  String toCode(int languageCode) {
    if (expressions.any((element) => element is AssignConditionExpression)) {
      var code = '';
      var temp = '';
      for (var expression in expressions) {
        if (expression is AssignConditionExpression) {
          code += expression.toCode(languageCode);
        } else {
          code +=
              'if (!(${expression.toCode(languageCode)})) {\n \treturn false;\n}\n';
        }
      }
      return code;
    }
    return expressions.map((e) => e.toCode(languageCode)).join(' && ');
  }
}

class ForAllExpression extends BooleanExpression
    implements CodeBlockExpression, UnityExpression {
  final VariableExpression variable;

  final Expression start;

  final Expression end;

  final BooleanExpression condition;

  ForAllExpression(this.variable, this.start, this.end, this.condition);

  @override
  bool calculateBoolean(ExpressionContext context) {
    final startValue = start.calculate(context);
    final endValue = end.calculate(context);
    for (var i = startValue; i <= endValue; i++) {
      context.variables[variable.name] = i;
      if (!condition.calculate(context)) {
        return false;
      }
    }
    return true;
  }

  @override
  String toCode(int languageCode) {
    return 'for (int $variable = ${start.toCode(languageCode)}; $variable <= ${end.toCode(languageCode)}; $variable++) {\n \tif (!(${condition.toCode(languageCode)})) {\n \t\treturn false;\n \t}\n}\nreturn true;';
  }

  @override
  ForAllExpression rehearsal() {
    return ForAllExpression(
        variable, start.rehearsal(), end.rehearsal(), condition.rehearsal());
  }

  @override
  Caller toCodeBlock(Program program, ExpressionContext context) {
    var stack = [start, end, condition];
    var args = <String>{};

    var toRemoved = <String>{variable.name};

    while (stack.isNotEmpty) {
      var expression = stack.removeLast();
      if (expression is VariableExpression) {
        args.add(expression.name);
      } else if (expression is UnityExpression) {
        stack.addAll((expression as UnityExpression).expressions);
        if (expression is ForAllExpression) {
          toRemoved.add(expression.variable.name);
        } else if (expression is ForAnyExpression) {
          toRemoved.add(expression.variable.name);
        }
      }
    }

    for (var element in toRemoved) {
      args.remove(element);
    }
    var parameters =
        args.map((e) => Parameter(e, context.variableTypes[e]!)).toList();

    context.variableTypes[variable.name] = ValueType.int;
    context.variables[variable.name] = 0;

    var startBlock = start is CodeBlockExpression
        ? (start as CodeBlockExpression).toCodeBlock(program, context)
        : Plain(start.toCode(0));
    var endBlock = end is CodeBlockExpression
        ? (end as CodeBlockExpression).toCodeBlock(program, context)
        : Plain(end.toCode(0));

    var code = condition is CodeBlockExpression
        ? (condition as CodeBlockExpression).toCodeBlock(program, context)
        : Plain(condition.toCode(0));

    context.variableTypes.remove(variable.name);
    context.variables.remove(variable.name);

    var ifBlock = If(Negate(code!));
    ifBlock.body.add(Return(Constant(ValueType.bool, false)));

    var forBlock = For(variable.name, startBlock!, endBlock!);
    forBlock.body.add(ifBlock);

    var method = Method(program.nextMethodName(), ValueType.bool, parameters);
    method.body.add(forBlock);
    method.body.add(Return(Constant(ValueType.bool, true)));

    program.methods.add(method);

    return Caller(method.name, args.map((e) => Variable(e)).toList());
  }

  @override
  // TODO: implement expressions
  List<Expression> get expressions => [start, end, condition];
}

class ForAnyExpression extends BooleanExpression
    implements CodeBlockExpression, UnityExpression {
  final VariableExpression variable;

  final Expression start;

  final Expression end;

  final BooleanExpression condition;

  ForAnyExpression(this.variable, this.start, this.end, this.condition);

  @override
  bool calculateBoolean(ExpressionContext context) {
    final startValue = start.calculate(context);
    final endValue = end.calculate(context);
    for (var i = startValue; i <= endValue; i++) {
      context.variables[variable.name] = i;
      if (condition.calculate(context)) {
        return true;
      }
    }
    return false;
  }

  @override
  String toCode(int languageCode) {
    return 'for (int $variable = ${start.toCode(languageCode)}; $variable <= ${end.toCode(languageCode)}; $variable++) {\n \tif (${condition.toCode(languageCode)}) {\n \t\treturn true;\n \t}\n}\nreturn false;';
  }

  @override
  ForAnyExpression rehearsal() {
    return ForAnyExpression(
        variable, start.rehearsal(), end.rehearsal(), condition.rehearsal());
  }

  @override
  Caller toCodeBlock(Program program, ExpressionContext context) {
    var stack = [start, end, condition];
    var args = <String>{};

    var toRemoved = <String>{variable.name};

    while (stack.isNotEmpty) {
      var expression = stack.removeLast();
      if (expression is VariableExpression) {
        args.add(expression.name);
      } else if (expression is UnityExpression) {
        stack.addAll((expression as UnityExpression).expressions);
        if (expression is ForAllExpression) {
          toRemoved.add(expression.variable.name);
        } else if (expression is ForAnyExpression) {
          toRemoved.add(expression.variable.name);
        }
      }
    }

    for (var element in toRemoved) {
      args.remove(element);
    }
    var parameters =
        args.map((e) => Parameter(e, context.variableTypes[e]!)).toList();

    context.variableTypes[variable.name] = ValueType.int;
    context.variables[variable.name] = 0;

    var startBlock = start is CodeBlockExpression
        ? (start as CodeBlockExpression).toCodeBlock(program, context)
        : Plain(start.toCode(0));
    var endBlock = end is CodeBlockExpression
        ? (end as CodeBlockExpression).toCodeBlock(program, context)
        : Plain(end.toCode(0));

    var code = condition is CodeBlockExpression
        ? (condition as CodeBlockExpression).toCodeBlock(program, context)
        : Plain(condition.toCode(0));

    context.variableTypes.remove(variable.name);
    context.variables.remove(variable.name);

    var ifBlock = If(code!);
    ifBlock.body.add(Return(Constant(ValueType.bool, true)));

    var forBlock = For(variable.name, startBlock!, endBlock!);
    forBlock.body.add(ifBlock);

    var method = Method(program.nextMethodName(), ValueType.bool, parameters);
    method.body.add(forBlock);
    method.body.add(Return(Constant(ValueType.bool, false)));

    program.methods.add(method);

    return Caller(method.name, args.map((e) => Variable(e)).toList());
  }

  @override
  List<Expression> get expressions => [start, end, condition];
}
