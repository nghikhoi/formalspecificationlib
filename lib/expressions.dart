class ExpressionContext {
  Map<String, dynamic> variables = {};
}

abstract class Expression {
  dynamic calculate(ExpressionContext context);

  void simplify();

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
  void simplify() {}

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
  void simplify() {}

  @override
  String toCode(int languageCode) {
    return value.toString();
  }
}

abstract class MathExpression extends Expression {
  final Expression left;

  final Expression right;

  MathExpression(this.left, this.right);

  @override
  void simplify() {
    left.simplify();
    right.simplify();
  }
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
}

class NegateExpression extends Expression {
  final Expression expression;

  NegateExpression(this.expression);

  @override
  dynamic calculate(ExpressionContext context) {
    return -expression.calculate(context);
  }

  @override
  void simplify() {
    expression.simplify();
  }

  @override
  String toCode(int languageCode) {
    return '(-${expression.toCode(languageCode)})';
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
}

abstract class BooleanExpression extends Expression {
  @override
  bool calculate(ExpressionContext context) {
    return calculateBoolean(context);
  }

  bool calculateBoolean(ExpressionContext context);
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
  void simplify() {
    left.simplify();
    right.simplify();
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} > ${right.toCode(languageCode)}';
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
  void simplify() {
    left.simplify();
    right.simplify();
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} >= ${right.toCode(languageCode)}';
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
  void simplify() {
    left.simplify();
    right.simplify();
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} < ${right.toCode(languageCode)}';
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
  void simplify() {
    left.simplify();
    right.simplify();
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} <= ${right.toCode(languageCode)}';
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
  void simplify() {
    left.simplify();
    right.simplify();
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} = ${right.toCode(languageCode)}';
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
  void simplify() {
    left.simplify();
    right.simplify();
  }

  @override
  String toCode(int languageCode) {
    return '${left.toCode(languageCode)} != ${right.toCode(languageCode)}';
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
  void simplify() {
    expression.simplify();
  }

  @override
  String toCode(int languageCode) {
    return '$variable = ${expression.toCode(languageCode)}';
  }

  EqualExpression toEqual() {
    return EqualExpression(VariableExpression(variable), expression);
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
  void simplify() {
    assign.simplify();
    expression.simplify();
  }

  @override
  String toCode(int languageCode) {
    return 'if (${expression.toCode(languageCode)}) { ${assign.toCode(languageCode)} }';
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
  void simplify() {
    for (int i = 0; i < expressions.length; i++) {
      final expression = expressions[i];
      expression.simplify();
      if (expression is OrExpression) {
        expressions.removeAt(i);
        expressions.insertAll(i, expression.expressions);
      }
    }
  }

  @override
  String toCode(int languageCode) {
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
  void simplify() {
    for (int i = 0; i < expressions.length; i++) {
      final expression = expressions[i];
      expression.simplify();
      if (expression is AndExpression) {
        expressions.removeAt(i);
        expressions.insertAll(i, expression.expressions);
      }
    }
  }

  @override
  String toCode(int languageCode) {
    return expressions.map((e) => e.toCode(languageCode)).join(' && ');
  }
}
