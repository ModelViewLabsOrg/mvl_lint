import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:mvl_lint/src/utils/types_utils.dart';

class PreferLastRule extends AnalysisRule {
  PreferLastRule()
    : super(
        name: 'prefer_last',
        description: 'Prefer last instead of elementAt(length - 1).',
      );

  static const code = LintCode(
    'prefer_last',
    'Use last instead of accessing the last element by index.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.prefer_last',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addMethodInvocation(this, _MethodVisitor(this))
      ..addIndexExpression(this, _IndexVisitor(this));
  }
}

class _MethodVisitor extends SimpleAstVisitor<void> {
  _MethodVisitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final Expression? target = node.realTarget;
    if (!isIterableOrSubclass(target?.staticType)) {
      return;
    }
    if (node.methodName.name != 'elementAt') {
      return;
    }

    final NodeList<Argument> arguments = node.argumentList.arguments;
    if (arguments.isEmpty) {
      return;
    }
    final Argument arg = arguments.first;
    if (arg is BinaryExpression && _isLastElementAccess(arg, target.toString())) {
      rule.reportAtNode(node);
    }
  }
}

class _IndexVisitor extends SimpleAstVisitor<void> {
  _IndexVisitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitIndexExpression(IndexExpression node) {
    final Expression target = node.realTarget;
    if (!isListOrSubclass(target.staticType)) {
      return;
    }

    final Expression index = node.index;
    if (index is BinaryExpression && _isLastElementAccess(index, target.toString())) {
      rule.reportAtNode(node);
    }
  }
}

bool _isLastElementAccess(BinaryExpression expression, String targetName) {
  final Expression left = expression.leftOperand;
  final Expression right = expression.rightOperand;
  final String? leftName = _getLeftOperandName(left);

  if (right is! IntegerLiteral) {
    return false;
  }
  if (right.value != 1) {
    return false;
  }
  if (expression.operator.type != TokenType.MINUS) {
    return false;
  }

  return leftName == '$targetName.length';
}

String? _getLeftOperandName(Expression expression) {
  if (expression is PrefixedIdentifier) {
    return expression.name;
  }

  if (expression is PropertyAccess) {
    if (expression.operator.type != TokenType.PERIOD) {
      return null;
    }
    return expression.toString();
  }

  return null;
}
