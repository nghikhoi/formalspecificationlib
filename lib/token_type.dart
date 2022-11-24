import 'package:testdart/expressions.dart';

class TokenType {
  final String token;
  final int priority;
  final int inputs;
  final Expression Function(List<Expression> inputs) creator;

  TokenType(this.token, this.priority, this.inputs, this.creator);

  @override
  String toString() {
    return token;
  }
}

TokenType LEFT_PAREN = TokenType('(', 0, 0, (inputs) {
  throw Exception('Left paren should not be used in expression');
});

TokenType EQUAL = TokenType('=', 1, 2, (inputs) {
  var left = inputs[1];
  var right = inputs[0];
  if (left is VariableExpression) {
    return AssignExpression(left.name, right);
  }
  return EqualExpression(left, right);
});

TokenType PLUS = TokenType('+', 4, 2, (inputs) {
  return AddExpression(inputs[1], inputs[0]);
});

TokenType MINUS = TokenType('-', 4, 2, (inputs) {
  return SubtractExpression(inputs[1], inputs[0]);
});

TokenType MULTIPLY = TokenType('*', 5, 2, (inputs) {
  return MultiplyExpression(inputs[1], inputs[0]);
});

TokenType NEGATE = TokenType('-1*', 5, 1, (inputs) {
  return NegateExpression(inputs[0]);
});

TokenType DIVIDE = TokenType('/', 5, 2, (inputs) {
  return DivideExpression(inputs[1], inputs[0]);
});

TokenType MOD =
    TokenType('%', 5, 2, (inputs) => ModuloExpression(inputs[1], inputs[0]));

TokenType GREATER_THAN = TokenType('>', 3, 2, (inputs) {
  return GreaterThanExpression(inputs[1], inputs[0]);
});

TokenType LESS_THAN = TokenType('<', 3, 2, (inputs) {
  return LessThanExpression(inputs[1], inputs[0]);
});

TokenType GREATER_THAN_EQUAL = TokenType('>=', 3, 2, (inputs) {
  return GreaterThanEqualExpression(inputs[1], inputs[0]);
});

TokenType LESS_THAN_EQUAL = TokenType('<=', 3, 2, (inputs) {
  return LessThanEqualExpression(inputs[1], inputs[0]);
});

TokenType NOT_EQUAL = TokenType('!=', 3, 2, (inputs) {
  return NotEqualExpression(inputs[1], inputs[0]);
});

TokenType OR = TokenType('||', 2, 2, (inputs) {
  var left = inputs[1];
  var right = inputs[0];
  if (left is! BooleanExpression) {
    throw Exception('Invalid left operand for OR');
  }
  if (right is! BooleanExpression) {
    throw Exception('Invalid right operand for OR');
  }
  return OrExpression.simple(left, right);
});

TokenType AND = TokenType('&&', 2, 2, (inputs) {
  var left = inputs[1];
  var right = inputs[0];
  if (left is AssignExpression) {
    if (right is BooleanExpression) {
      return AssignConditionExpression(left, right);
    }
    throw Exception('Invalid right operand for AssignConditionExpression');
  }
  if (left is! BooleanExpression) {
    throw Exception('Invalid left operand for AND');
  }
  if (right is! BooleanExpression) {
    throw Exception('Invalid right operand for AND');
  }
  return AndExpression.simple(left, right);
});

Map<String, TokenType> TOKEN_TYPES = {
  '(': LEFT_PAREN,
  '=': EQUAL,
  '+': PLUS,
  '-': MINUS,
  '*': MULTIPLY,
  '-1*': NEGATE,
  '/': DIVIDE,
  '%': MOD,
  '>': GREATER_THAN,
  '<': LESS_THAN,
  '>=': GREATER_THAN_EQUAL,
  '<=': LESS_THAN_EQUAL,
  '!=': NOT_EQUAL,
  '||': OR,
  '&&': AND,
  '∀': FORALL,
  '∃': EXISTS,
};
