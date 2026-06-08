import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';
import 'package:mvl_lint/src/utils/expression_identifiers_visitor.dart';

class AvoidUnnecessaryReturnVariableRule extends AnalysisRule {
  AvoidUnnecessaryReturnVariableRule()
    : super(
        name: 'avoid_unnecessary_return_variable',
        description: 'Avoid creating a variable only to return it immediately.',
      );

  static const code = LintCode(
    'avoid_unnecessary_return_variable',
    'Avoid creating unnecessary variable only for return.',
    correctionMessage: 'Rewrite the variable evaluation into the return statement instead.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_unnecessary_return_variable',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addReturnStatement(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitReturnStatement(ReturnStatement node) {
    final Expression? expr = node.expression;
    if (expr is! SimpleIdentifier) {
      return;
    }

    final Element? element = expr.element;
    if (element is! LocalVariableElement) {
      return;
    }

    if (!element.isFinal && !element.isConst) {
      return;
    }

    final AstNode? blockBody = node.parent;
    if (blockBody == null) {
      return;
    }

    final checker = _ReturnVariableChecker(element, node);
    blockBody.visitChildren(checker);

    if (!checker.hasBadStatementCount()) {
      return;
    }

    if (!checker.foundTokensBetweenDeclarationAndReturn) {
      rule.reportAtNode(node);
      return;
    }

    final VariableDeclaration? declaration = checker.variableDeclaration;
    final Expression? initializer = declaration?.initializer;
    if (initializer == null || !_isExpressionImmutable(initializer)) {
      return;
    }

    rule.reportAtNode(node);
  }

  bool _isExpressionImmutable(Expression expr) {
    final visitor = ExpressionIdentifiersVisitor();
    expr.accept(visitor);

    return visitor.identifiers.every(_isSimpleIdentifierImmutable);
  }

  bool _isSimpleIdentifierImmutable(SimpleIdentifier identifier) {
    switch (identifier.element) {
      case final VariableElement variable:
        return variable.isFinal || variable.isConst;
      case ClassElement _:
        return true;
      case GetterElement(:final PropertyInducingElement variable):
        return variable.isFinal || variable.isConst;
      default:
        return false;
    }
  }
}

class _ReturnVariableChecker extends RecursiveAstVisitor<void> {
  _ReturnVariableChecker(this.returnVariableElement, this.returnStatement);

  final LocalVariableElement returnVariableElement;
  final ReturnStatement returnStatement;

  var foundTokensBetweenDeclarationAndReturn = false;
  VariableDeclaration? variableDeclaration;
  var variableStatementCounter = 0;

  bool hasBadStatementCount() => variableStatementCounter == 1;

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    final VariableDeclaration? targetVariable = node.variables.variables.firstWhereOrNull(
      (v) => v.declaredFragment?.element.id == returnVariableElement.id,
    );

    if (targetVariable != null) {
      variableDeclaration = targetVariable;
      final Token? tokenBeforeReturn = returnStatement.findPrevious(returnStatement.beginToken);
      if (tokenBeforeReturn != node.endToken) {
        foundTokensBetweenDeclarationAndReturn = true;
      }
    }

    super.visitVariableDeclarationStatement(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.element?.id == returnVariableElement.id) {
      variableStatementCounter++;
    }
    super.visitSimpleIdentifier(node);
  }
}
