import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class CyclomaticComplexityRule extends AnalysisRule {
  CyclomaticComplexityRule({this.maxComplexity = 10})
    : super(
        name: 'cyclomatic_complexity',
        description: 'Limit cyclomatic complexity in function bodies.',
      );

  final int maxComplexity;

  static const code = LintCode(
    'cyclomatic_complexity',
    'The maximum allowed complexity of a function is {0}. Please decrease it.',
    correctionMessage: 'Try splitting this function into smaller parts.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.cyclomatic_complexity',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addMethodDeclaration(this, _Visitor(this))
      ..addFunctionDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final CyclomaticComplexityRule rule;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkBody(node.body);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkBody(node.functionExpression.body);
  }

  void _checkBody(FunctionBody? body) {
    if (body is! BlockFunctionBody) {
      return;
    }

    final complexityVisitor = _CyclomaticComplexityFlowVisitor();
    body.visitChildren(complexityVisitor);

    if (complexityVisitor.complexityEntities.length + 1 > rule.maxComplexity) {
      rule.reportAtNode(body, arguments: [rule.maxComplexity]);
    }
  }
}

class _CyclomaticComplexityFlowVisitor extends RecursiveAstVisitor<void> {
  static const List<TokenType> _complexityTokenTypes = [
    TokenType.AMPERSAND_AMPERSAND,
    TokenType.BAR_BAR,
    TokenType.QUESTION_PERIOD,
    TokenType.QUESTION_QUESTION,
    TokenType.QUESTION_QUESTION_EQ,
  ];

  final complexityEntities = <SyntacticEntity>{};

  @override
  void visitAssertStatement(AssertStatement node) {
    _increaseComplexity(node);
    super.visitAssertStatement(node);
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    _visitBlock(
      node.block.leftBracket.next,
      node.block.rightBracket,
    );
    super.visitBlockFunctionBody(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    _increaseComplexity(node);
    super.visitCatchClause(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _increaseComplexity(node);
    super.visitConditionalExpression(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _visitBlock(
      node.expression.beginToken.previous,
      node.expression.endToken.next,
    );
    super.visitExpressionFunctionBody(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    _increaseComplexity(node);
    super.visitForStatement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _increaseComplexity(node);
    super.visitIfStatement(node);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _increaseComplexity(node);
    super.visitSwitchCase(node);
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _increaseComplexity(node);
    super.visitSwitchDefault(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _increaseComplexity(node);
    super.visitWhileStatement(node);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _increaseComplexity(node);
    super.visitYieldStatement(node);
  }

  void _visitBlock(Token? firstToken, Token? lastToken) {
    var token = firstToken;
    while (token != lastToken && token != null) {
      if (token.matchesAny(_complexityTokenTypes)) {
        _increaseComplexity(token);
      }
      token = token.next;
    }
  }

  void _increaseComplexity(SyntacticEntity entity) {
    complexityEntities.add(entity);
  }
}
