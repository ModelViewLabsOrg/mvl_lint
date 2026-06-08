import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferEarlyReturnRule extends AnalysisRule {
  PreferEarlyReturnRule()
    : super(
        name: 'prefer_early_return',
        description: 'Prefer early return to reduce nesting.',
      );

  static const code = LintCode(
    'prefer_early_return',
    'Use reverse if to reduce nesting.',
    correctionMessage: 'Invert the condition and return early.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.prefer_early_return',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addBlockFunctionBody(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    if (node.block.statements.isEmpty) {
      return;
    }

    final (List<IfStatement> ifStatements, Statement? nextStatement) = _getStartIfStatements(node);
    if (ifStatements.isEmpty) {
      return;
    }

    final bool nextStatementIsEmptyReturn =
        nextStatement is ReturnStatement && nextStatement.expression == null;
    final nextStatementIsNull = nextStatement == null;

    if (!nextStatementIsEmptyReturn && !nextStatementIsNull) {
      return;
    }

    _handleIfStatement(ifStatements.last);
  }

  void _handleIfStatement(IfStatement node) {
    if (_isElseIfStatement(node)) {
      return;
    }
    if (_hasElseStatement(node)) {
      return;
    }
    if (_hasReturnStatement(node)) {
      return;
    }
    if (_hasThrowExpression(node)) {
      return;
    }

    rule.reportAtNode(node);
  }

  (List<IfStatement>, Statement?) _getStartIfStatements(
    BlockFunctionBody body,
  ) {
    final ifStatements = <IfStatement>[];
    for (final Statement statement in body.block.statements) {
      if (statement is IfStatement) {
        ifStatements.add(statement);
      } else {
        return (ifStatements, statement);
      }
    }
    return (ifStatements, null);
  }

  bool _hasElseStatement(IfStatement node) => node.elseStatement != null;

  bool _isElseIfStatement(IfStatement node) =>
      node.elseStatement != null && node.elseStatement is IfStatement;

  bool _hasReturnStatement(Statement node) {
    final visitor = _ReturnStatementVisitor();
    node.accept(visitor);
    return visitor.nodes.isNotEmpty;
  }

  bool _hasThrowExpression(Statement node) {
    final visitor = _ThrowExpressionVisitor();
    node.accept(visitor);
    return visitor.nodes.isNotEmpty;
  }
}

class _ReturnStatementVisitor extends RecursiveAstVisitor<void> {
  final nodes = <ReturnStatement>[];

  @override
  void visitReturnStatement(ReturnStatement node) {
    nodes.add(node);
    super.visitReturnStatement(node);
  }
}

class _ThrowExpressionVisitor extends RecursiveAstVisitor<void> {
  final nodes = <ThrowExpression>[];

  @override
  void visitThrowExpression(ThrowExpression node) {
    nodes.add(node);
    super.visitThrowExpression(node);
  }
}
