class ExpressionContext {
  Map<String, dynamic> variables = {};
}

abstract class Expression {
  dynamic calculate(ExpressionContext context);

  Expression rehearsal();

  String toCode(int languageCode);
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

class ConstantsExpression implements Expression {
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
}

abstract class MathExpression extends Expression {
  final Expression left;

  final Expression right;

  MathExpression(this.left, this.right);
}

class AddExpression extends MathExpression {
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
}

class SubtractExpression extends MathExpression {
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
}

class MultiplyExpression extends MathExpression {
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
}

class NegateExpression extends Expression {
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
}

class DivideExpression extends MathExpression {
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
}

class ModuloExpression extends MathExpression {
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

class GreaterThanExpression extends BooleanExpression {
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
}

class GreaterThanEqualExpression extends BooleanExpression {
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
}

class LessThanExpression extends BooleanExpression {
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
}

class LessThanEqualExpression extends BooleanExpression {
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
}

class EqualExpression extends BooleanExpression {
  final Expression left;

  final Expression right;

  EqualExpression(this.left, this.right);

  @override
  bool calculateBoolean(ExpressionContext context) {
    return left.calculate(context) == right.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} = ${right.toCode(languageCode)}';
  }

  @override
  BooleanExpression rehearsal() {
    return EqualExpression(left.rehearsal(), right.rehearsal());
  }
}

class NotEqualExpression extends BooleanExpression {
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
}

class AssignExpression extends Expression {
  final String variable;

  final Expression expression;

  AssignExpression(this.variable, this.expression);

  @override
  dynamic calculate(ExpressionContext context) {
    context.variables[variable] = expression.calculate(context);
  }

  @override
  String toCode(int languageCode) {
    return '$variable = ${expression.toCode(languageCode)}';
  }

  EqualExpression toEqual() {
    return EqualExpression(VariableExpression(variable), expression);
  }

  @override
  AssignExpression rehearsal() {
    return AssignExpression(variable, expression.rehearsal());
  }
}

class AssignConditionExpression extends BooleanExpression {
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
}

class OrExpression extends BooleanExpression {
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
    if (expressions.any((element) => element is AssignConditionExpression)) {
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
}

class AndExpression extends BooleanExpression {
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

class ForAllExpression extends BooleanExpression {
  final String variable;

  final Expression expression;

  final BooleanExpression condition;

  ForAllExpression(this.variable, this.expression, this.condition);

  @override
  bool calculateBoolean(ExpressionContext context) {
    final list = expression.calculate(context);
    for (var item in list) {
      context.variables[variable] = item;
      if (!condition.calculate(context)) {
        return false;
      }
    }
    return true;
  }

  @override
  String toCode(int languageCode) {
    return 'for (var ${variable} in ${expression.toCode(languageCode)}) {\n \tif (!(${condition.toCode(languageCode)})) {\n \t\treturn false;\n \t}\n}\nreturn true;';
  }

  @override
  BooleanExpression rehearsal() {
    return ForAllExpression(variable, expression.rehearsal(),
        condition.rehearsal() as BooleanExpression);
  }
}

class ForAnyExpression extends BooleanExpression {
  final String variable;

  final Expression expression;

  final BooleanExpression condition;

  ForAnyExpression(this.variable, this.expression, this.condition);

  @override
  bool calculateBoolean(ExpressionContext context) {
    final list = expression.calculate(context);
    for (var item in list) {
      context.variables[variable] = item;
      if (condition.calculate(context)) {
        return true;
      }
    }
    return false;
  }

  @override
  String toCode(int languageCode) {
    return 'for (var ${variable} in ${expression.toCode(languageCode)}) {\n \tif (${condition.toCode(languageCode)}) {\n \t\treturn true;\n \t}\n}\nreturn false;';
  }

  @override
  BooleanExpression rehearsal() {
    return ForAnyExpression(variable, expression.rehearsal(),
        condition.rehearsal() as BooleanExpression);
  }
}
