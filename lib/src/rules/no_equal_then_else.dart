import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoEqualThenElseRule extends AnalysisRule {
  NoEqualThenElseRule()
    : super(
        name: 'no_equal_then_else',
        description: 'Warn when if-else branches are equal.',
      );

  static const code = LintCode(
    'no_equal_then_else',
    'Then and else branches are equal.',
    correctionMessage: 'Remove the redundant conditional.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.no_equal_then_else',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addIfStatement(this, _IfVisitor(this))
      ..addConditionalExpression(this, _ConditionalVisitor(this));
  }
}

class _IfVisitor extends SimpleAstVisitor<void> {
  _IfVisitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitIfStatement(IfStatement node) {
    final Statement? elseStatement = node.elseStatement;
    if (elseStatement != null &&
        elseStatement is! IfStatement &&
        node.thenStatement.toString() == elseStatement.toString()) {
      rule.reportAtNode(node);
    }
  }
}

class _ConditionalVisitor extends SimpleAstVisitor<void> {
  _ConditionalVisitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (node.thenExpression.toString() == node.elseExpression.toString()) {
      rule.reportAtNode(node);
    }
  }
}
